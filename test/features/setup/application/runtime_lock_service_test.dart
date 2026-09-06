import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/core/security/local_security_state_store.dart';
import 'package:qurani/core/security/local_security_store.dart';
import 'package:qurani/core/security/pin_verifier_v1.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';

void main() {
  group('RuntimeLockService', () {
    test(
      'starts locked and an active temporary lock blocks verification',
      () async {
        final clock = _MutableClock(DateTime.utc(2026, 9, 4, 20));
        final harness = _Harness(
          clock: clock,
          initialState: _readyState(
            failedAttemptCount: 5,
            lockedUntilUtc: DateTime.utc(2026, 9, 4, 20, 1),
          ),
        );

        final snapshot = await harness.service.inspect();
        expect(snapshot.unlocked, isFalse);
        expect(snapshot.failedAttemptCount, 5);
        expect(snapshot.lockedUntilUtc, DateTime.utc(2026, 9, 4, 20, 1));

        final result = await harness.service.unlock('482731');

        expect(result.status, RuntimeUnlockStatus.temporarilyLocked);
        expect(harness.pinVerifier.calls, 0);
        expect(harness.keyManagement.unwrapCalls, 0);
        expect(harness.databaseOpener.openCalls, 0);

        final persisted = await harness.stateStore.read();
        expect(persisted!.failedAttemptCount, 5);
        expect(persisted.lockedUntilUtc, DateTime.utc(2026, 9, 4, 20, 1));
      },
    );

    test(
      'applies the exact approved failed-attempt escalation thresholds',
      () async {
        final clock = _MutableClock(DateTime.utc(2026, 9, 4, 20));
        final harness = _Harness(clock: clock, initialState: _readyState());
        harness.pinVerifier.acceptedPin = '999999';

        for (var attempt = 1; attempt <= 4; attempt++) {
          final result = await harness.service.unlock('482731');
          expect(result.status, RuntimeUnlockStatus.invalidPin);
          expect(result.snapshot.failedAttemptCount, attempt);
          expect(result.snapshot.lockedUntilUtc, isNull);
        }

        final fifth = await harness.service.unlock('482731');
        expect(fifth.status, RuntimeUnlockStatus.temporarilyLocked);
        expect(fifth.snapshot.lockedUntilUtc, DateTime.utc(2026, 9, 4, 20, 1));

        clock.now = DateTime.utc(2026, 9, 4, 20, 1, 1);

        for (var attempt = 6; attempt <= 9; attempt++) {
          final result = await harness.service.unlock('482731');
          expect(result.status, RuntimeUnlockStatus.invalidPin);
          expect(result.snapshot.failedAttemptCount, attempt);
          expect(result.snapshot.lockedUntilUtc, isNull);
        }

        final tenth = await harness.service.unlock('482731');
        expect(tenth.status, RuntimeUnlockStatus.temporarilyLocked);
        expect(
          tenth.snapshot.lockedUntilUtc,
          DateTime.utc(2026, 9, 4, 20, 6, 1),
        );

        clock.now = DateTime.utc(2026, 9, 4, 20, 6, 2);

        for (var attempt = 11; attempt <= 14; attempt++) {
          final result = await harness.service.unlock('482731');
          expect(result.status, RuntimeUnlockStatus.invalidPin);
          expect(result.snapshot.failedAttemptCount, attempt);
          expect(result.snapshot.lockedUntilUtc, isNull);
        }

        final fifteenth = await harness.service.unlock('482731');
        expect(fifteenth.status, RuntimeUnlockStatus.temporarilyLocked);
        expect(
          fifteenth.snapshot.lockedUntilUtc,
          DateTime.utc(2026, 9, 4, 20, 21, 2),
        );

        expect(harness.keyManagement.unwrapCalls, 0);
        expect(harness.databaseOpener.openCalls, 0);
      },
    );

    test('wrong PIN never unwraps keys or opens the database', () async {
      final harness = _Harness(
        clock: _MutableClock(DateTime.utc(2026, 9, 4, 20)),
        initialState: _readyState(),
      );
      harness.pinVerifier.acceptedPin = '999999';

      final result = await harness.service.unlock('482731');

      expect(result.status, RuntimeUnlockStatus.invalidPin);
      expect(harness.keyManagement.unwrapCalls, 0);
      expect(harness.databaseOpener.openCalls, 0);
      expect((await harness.service.inspect()).unlocked, isFalse);
    });

    test(
      'correct PIN unwraps both keys, opens DB, and resets attempt state',
      () async {
        final harness = _Harness(
          clock: _MutableClock(DateTime.utc(2026, 9, 4, 20)),
          initialState: _readyState(failedAttemptCount: 9),
        );

        final result = await harness.service.unlock('482731');

        expect(result.status, RuntimeUnlockStatus.unlocked);
        expect(result.snapshot.unlocked, isTrue);
        expect(harness.pinVerifier.calls, 1);
        expect(harness.keyManagement.unwrapCalls, 2);
        expect(harness.databaseOpener.openCalls, 1);

        final persisted = await harness.stateStore.read();
        expect(persisted!.failedAttemptCount, 0);
        expect(persisted.lockedUntilUtc, isNull);
        expect((await harness.service.inspect()).unlocked, isTrue);
      },
    );

    test(
      'change PIN is refused unless the runtime session is already unlocked',
      () async {
        final harness = _Harness(
          clock: _MutableClock(DateTime.utc(2026, 9, 5, 8)),
          initialState: _readyState(),
        );

        await expectLater(
          harness.service.changePin(currentPin: '482731', newPin: '731482'),
          throwsStateError,
        );

        expect(harness.pinVerifier.calls, 0);
        expect(harness.changePinVerifierFactory.calls, 0);
        expect(harness.keyManagement.wrapCalls, 0);
      },
    );

    test(
      'wrong current PIN never creates new verifier or rewraps keys',
      () async {
        final harness = _Harness(
          clock: _MutableClock(DateTime.utc(2026, 9, 5, 8)),
          initialState: _readyState(),
        );

        await harness.service.unlock('482731');
        final writesBefore = harness.rawStore!.writeCalls;

        final result = await harness.service.changePin(
          currentPin: '999999',
          newPin: '731482',
        );

        expect(result.status, RuntimeChangePinStatus.invalidCurrentPin);
        expect(harness.changePinVerifierFactory.calls, 0);
        expect(harness.keyManagement.wrapCalls, 0);
        expect(harness.rawStore!.writeCalls, writesBefore);
        expect(harness.databaseOpener.openCalls, 1);
        expect(harness.databaseOpener.lastHandle!.closeCalls, 0);
        expect((await harness.service.inspect()).unlocked, isTrue);
      },
    );

    test(
      'change PIN rewraps copies of the same DatabaseKey and AudioKey only',
      () async {
        final harness = _Harness(
          clock: _MutableClock(DateTime.utc(2026, 9, 5, 8)),
          initialState: _readyState(
            failedAttemptCount: 4,
            lockedUntilUtc: null,
          ),
        );

        await harness.service.unlock('482731');

        final databaseKeyBefore = List<int>.from(
          harness.keyManagement.databaseKeyBuffer!,
        );
        final audioKeyBefore = List<int>.from(
          harness.keyManagement.audioKeyBuffer!,
        );
        final handle = harness.databaseOpener.lastHandle!;

        harness.changePinVerifierFactory.nextVerifier = _verifier(marker: 13);

        final result = await harness.service.changePin(
          currentPin: '482731',
          newPin: '731482',
        );

        expect(result.status, RuntimeChangePinStatus.changed);
        expect(harness.changePinVerifierFactory.createdPins, <String>[
          '731482',
        ]);
        expect(harness.keyManagement.wrapCalls, 2);
        expect(harness.keyManagement.wrapPins, <String>['731482', '731482']);
        expect(
          harness.keyManagement.wrappedRawKeySnapshots[KeyPurpose.databaseKey],
          databaseKeyBefore,
        );
        expect(
          harness.keyManagement.wrappedRawKeySnapshots[KeyPurpose.audioKey],
          audioKeyBefore,
        );
        expect(
          harness.keyManagement.wrappedRawKeyBuffers[KeyPurpose.databaseKey],
          everyElement(0),
        );
        expect(
          harness.keyManagement.wrappedRawKeyBuffers[KeyPurpose.audioKey],
          everyElement(0),
        );

        final persisted = await harness.stateStore.read();
        expect(persisted, isNotNull);
        expect(
          persisted!.pinVerifier!.verifierBase64,
          _verifier(marker: 13).verifierBase64,
        );
        expect(persisted.failedAttemptCount, 0);
        expect(persisted.lockedUntilUtc, isNull);

        expect(harness.databaseOpener.openCalls, 1);
        expect(handle.closeCalls, 0);
        expect((await harness.service.inspect()).unlocked, isTrue);
      },
    );

    test(
      'rewrap failure leaves persisted PIN security state untouched',
      () async {
        final initialState = _readyState();
        final harness = _Harness(
          clock: _MutableClock(DateTime.utc(2026, 9, 5, 8)),
          initialState: initialState,
        );

        await harness.service.unlock('482731');

        final persistedBefore = await harness.stateStore.read();
        final writesBefore = harness.rawStore!.writeCalls;
        harness.keyManagement.throwOnWrapCall = 2;

        await expectLater(
          harness.service.changePin(currentPin: '482731', newPin: '731482'),
          throwsStateError,
        );

        final persistedAfter = await harness.stateStore.read();

        expect(harness.rawStore!.writeCalls, writesBefore);
        expect(
          persistedAfter!.pinVerifier!.verifierBase64,
          persistedBefore!.pinVerifier!.verifierBase64,
        );
        expect(
          persistedAfter.databaseKeyEnvelope!.outer.ciphertextBase64,
          persistedBefore.databaseKeyEnvelope!.outer.ciphertextBase64,
        );
        expect(
          persistedAfter.audioKeyEnvelope!.outer.ciphertextBase64,
          persistedBefore.audioKeyEnvelope!.outer.ciphertextBase64,
        );
        expect((await harness.service.inspect()).unlocked, isTrue);
      },
    );

    test(
      'production change-PIN verifier uses approved PinVerifierV1 policy',
      () async {
        final factory = ProductionChangePinVerifierFactory();
        final verifierService = PinVerifierV1Service();

        final verifier = await factory.create('482731');

        expect(
          await verifierService.verify(pin: '482731', verifier: verifier),
          isTrue,
        );
        expect(
          await verifierService.verify(pin: '731482', verifier: verifier),
          isFalse,
        );

        await expectLater(factory.create('123456'), throwsArgumentError);
      },
    );

    test(
      'explicit lock closes database and wipes both unwrapped key buffers',
      () async {
        final harness = _Harness(
          clock: _MutableClock(DateTime.utc(2026, 9, 4, 20)),
          initialState: _readyState(),
        );

        await harness.service.unlock('482731');

        final databaseKey = harness.keyManagement.databaseKeyBuffer!;
        final audioKey = harness.keyManagement.audioKeyBuffer!;
        final handle = harness.databaseOpener.lastHandle!;

        expect(databaseKey, isNot(everyElement(0)));
        expect(audioKey, isNot(everyElement(0)));
        expect(handle.closeCalls, 0);

        await harness.service.lock();

        expect(handle.closeCalls, 1);
        expect(databaseKey, everyElement(0));
        expect(audioKey, everyElement(0));
        expect((await harness.service.inspect()).unlocked, isFalse);
      },
    );

    test(
      'a new runtime service instance is locked even if the prior process session was unlocked',
      () async {
        final rawStore = _MemorySecurityStore();
        final stateStore = LocalSecurityStateStore(store: rawStore);
        await stateStore.write(_readyState());

        final firstHarness = _Harness.withStateStore(
          clock: _MutableClock(DateTime.utc(2026, 9, 4, 20)),
          stateStore: stateStore,
        );

        await firstHarness.service.unlock('482731');
        expect((await firstHarness.service.inspect()).unlocked, isTrue);

        final secondHarness = _Harness.withStateStore(
          clock: _MutableClock(DateTime.utc(2026, 9, 4, 20)),
          stateStore: stateStore,
        );

        expect((await secondHarness.service.inspect()).unlocked, isFalse);

        await firstHarness.service.dispose();
        await secondHarness.service.dispose();
      },
    );

    test(
      'database-open failure wipes recovered keys and keeps session locked',
      () async {
        final harness = _Harness(
          clock: _MutableClock(DateTime.utc(2026, 9, 4, 20)),
          initialState: _readyState(),
        );
        harness.databaseOpener.throwOnOpen = true;

        await expectLater(harness.service.unlock('482731'), throwsStateError);

        expect(harness.keyManagement.databaseKeyBuffer, isNotNull);
        expect(harness.keyManagement.databaseKeyBuffer!, everyElement(0));
        expect(harness.keyManagement.audioKeyBuffer!, everyElement(0));
        expect((await harness.service.inspect()).unlocked, isFalse);
      },
    );

    test('runtime unlock refuses preparing setup state', () async {
      final harness = _Harness(
        clock: _MutableClock(DateTime.utc(2026, 9, 4, 20)),
        initialState: const LocalSecurityStateV1(
          setupState: SetupStateV1.preparing,
        ),
      );

      await expectLater(harness.service.unlock('482731'), throwsStateError);

      expect(harness.pinVerifier.calls, 0);
      expect(harness.keyManagement.unwrapCalls, 0);
      expect(harness.databaseOpener.openCalls, 0);
    });
  });
}

final class _Harness {
  factory _Harness({
    required _MutableClock clock,
    required LocalSecurityStateV1 initialState,
  }) {
    final rawStore = _MemorySecurityStore(initialState);

    return _Harness._(
      clock: clock,
      rawStore: rawStore,
      stateStore: LocalSecurityStateStore(store: rawStore),
    );
  }

  factory _Harness.withStateStore({
    required _MutableClock clock,
    required LocalSecurityStateStore stateStore,
  }) {
    return _Harness._(clock: clock, rawStore: null, stateStore: stateStore);
  }

  _Harness._({
    required this.clock,
    required this.rawStore,
    required this.stateStore,
  }) : pinVerifier = _FakeRuntimePinVerifier(),
       changePinVerifierFactory = _FakeChangePinVerifierFactory(),
       keyManagement = _FakeKeyManagement(),
       databaseOpener = _FakeRuntimeDatabaseOpener() {
    service = RuntimeLockService(
      securityStateStore: stateStore,
      keyManagement: keyManagement,
      pinVerifier: pinVerifier,
      databaseOpener: databaseOpener,
      clock: clock,
      changePinVerifierFactory: changePinVerifierFactory,
    );
  }

  final _MutableClock clock;
  final _MemorySecurityStore? rawStore;
  final LocalSecurityStateStore stateStore;
  final _FakeRuntimePinVerifier pinVerifier;
  final _FakeChangePinVerifierFactory changePinVerifierFactory;
  final _FakeKeyManagement keyManagement;
  final _FakeRuntimeDatabaseOpener databaseOpener;
  late final RuntimeLockService service;
}

final class _MemorySecurityStore implements LocalSecurityStore {
  _MemorySecurityStore([LocalSecurityStateV1? initialState])
    : payload = initialState == null
          ? null
          : const LocalSecurityStateV1Codec().encode(initialState);

  Uint8List? payload;
  int writeCalls = 0;

  @override
  Future<void> clear() async {
    payload = null;
  }

  @override
  Future<Uint8List?> read() async {
    final value = payload;
    return value == null ? null : Uint8List.fromList(value);
  }

  @override
  Future<void> write(Uint8List payload) async {
    writeCalls += 1;
    this.payload = Uint8List.fromList(payload);
  }
}

final class _MutableClock implements Clock {
  _MutableClock(this.now);

  DateTime now;

  @override
  DateTime nowUtc() => now.toUtc();

  @override
  DateTime todayLocal() {
    final local = now.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

final class _FakeRuntimePinVerifier implements RuntimePinVerifier {
  String acceptedPin = '482731';
  int calls = 0;

  @override
  Future<bool> verify({
    required String pin,
    required PinVerifierV1 verifier,
  }) async {
    calls += 1;
    return pin == acceptedPin;
  }
}

final class _FakeChangePinVerifierFactory implements ChangePinVerifierFactory {
  int calls = 0;
  final List<String> createdPins = <String>[];
  PinVerifierV1 nextVerifier = _verifier(marker: 13);
  bool throwOnCreate = false;

  @override
  Future<PinVerifierV1> create(String pin) async {
    calls += 1;
    createdPins.add(pin);

    if (throwOnCreate) {
      throw ArgumentError.value(pin, 'pin', 'simulated invalid new PIN');
    }

    return nextVerifier;
  }
}

final class _FakeKeyManagement implements KeyManagement {
  int unwrapCalls = 0;
  int wrapCalls = 0;
  int? throwOnWrapCall;

  Uint8List? databaseKeyBuffer;
  Uint8List? audioKeyBuffer;

  final List<String> wrapPins = <String>[];
  final Map<KeyPurpose, List<int>> wrappedRawKeySnapshots =
      <KeyPurpose, List<int>>{};
  final Map<KeyPurpose, Uint8List> wrappedRawKeyBuffers =
      <KeyPurpose, Uint8List>{};

  @override
  Future<KeystoreMasterKeyInfo> ensureMasterKey() {
    throw UnimplementedError();
  }

  @override
  Uint8List generateRandomKey() {
    throw UnimplementedError();
  }

  @override
  Uint8List generateSalt() {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> unwrapKey({
    required KeyEnvelopeV1 envelope,
    required String pin,
  }) async {
    unwrapCalls += 1;

    final buffer = Uint8List.fromList(
      List<int>.filled(
        QuraniKeyManagement.keyBytes,
        envelope.purpose == KeyPurpose.databaseKey ? 7 : 9,
      ),
    );

    if (envelope.purpose == KeyPurpose.databaseKey) {
      databaseKeyBuffer = buffer;
    } else {
      audioKeyBuffer = buffer;
    }

    return buffer;
  }

  @override
  Future<KeyEnvelopeV1> wrapKey({
    required KeyPurpose purpose,
    required Uint8List rawKey,
    required String pin,
    Uint8List? salt,
  }) async {
    wrapCalls += 1;

    if (throwOnWrapCall == wrapCalls) {
      throw StateError('simulated wrap failure');
    }

    wrapPins.add(pin);
    wrappedRawKeySnapshots[purpose] = List<int>.from(rawKey);
    wrappedRawKeyBuffers[purpose] = rawKey;

    return _envelope(
      purpose,
      marker: purpose == KeyPurpose.databaseKey ? 21 : 22,
    );
  }
}

final class _FakeRuntimeDatabaseHandle implements RuntimeDatabaseHandle {
  int closeCalls = 0;

  @override
  Future<void> close() async {
    closeCalls += 1;
  }
}

final class _FakeRuntimeDatabaseOpener implements RuntimeDatabaseOpener {
  int openCalls = 0;
  bool throwOnOpen = false;
  _FakeRuntimeDatabaseHandle? lastHandle;

  @override
  Future<RuntimeDatabaseHandle> open({required Uint8List databaseKey}) async {
    openCalls += 1;

    if (throwOnOpen) {
      throw StateError('simulated runtime DB open failure');
    }

    final handle = _FakeRuntimeDatabaseHandle();
    lastHandle = handle;
    return handle;
  }
}

LocalSecurityStateV1 _readyState({
  int failedAttemptCount = 0,
  DateTime? lockedUntilUtc,
}) {
  return LocalSecurityStateV1(
    setupState: SetupStateV1.ready,
    pinVerifier: _verifier(),
    failedAttemptCount: failedAttemptCount,
    lockedUntilUtc: lockedUntilUtc,
    databaseKeyEnvelope: _envelope(KeyPurpose.databaseKey),
    audioKeyEnvelope: _envelope(KeyPurpose.audioKey),
  );
}

PinVerifierV1 _verifier({int marker = 7}) {
  return PinVerifierV1(
    saltBase64: base64Encode(
      List<int>.generate(
        QuraniKeyManagement.saltBytes,
        (index) => index + 1,
        growable: false,
      ),
    ),
    verifierBase64: base64Encode(
      List<int>.filled(PinVerifierV1.verifierBytes, marker),
    ),
  );
}

KeyEnvelopeV1 _envelope(KeyPurpose purpose, {int marker = 9}) {
  return KeyEnvelopeV1(
    version: KeyEnvelopeV1.supportedVersion,
    purpose: purpose,
    saltBase64: base64Encode(
      List<int>.generate(
        QuraniKeyManagement.saltBytes,
        (index) => index + 11,
        growable: false,
      ),
    ),
    kdf: QuraniKeyManagement.currentKdf,
    outer: KeystoreOuterEnvelope(
      version: KeyEnvelopeV1.supportedVersion,
      alias: QuraniKeyManagement.masterKeyAlias,
      algorithm: QuraniKeyManagement.masterKeyTransformation,
      ivBase64: base64Encode(List<int>.filled(12, marker)),
      ciphertextBase64: base64Encode(List<int>.filled(48, marker)),
    ),
  );
}
