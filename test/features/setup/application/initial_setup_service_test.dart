import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/core/security/local_security_state_store.dart';
import 'package:qurani/core/security/local_security_store.dart';
import 'package:qurani/core/security/pin_verifier_v1.dart';
import 'package:qurani/features/setup/application/initial_setup_database_coordinator.dart';
import 'package:qurani/features/setup/application/initial_setup_service.dart';
import 'package:qurani/features/setup/domain/initial_setup_request.dart';

import '../../../helpers/fake_clock.dart';

void main() {
  group('InitialSetupRequest', () {
    test('maps no-support and support choices to the approved states', () {
      const disabled = InitialSetupRequest(
        teacherName: ' المعلم ',
        halaqahName: ' الحلقة ',
        centerName: ' المركز ',
        hasSupportOrganization: false,
        supportOrganizationName: null,
        pin: '482731',
      );

      const pending = InitialSetupRequest(
        teacherName: 'المعلم',
        halaqahName: 'الحلقة',
        centerName: 'المركز',
        hasSupportOrganization: true,
        supportOrganizationName: ' الجهة ',
        pin: '482731',
      );

      disabled.validate();
      pending.validate();

      expect(disabled.supportStatus, 'disabled');
      expect(disabled.normalizedSupportOrganizationName, isNull);
      expect(pending.supportStatus, 'pending_activation');
      expect(pending.normalizedSupportOrganizationName, 'الجهة');
    });

    test('rejects missing identity/support fields and weak PIN', () {
      expect(
        () => const InitialSetupRequest(
          teacherName: '',
          halaqahName: 'حلقة',
          centerName: 'مركز',
          hasSupportOrganization: false,
          supportOrganizationName: null,
          pin: '482731',
        ).validate(),
        throwsArgumentError,
      );

      expect(
        () => const InitialSetupRequest(
          teacherName: 'معلم',
          halaqahName: 'حلقة',
          centerName: 'مركز',
          hasSupportOrganization: true,
          supportOrganizationName: ' ',
          pin: '482731',
        ).validate(),
        throwsArgumentError,
      );

      expect(
        () => const InitialSetupRequest(
          teacherName: 'معلم',
          halaqahName: 'حلقة',
          centerName: 'مركز',
          hasSupportOrganization: false,
          supportOrganizationName: null,
          pin: '123456',
        ).validate(),
        throwsArgumentError,
      );
    });
  });

  group('InitialSetupService crash-safe orchestration', () {
    test(
      'fresh setup publishes candidate then marks security state ready',
      () async {
        final harness = _Harness();
        final service = harness.service();

        await service.execute(_request());

        final state = await harness.stateStore.read();

        expect(state, isNotNull);
        expect(state!.setupState, SetupStateV1.ready);
        expect(state.failedAttemptCount, 0);
        expect(state.lockedUntilUtc, isNull);
        expect(state.pinVerifier, isNotNull);
        expect(state.databaseKeyEnvelope, isNotNull);
        expect(state.audioKeyEnvelope, isNotNull);

        expect(harness.database.finalExists, isTrue);
        expect(harness.database.candidateExists, isFalse);
        expect(
          harness.database.operations,
          containsAllInOrder(<String>[
            'buildCandidate',
            'publishCandidate',
            'verifyFinal',
          ]),
        );
        expect(harness.keyManagement.ensureMasterKeyCount, 1);
        expect(harness.keyManagement.generatedKeyCount, 2);
      },
    );

    test(
      'support choice stays pending_activation during Package 2 setup',
      () async {
        final harness = _Harness();

        await harness.service().execute(
          _request(hasSupport: true, organizationName: 'مؤسسة الخير'),
        );

        expect(harness.database.lastRequest, isNotNull);
        expect(
          harness.database.lastRequest!.supportStatus,
          'pending_activation',
        );
        expect(
          harness.database.lastRequest!.normalizedSupportOrganizationName,
          'مؤسسة الخير',
        );
      },
    );

    test(
      'retry after publication failure reuses staged security material',
      () async {
        final harness = _Harness();
        harness.database.failPublishOnce = true;

        await expectLater(
          harness.service().execute(_request()),
          throwsStateError,
        );

        final preparing = await harness.stateStore.read();
        expect(preparing!.setupState, SetupStateV1.preparing);
        expect(preparing.pinVerifier, isNotNull);
        expect(preparing.databaseKeyEnvelope, isNotNull);
        expect(harness.database.candidateExists, isTrue);
        expect(harness.keyManagement.generatedKeyCount, 2);

        await harness.service().execute(_request());

        final ready = await harness.stateStore.read();
        expect(ready!.setupState, SetupStateV1.ready);
        expect(harness.keyManagement.generatedKeyCount, 2);
        expect(harness.database.operations, contains('verifyCandidate'));
        expect(harness.database.finalExists, isTrue);
      },
    );

    test(
      'crash after atomic publish resumes from final DB before ready',
      () async {
        final rawStore = _MemorySecurityStore(failReadyWriteOnce: true);
        final harness = _Harness(rawStore: rawStore);

        await expectLater(
          harness.service().execute(_request()),
          throwsStateError,
        );

        expect(harness.database.finalExists, isTrue);
        expect(harness.database.candidateExists, isFalse);

        final preparing = await harness.stateStore.read();
        expect(preparing!.setupState, SetupStateV1.preparing);

        await harness.service().execute(_request());

        final ready = await harness.stateStore.read();
        expect(ready!.setupState, SetupStateV1.ready);
        expect(
          harness.database.operations
              .where((operation) => operation == 'verifyFinal')
              .length,
          greaterThanOrEqualTo(2),
        );
        expect(harness.keyManagement.generatedKeyCount, 2);
      },
    );

    test('wrong PIN cannot resume staged setup material', () async {
      final harness = _Harness();
      harness.database.failPublishOnce = true;

      await expectLater(
        harness.service().execute(_request()),
        throwsStateError,
      );

      await expectLater(
        harness.service().execute(_request(pin: '482732')),
        throwsStateError,
      );

      expect(harness.database.finalExists, isFalse);
      expect(harness.database.candidateExists, isTrue);
    });

    test('completed setup rejects a second setup attempt', () async {
      final harness = _Harness();
      final service = harness.service();

      await service.execute(_request());

      await expectLater(service.execute(_request()), throwsStateError);
    });
  });
}

InitialSetupRequest _request({
  String pin = '482731',
  bool hasSupport = false,
  String? organizationName,
}) {
  return InitialSetupRequest(
    teacherName: 'عبدالحكيم قائد',
    halaqahName: 'حلقة ذي النورين',
    centerName: 'المركز الرئيسي',
    hasSupportOrganization: hasSupport,
    supportOrganizationName: organizationName,
    pin: pin,
  );
}

final class _Harness {
  _Harness({_MemorySecurityStore? rawStore})
    : rawStore = rawStore ?? _MemorySecurityStore(),
      database = _FakeDatabaseCoordinator(),
      keyManagement = _FakeKeyManagement(),
      pinVerifier = _FakePinVerifier() {
    stateStore = LocalSecurityStateStore(store: this.rawStore);
  }

  final _MemorySecurityStore rawStore;
  final _FakeDatabaseCoordinator database;
  final _FakeKeyManagement keyManagement;
  final _FakePinVerifier pinVerifier;
  late final LocalSecurityStateStore stateStore;

  InitialSetupService service() {
    return InitialSetupService(
      securityStateStore: stateStore,
      keyManagement: keyManagement,
      pinVerifier: pinVerifier,
      databaseCoordinator: database,
      clock: FakeClock(
        nowUtc: DateTime.utc(2026, 9, 4, 19),
        todayLocal: DateTime(2026, 9, 4),
      ),
    );
  }
}

final class _MemorySecurityStore implements LocalSecurityStore {
  _MemorySecurityStore({this.failReadyWriteOnce = false});

  final bool failReadyWriteOnce;
  Uint8List? _payload;
  bool _readyFailureConsumed = false;

  @override
  Future<void> clear() async {
    _payload = null;
  }

  @override
  Future<Uint8List?> read() async {
    final payload = _payload;
    return payload == null ? null : Uint8List.fromList(payload);
  }

  @override
  Future<void> write(Uint8List payload) async {
    final decoded = const LocalSecurityStateV1Codec().decode(payload);

    if (failReadyWriteOnce &&
        !_readyFailureConsumed &&
        decoded.setupState == SetupStateV1.ready) {
      _readyFailureConsumed = true;
      throw StateError('Simulated crash before ready state publication.');
    }

    _payload = Uint8List.fromList(payload);
  }
}

final class _FakePinVerifier implements InitialSetupPinVerifier {
  final Map<String, String> _pins = <String, String>{};
  var _counter = 0;

  @override
  Future<PinVerifierV1> create({required String pin}) async {
    _counter += 1;
    final verifierBytes = List<int>.generate(
      PinVerifierV1.verifierBytes,
      (index) => (_counter + index) & 0xff,
      growable: false,
    );
    final verifierBase64 = base64Encode(verifierBytes);
    _pins[verifierBase64] = pin;

    return PinVerifierV1(
      saltBase64: base64Encode(
        List<int>.generate(
          QuraniKeyManagement.saltBytes,
          (index) => index + 1,
          growable: false,
        ),
      ),
      verifierBase64: verifierBase64,
    );
  }

  @override
  Future<bool> verify({
    required String pin,
    required PinVerifierV1 verifier,
  }) async {
    return _pins[verifier.verifierBase64] == pin;
  }
}

final class _FakeKeyManagement implements KeyManagement {
  var ensureMasterKeyCount = 0;
  var generatedKeyCount = 0;

  @override
  Future<KeystoreMasterKeyInfo> ensureMasterKey() async {
    ensureMasterKeyCount += 1;
    return const KeystoreMasterKeyInfo(
      alias: QuraniKeyManagement.masterKeyAlias,
      aliasExists: true,
      algorithm: QuraniKeyManagement.masterKeyAlgorithm,
      configuredKeySizeBits: QuraniKeyManagement.masterKeyBits,
      transformation: QuraniKeyManagement.masterKeyTransformation,
      encodedIsNull: true,
      userAuthenticationRequired: false,
    );
  }

  @override
  Uint8List generateRandomKey() {
    generatedKeyCount += 1;
    return Uint8List.fromList(
      List<int>.generate(
        QuraniKeyManagement.keyBytes,
        (index) => (generatedKeyCount * 31 + index) & 0xff,
        growable: false,
      ),
    );
  }

  @override
  Uint8List generateSalt() {
    return Uint8List.fromList(
      List<int>.generate(
        QuraniKeyManagement.saltBytes,
        (index) => index + 11,
        growable: false,
      ),
    );
  }

  @override
  Future<KeyEnvelopeV1> wrapKey({
    required KeyPurpose purpose,
    required Uint8List rawKey,
    required String pin,
    Uint8List? salt,
  }) async {
    return KeyEnvelopeV1(
      version: KeyEnvelopeV1.supportedVersion,
      purpose: purpose,
      saltBase64: base64Encode(salt ?? generateSalt()),
      kdf: QuraniKeyManagement.currentKdf,
      outer: KeystoreOuterEnvelope(
        version: KeyEnvelopeV1.supportedVersion,
        alias: QuraniKeyManagement.masterKeyAlias,
        algorithm: QuraniKeyManagement.masterKeyTransformation,
        ivBase64: base64Encode(List<int>.filled(12, 7)),
        ciphertextBase64: base64Encode(rawKey),
      ),
    );
  }

  @override
  Future<Uint8List> unwrapKey({
    required KeyEnvelopeV1 envelope,
    required String pin,
  }) async {
    return Uint8List.fromList(base64Decode(envelope.outer.ciphertextBase64));
  }
}

final class _FakeDatabaseCoordinator
    implements InitialSetupDatabaseCoordinator {
  bool finalExists = false;
  bool candidateExists = false;
  bool failPublishOnce = false;
  bool _publishFailureConsumed = false;
  InitialSetupRequest? lastRequest;
  final List<String> operations = <String>[];

  @override
  Future<bool> finalDatabaseExists() async => finalExists;

  @override
  Future<bool> candidateDatabaseExists() async => candidateExists;

  @override
  Future<void> discardCandidate() async {
    operations.add('discardCandidate');
    candidateExists = false;
  }

  @override
  Future<void> buildAndVerifyCandidate({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
    required DateTime createdAtUtc,
  }) async {
    operations.add('buildCandidate');
    lastRequest = request;
    candidateExists = true;
  }

  @override
  Future<void> verifyCandidate({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
  }) async {
    operations.add('verifyCandidate');
    if (!candidateExists) {
      throw StateError('candidate missing');
    }
    lastRequest = request;
  }

  @override
  Future<void> publishCandidate() async {
    operations.add('publishCandidate');

    if (failPublishOnce && !_publishFailureConsumed) {
      _publishFailureConsumed = true;
      throw StateError('Simulated crash during publication.');
    }

    if (!candidateExists || finalExists) {
      throw StateError('invalid publish state');
    }

    candidateExists = false;
    finalExists = true;
  }

  @override
  Future<void> verifyFinal({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
  }) async {
    operations.add('verifyFinal');
    if (!finalExists) {
      throw StateError('final missing');
    }
    lastRequest = request;
  }
}
