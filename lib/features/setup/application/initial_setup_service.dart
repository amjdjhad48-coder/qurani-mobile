import 'dart:typed_data';

import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/core/security/local_security_state_store.dart';
import 'package:qurani/core/security/pin_verifier_v1.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/setup/application/initial_setup_database_coordinator.dart';
import 'package:qurani/features/setup/domain/initial_setup_request.dart';

abstract interface class InitialSetupPinVerifier {
  Future<PinVerifierV1> create({required String pin});

  Future<bool> verify({required String pin, required PinVerifierV1 verifier});
}

final class ProductionInitialSetupPinVerifier
    implements InitialSetupPinVerifier {
  ProductionInitialSetupPinVerifier({PinVerifierV1Service? service})
    : _service = service ?? PinVerifierV1Service();

  final PinVerifierV1Service _service;

  @override
  Future<PinVerifierV1> create({required String pin}) {
    return _service.create(pin: pin);
  }

  @override
  Future<bool> verify({required String pin, required PinVerifierV1 verifier}) {
    return _service.verify(pin: pin, verifier: verifier);
  }
}

final class InitialSetupService {
  factory InitialSetupService({
    required LocalSecurityStateStore securityStateStore,
    required KeyManagement keyManagement,
    required InitialSetupPinVerifier pinVerifier,
    required InitialSetupDatabaseCoordinator databaseCoordinator,
    required Clock clock,
  }) {
    return InitialSetupService._(
      securityStateStore,
      keyManagement,
      pinVerifier,
      databaseCoordinator,
      clock,
    );
  }

  InitialSetupService._(
    this._securityStateStore,
    this._keyManagement,
    this._pinVerifier,
    this._databaseCoordinator,
    this._clock,
  );

  final LocalSecurityStateStore _securityStateStore;
  final KeyManagement _keyManagement;
  final InitialSetupPinVerifier _pinVerifier;
  final InitialSetupDatabaseCoordinator _databaseCoordinator;
  final Clock _clock;

  Future<void> execute(InitialSetupRequest request) async {
    request.validate();

    var state = await _securityStateStore.read();

    if (state?.setupState == SetupStateV1.ready) {
      throw StateError('Initial setup has already completed.');
    }

    if (state == null) {
      if (await _databaseCoordinator.finalDatabaseExists()) {
        throw StateError(
          'Final database exists without local security setup state.',
        );
      }

      if (await _databaseCoordinator.candidateDatabaseExists()) {
        await _databaseCoordinator.discardCandidate();
      }

      state = const LocalSecurityStateV1(setupState: SetupStateV1.preparing);
      await _securityStateStore.write(state);
    }

    final materialState = state;
    final hasVerifier = materialState.pinVerifier != null;
    final hasDatabaseEnvelope = materialState.databaseKeyEnvelope != null;
    final hasAudioEnvelope = materialState.audioKeyEnvelope != null;
    final materialCount = <bool>[
      hasVerifier,
      hasDatabaseEnvelope,
      hasAudioEnvelope,
    ].where((value) => value).length;

    if (materialCount != 0 && materialCount != 3) {
      throw StateError(
        'Preparing setup state contains partial security material.',
      );
    }

    Uint8List? databaseKey;
    Uint8List? audioKey;

    try {
      if (materialCount == 0) {
        if (await _databaseCoordinator.finalDatabaseExists()) {
          throw StateError(
            'Final database exists before recoverable security material.',
          );
        }

        if (await _databaseCoordinator.candidateDatabaseExists()) {
          await _databaseCoordinator.discardCandidate();
        }

        await _keyManagement.ensureMasterKey();

        databaseKey = _keyManagement.generateRandomKey();
        audioKey = _keyManagement.generateRandomKey();

        if (_bytesEqual(databaseKey, audioKey)) {
          throw StateError('DatabaseKey and AudioKey must be independent.');
        }

        final verifier = await _pinVerifier.create(pin: request.pin);
        final databaseEnvelope = await _keyManagement.wrapKey(
          purpose: KeyPurpose.databaseKey,
          rawKey: databaseKey,
          pin: request.pin,
        );
        final audioEnvelope = await _keyManagement.wrapKey(
          purpose: KeyPurpose.audioKey,
          rawKey: audioKey,
          pin: request.pin,
        );

        state = LocalSecurityStateV1(
          setupState: SetupStateV1.preparing,
          pinVerifier: verifier,
          databaseKeyEnvelope: databaseEnvelope,
          audioKeyEnvelope: audioEnvelope,
        );

        await _securityStateStore.write(state);
      } else {
        final verifier = materialState.pinVerifier!;
        final pinMatches = await _pinVerifier.verify(
          pin: request.pin,
          verifier: verifier,
        );

        if (!pinMatches) {
          throw StateError(
            'PIN does not match the preparing setup security material.',
          );
        }

        databaseKey = await _keyManagement.unwrapKey(
          envelope: materialState.databaseKeyEnvelope!,
          pin: request.pin,
        );
        audioKey = await _keyManagement.unwrapKey(
          envelope: materialState.audioKeyEnvelope!,
          pin: request.pin,
        );
      }

      if (databaseKey.length != QuraniKeyManagement.keyBytes ||
          audioKey.length != QuraniKeyManagement.keyBytes) {
        throw StateError('Recovered setup data key length is invalid.');
      }

      if (await _databaseCoordinator.finalDatabaseExists()) {
        await _databaseCoordinator.verifyFinal(
          request: request,
          databaseKey: databaseKey,
        );

        if (await _databaseCoordinator.candidateDatabaseExists()) {
          await _databaseCoordinator.discardCandidate();
        }

        await _markReady(state);
        return;
      }

      if (await _databaseCoordinator.candidateDatabaseExists()) {
        try {
          await _databaseCoordinator.verifyCandidate(
            request: request,
            databaseKey: databaseKey,
          );
        } catch (_) {
          await _databaseCoordinator.discardCandidate();
          await _databaseCoordinator.buildAndVerifyCandidate(
            request: request,
            databaseKey: databaseKey,
            createdAtUtc: _clock.nowUtc(),
          );
        }
      } else {
        await _databaseCoordinator.buildAndVerifyCandidate(
          request: request,
          databaseKey: databaseKey,
          createdAtUtc: _clock.nowUtc(),
        );
      }

      await _databaseCoordinator.publishCandidate();

      await _databaseCoordinator.verifyFinal(
        request: request,
        databaseKey: databaseKey,
      );

      await _markReady(state);
    } finally {
      databaseKey?.fillRange(0, databaseKey.length, 0);
      audioKey?.fillRange(0, audioKey.length, 0);
    }
  }

  Future<void> _markReady(LocalSecurityStateV1 state) {
    return _securityStateStore.write(
      LocalSecurityStateV1(
        setupState: SetupStateV1.ready,
        pinVerifier: state.pinVerifier,
        failedAttemptCount: 0,
        lockedUntilUtc: null,
        databaseKeyEnvelope: state.databaseKeyEnvelope,
        audioKeyEnvelope: state.audioKeyEnvelope,
      ),
    );
  }

  static bool _bytesEqual(Uint8List first, Uint8List second) {
    if (first.length != second.length) {
      return false;
    }

    var difference = 0;
    for (var index = 0; index < first.length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }
}
