import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/core/security/local_security_state_store.dart';
import 'package:qurani/core/security/local_security_store.dart';
import 'package:qurani/core/security/pin_verifier_v1.dart';

void main() {
  group('LocalSecurityStateV1', () {
    test('preparing state may exist before security material is complete', () {
      const codec = LocalSecurityStateV1Codec();
      const state = LocalSecurityStateV1(setupState: SetupStateV1.preparing);

      final decoded = codec.decode(codec.encode(state));

      expect(decoded.version, LocalSecurityStateV1.supportedVersion);
      expect(decoded.setupState, SetupStateV1.preparing);
      expect(decoded.pinVerifier, isNull);
      expect(decoded.databaseKeyEnvelope, isNull);
      expect(decoded.audioKeyEnvelope, isNull);
      expect(decoded.failedAttemptCount, 0);
    });

    test(
      'ready state requires verifier and both purpose-correct envelopes',
      () {
        const codec = LocalSecurityStateV1Codec();

        final state = LocalSecurityStateV1(
          setupState: SetupStateV1.ready,
          pinVerifier: _verifier(),
          failedAttemptCount: 10,
          lockedUntilUtc: DateTime.utc(2026, 9, 4, 13, 30),
          databaseKeyEnvelope: _envelope(KeyPurpose.databaseKey),
          audioKeyEnvelope: _envelope(KeyPurpose.audioKey),
        );

        final decoded = codec.decode(codec.encode(state));

        expect(decoded.setupState, SetupStateV1.ready);
        expect(decoded.failedAttemptCount, 10);
        expect(decoded.lockedUntilUtc, DateTime.utc(2026, 9, 4, 13, 30));
        expect(decoded.databaseKeyEnvelope!.purpose, KeyPurpose.databaseKey);
        expect(decoded.audioKeyEnvelope!.purpose, KeyPurpose.audioKey);
      },
    );

    test('ready state rejects missing required security material', () {
      const codec = LocalSecurityStateV1Codec();
      const invalid = LocalSecurityStateV1(setupState: SetupStateV1.ready);

      expect(() => codec.encode(invalid), throwsFormatException);
    });

    test('rejects a key envelope stored under the wrong purpose', () {
      const codec = LocalSecurityStateV1Codec();

      final invalid = LocalSecurityStateV1(
        setupState: SetupStateV1.ready,
        pinVerifier: _verifier(),
        databaseKeyEnvelope: _envelope(KeyPurpose.audioKey),
        audioKeyEnvelope: _envelope(KeyPurpose.audioKey),
      );

      expect(() => codec.encode(invalid), throwsFormatException);
    });

    test('rejects non-UTC lock deadlines and unknown state versions', () {
      const codec = LocalSecurityStateV1Codec();

      final localDeadline = LocalSecurityStateV1(
        setupState: SetupStateV1.preparing,
        lockedUntilUtc: DateTime(2026, 9, 4, 13, 30),
      );

      expect(() => codec.encode(localDeadline), throwsFormatException);

      final unknownVersion = Uint8List.fromList(
        utf8.encode(
          jsonEncode(<String, Object?>{
            'version': 2,
            'setupState': 'preparing',
            'pinVerifier': null,
            'failedAttemptCount': 0,
            'lockedUntilUtc': null,
            'databaseKeyEnvelope': null,
            'audioKeyEnvelope': null,
          }),
        ),
      );

      expect(() => codec.decode(unknownVersion), throwsFormatException);
    });

    test('serialized state contains no raw PIN or raw data-key fields', () {
      const codec = LocalSecurityStateV1Codec();

      final state = LocalSecurityStateV1(
        setupState: SetupStateV1.ready,
        pinVerifier: _verifier(),
        databaseKeyEnvelope: _envelope(KeyPurpose.databaseKey),
        audioKeyEnvelope: _envelope(KeyPurpose.audioKey),
      );

      final json = utf8.decode(codec.encode(state));

      expect(json, isNot(contains('"pin":')));
      expect(json, isNot(contains('"pinKek":')));
      expect(json, isNot(contains('"databaseKey":')));
      expect(json, isNot(contains('"audioKey":')));
      expect(json, contains('"pinVerifier":'));
      expect(json, contains('"databaseKeyEnvelope":'));
      expect(json, contains('"audioKeyEnvelope":'));
    });
  });

  group('LocalSecurityStateStore', () {
    test(
      'round-trips versioned state through opaque LocalSecurityStore bytes',
      () async {
        final rawStore = _MemoryLocalSecurityStore();
        final stateStore = LocalSecurityStateStore(store: rawStore);

        final state = LocalSecurityStateV1(
          setupState: SetupStateV1.ready,
          pinVerifier: _verifier(),
          databaseKeyEnvelope: _envelope(KeyPurpose.databaseKey),
          audioKeyEnvelope: _envelope(KeyPurpose.audioKey),
        );

        await stateStore.write(state);
        expect(rawStore.payload, isNotNull);

        final restored = await stateStore.read();

        expect(restored, isNotNull);
        expect(restored!.setupState, SetupStateV1.ready);
        expect(restored.databaseKeyEnvelope!.purpose, KeyPurpose.databaseKey);
        expect(restored.audioKeyEnvelope!.purpose, KeyPurpose.audioKey);

        await stateStore.clear();
        expect(await stateStore.read(), isNull);
      },
    );
  });
}

PinVerifierV1 _verifier() {
  return PinVerifierV1(
    saltBase64: base64Encode(
      List<int>.generate(
        QuraniKeyManagement.saltBytes,
        (index) => index + 1,
        growable: false,
      ),
    ),
    verifierBase64: base64Encode(
      List<int>.filled(PinVerifierV1.verifierBytes, 7),
    ),
  );
}

KeyEnvelopeV1 _envelope(KeyPurpose purpose) {
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
      ivBase64: base64Encode(List<int>.filled(12, 3)),
      ciphertextBase64: base64Encode(List<int>.filled(48, 9)),
    ),
  );
}

final class _MemoryLocalSecurityStore implements LocalSecurityStore {
  Uint8List? payload;

  @override
  Future<void> clear() async {
    payload = null;
  }

  @override
  Future<Uint8List?> read() async {
    return payload == null ? null : Uint8List.fromList(payload!);
  }

  @override
  Future<void> write(Uint8List payload) async {
    this.payload = Uint8List.fromList(payload);
  }
}
