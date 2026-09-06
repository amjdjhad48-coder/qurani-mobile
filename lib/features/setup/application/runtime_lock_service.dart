import 'dart:typed_data';

import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/core/security/local_security_state_store.dart';
import 'package:qurani/core/security/lock_policy.dart';
import 'package:qurani/core/security/pin_verifier_v1.dart';
import 'package:qurani/core/shared/clock.dart';

abstract interface class RuntimePinVerifier {
  Future<bool> verify({required String pin, required PinVerifierV1 verifier});
}

final class ProductionRuntimePinVerifier implements RuntimePinVerifier {
  ProductionRuntimePinVerifier({PinVerifierV1Service? service})
    : _service = service ?? PinVerifierV1Service();

  final PinVerifierV1Service _service;

  @override
  Future<bool> verify({required String pin, required PinVerifierV1 verifier}) {
    return _service.verify(pin: pin, verifier: verifier);
  }
}

abstract interface class ChangePinVerifierFactory {
  Future<PinVerifierV1> create(String pin);
}

final class ProductionChangePinVerifierFactory
    implements ChangePinVerifierFactory {
  ProductionChangePinVerifierFactory({PinVerifierV1Service? service})
    : _service = service ?? PinVerifierV1Service();

  final PinVerifierV1Service _service;

  @override
  Future<PinVerifierV1> create(String pin) {
    return _service.create(pin: pin);
  }
}

abstract interface class RuntimeDatabaseHandle {
  Future<void> close();
}

abstract interface class RuntimeDatabaseOpener {
  Future<RuntimeDatabaseHandle> open({required Uint8List databaseKey});
}

enum RuntimeUnlockStatus { unlocked, invalidPin, temporarilyLocked }

final class RuntimeLockSnapshot {
  const RuntimeLockSnapshot({
    required this.unlocked,
    required this.failedAttemptCount,
    required this.lockedUntilUtc,
  });

  final bool unlocked;
  final int failedAttemptCount;
  final DateTime? lockedUntilUtc;

  bool get isTemporarilyLocked => lockedUntilUtc != null;
}

final class RuntimeUnlockResult {
  const RuntimeUnlockResult({required this.status, required this.snapshot});

  final RuntimeUnlockStatus status;
  final RuntimeLockSnapshot snapshot;
}

enum RuntimeChangePinStatus { changed, invalidCurrentPin }

final class RuntimeChangePinResult {
  const RuntimeChangePinResult(this.status);

  final RuntimeChangePinStatus status;

  bool get changed => status == RuntimeChangePinStatus.changed;
}

abstract interface class RuntimeLockCoordinator {
  Future<RuntimeLockSnapshot> inspect();

  Future<RuntimeUnlockResult> unlock(String pin);

  Future<RuntimeChangePinResult> changePin({
    required String currentPin,
    required String newPin,
  });

  Future<void> lock();

  Future<void> dispose();
}

final class RuntimeLockService implements RuntimeLockCoordinator {
  factory RuntimeLockService({
    required LocalSecurityStateStore securityStateStore,
    required KeyManagement keyManagement,
    required RuntimePinVerifier pinVerifier,
    required RuntimeDatabaseOpener databaseOpener,
    required Clock clock,
    ChangePinVerifierFactory? changePinVerifierFactory,
  }) {
    return RuntimeLockService._(
      securityStateStore,
      keyManagement,
      pinVerifier,
      databaseOpener,
      clock,
      changePinVerifierFactory ?? ProductionChangePinVerifierFactory(),
    );
  }

  RuntimeLockService._(
    this._securityStateStore,
    this._keyManagement,
    this._pinVerifier,
    this._databaseOpener,
    this._clock,
    this._changePinVerifierFactory,
  );

  final LocalSecurityStateStore _securityStateStore;
  final KeyManagement _keyManagement;
  final RuntimePinVerifier _pinVerifier;
  final RuntimeDatabaseOpener _databaseOpener;
  final Clock _clock;
  final ChangePinVerifierFactory _changePinVerifierFactory;

  RuntimeDatabaseHandle? _databaseHandle;
  Uint8List? _databaseKey;
  Uint8List? _audioKey;

  @override
  Future<RuntimeLockSnapshot> inspect() async {
    if (_databaseHandle != null) {
      return const RuntimeLockSnapshot(
        unlocked: true,
        failedAttemptCount: 0,
        lockedUntilUtc: null,
      );
    }

    final state = await _requireReadyState();
    final activeLock = _activeLockUntil(state);

    return RuntimeLockSnapshot(
      unlocked: false,
      failedAttemptCount: state.failedAttemptCount,
      lockedUntilUtc: activeLock,
    );
  }

  @override
  Future<RuntimeUnlockResult> unlock(String pin) async {
    if (_databaseHandle != null) {
      return const RuntimeUnlockResult(
        status: RuntimeUnlockStatus.unlocked,
        snapshot: RuntimeLockSnapshot(
          unlocked: true,
          failedAttemptCount: 0,
          lockedUntilUtc: null,
        ),
      );
    }

    final state = await _requireReadyState();
    final activeLock = _activeLockUntil(state);

    if (activeLock != null) {
      return RuntimeUnlockResult(
        status: RuntimeUnlockStatus.temporarilyLocked,
        snapshot: RuntimeLockSnapshot(
          unlocked: false,
          failedAttemptCount: state.failedAttemptCount,
          lockedUntilUtc: activeLock,
        ),
      );
    }

    final pinMatches = await _pinVerifier.verify(
      pin: pin,
      verifier: state.pinVerifier!,
    );

    if (!pinMatches) {
      return _recordFailedAttempt(state);
    }

    Uint8List? databaseKey;
    Uint8List? audioKey;
    RuntimeDatabaseHandle? openedHandle;

    try {
      databaseKey = await _keyManagement.unwrapKey(
        envelope: state.databaseKeyEnvelope!,
        pin: pin,
      );
      audioKey = await _keyManagement.unwrapKey(
        envelope: state.audioKeyEnvelope!,
        pin: pin,
      );

      if (databaseKey.length != QuraniKeyManagement.keyBytes ||
          audioKey.length != QuraniKeyManagement.keyBytes) {
        throw StateError('Recovered runtime data-key length is invalid.');
      }

      openedHandle = await _databaseOpener.open(databaseKey: databaseKey);

      await _securityStateStore.write(
        _withAttemptState(state, failedAttemptCount: 0, lockedUntilUtc: null),
      );

      _databaseHandle = openedHandle;
      openedHandle = null;

      _databaseKey = databaseKey;
      databaseKey = null;

      _audioKey = audioKey;
      audioKey = null;

      return const RuntimeUnlockResult(
        status: RuntimeUnlockStatus.unlocked,
        snapshot: RuntimeLockSnapshot(
          unlocked: true,
          failedAttemptCount: 0,
          lockedUntilUtc: null,
        ),
      );
    } finally {
      if (openedHandle != null) {
        await openedHandle.close();
      }
      databaseKey?.fillRange(0, databaseKey.length, 0);
      audioKey?.fillRange(0, audioKey.length, 0);
    }
  }

  @override
  Future<RuntimeChangePinResult> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final databaseHandle = _databaseHandle;
    final databaseKey = _databaseKey;
    final audioKey = _audioKey;

    if (databaseHandle == null || databaseKey == null || audioKey == null) {
      throw StateError(
        'Change PIN requires an already-unlocked runtime session.',
      );
    }

    final state = await _requireReadyState();

    final currentPinMatches = await _pinVerifier.verify(
      pin: currentPin,
      verifier: state.pinVerifier!,
    );

    if (!currentPinMatches) {
      return const RuntimeChangePinResult(
        RuntimeChangePinStatus.invalidCurrentPin,
      );
    }

    // Creating the new verifier first applies the already-approved six-digit
    // PIN policy before any security state is replaced.
    final newVerifier = await _changePinVerifierFactory.create(newPin);

    final databaseKeyCopy = Uint8List.fromList(databaseKey);
    final audioKeyCopy = Uint8List.fromList(audioKey);

    try {
      final newDatabaseEnvelope = await _keyManagement.wrapKey(
        purpose: KeyPurpose.databaseKey,
        rawKey: databaseKeyCopy,
        pin: newPin,
      );

      final newAudioEnvelope = await _keyManagement.wrapKey(
        purpose: KeyPurpose.audioKey,
        rawKey: audioKeyCopy,
        pin: newPin,
      );

      await _securityStateStore.write(
        LocalSecurityStateV1(
          version: state.version,
          setupState: state.setupState,
          pinVerifier: newVerifier,
          failedAttemptCount: 0,
          lockedUntilUtc: null,
          databaseKeyEnvelope: newDatabaseEnvelope,
          audioKeyEnvelope: newAudioEnvelope,
        ),
      );

      return const RuntimeChangePinResult(RuntimeChangePinStatus.changed);
    } finally {
      databaseKeyCopy.fillRange(0, databaseKeyCopy.length, 0);
      audioKeyCopy.fillRange(0, audioKeyCopy.length, 0);
    }
  }

  Future<RuntimeUnlockResult> _recordFailedAttempt(
    LocalSecurityStateV1 state,
  ) async {
    final failedAttemptCount = state.failedAttemptCount + 1;
    final lockDuration = LockPolicy.lockDurationAfterFailedAttempts(
      failedAttemptCount,
    );
    final lockedUntilUtc = lockDuration == null
        ? null
        : _clock.nowUtc().add(lockDuration);

    await _securityStateStore.write(
      _withAttemptState(
        state,
        failedAttemptCount: failedAttemptCount,
        lockedUntilUtc: lockedUntilUtc,
      ),
    );

    return RuntimeUnlockResult(
      status: lockedUntilUtc == null
          ? RuntimeUnlockStatus.invalidPin
          : RuntimeUnlockStatus.temporarilyLocked,
      snapshot: RuntimeLockSnapshot(
        unlocked: false,
        failedAttemptCount: failedAttemptCount,
        lockedUntilUtc: lockedUntilUtc,
      ),
    );
  }

  @override
  Future<void> lock() async {
    final handle = _databaseHandle;
    final databaseKey = _databaseKey;
    final audioKey = _audioKey;

    _databaseHandle = null;
    _databaseKey = null;
    _audioKey = null;

    databaseKey?.fillRange(0, databaseKey.length, 0);
    audioKey?.fillRange(0, audioKey.length, 0);

    if (handle != null) {
      await handle.close();
    }
  }

  @override
  Future<void> dispose() {
    return lock();
  }

  Future<LocalSecurityStateV1> _requireReadyState() async {
    final state = await _securityStateStore.read();

    if (state == null || state.setupState != SetupStateV1.ready) {
      throw StateError('Runtime PIN unlock requires completed initial setup.');
    }

    return state;
  }

  DateTime? _activeLockUntil(LocalSecurityStateV1 state) {
    final lockedUntilUtc = state.lockedUntilUtc;
    if (lockedUntilUtc == null) {
      return null;
    }

    return lockedUntilUtc.isAfter(_clock.nowUtc()) ? lockedUntilUtc : null;
  }

  static LocalSecurityStateV1 _withAttemptState(
    LocalSecurityStateV1 state, {
    required int failedAttemptCount,
    required DateTime? lockedUntilUtc,
  }) {
    return LocalSecurityStateV1(
      version: state.version,
      setupState: state.setupState,
      pinVerifier: state.pinVerifier,
      failedAttemptCount: failedAttemptCount,
      lockedUntilUtc: lockedUntilUtc,
      databaseKeyEnvelope: state.databaseKeyEnvelope,
      audioKeyEnvelope: state.audioKeyEnvelope,
    );
  }
}
