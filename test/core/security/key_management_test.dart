import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/key_management.dart';

void main() {
  group('QuraniKeyManagement', () {
    test('keeps the approved Argon2id v1 parameters', () {
      const kdf = QuraniKeyManagement.currentKdf;

      expect(kdf.algorithm, 'argon2id');
      expect(kdf.memoryKiB, 19456);
      expect(kdf.iterations, 2);
      expect(kdf.parallelism, 1);
      expect(kdf.outputBytes, 32);
    });

    test('generates independent 256-bit data keys', () {
      final service = QuraniKeyManagement(
        keystoreBridge: _PassthroughKeystoreBridge(),
      );

      final first = service.generateRandomKey();
      final second = service.generateRandomKey();

      expect(first, hasLength(32));
      expect(second, hasLength(32));
      expect(first, isNot(equals(second)));
    });

    test('validates production QuraniMasterKey metadata', () async {
      final service = QuraniKeyManagement(
        keystoreBridge: _PassthroughKeystoreBridge(),
      );

      final info = await service.ensureMasterKey();

      expect(info.alias, 'QuraniMasterKey');
      expect(info.algorithm, 'AES');
      expect(info.configuredKeySizeBits, 256);
      expect(info.transformation, 'AES/GCM/NoPadding');
      expect(info.encodedIsNull, isTrue);
      expect(info.userAuthenticationRequired, isFalse);
    });

    test('DatabaseKey envelope round-trips with correct PIN', () async {
      final service = QuraniKeyManagement(
        keystoreBridge: _PassthroughKeystoreBridge(),
      );
      final rawKey = Uint8List.fromList(
        List<int>.generate(32, (index) => index),
      );
      final salt = Uint8List.fromList(
        List<int>.generate(16, (index) => index + 1),
      );

      final envelope = await service.wrapKey(
        purpose: KeyPurpose.databaseKey,
        rawKey: rawKey,
        pin: '246813',
        salt: salt,
      );

      final recovered = await service.unwrapKey(
        envelope: envelope,
        pin: '246813',
      );

      expect(recovered, rawKey);
      expect(envelope.purpose, KeyPurpose.databaseKey);
      expect(envelope.version, 1);
      expect(envelope.kdf.memoryKiB, 19456);
      expect(envelope.outer.alias, 'QuraniMasterKey');
    });

    test('wrong PIN fails authenticated inner decryption', () async {
      final service = QuraniKeyManagement(
        keystoreBridge: _PassthroughKeystoreBridge(),
      );
      final rawKey = Uint8List(32);
      final salt = Uint8List.fromList(
        List<int>.generate(16, (index) => index + 1),
      );

      final envelope = await service.wrapKey(
        purpose: KeyPurpose.databaseKey,
        rawKey: rawKey,
        pin: '246813',
        salt: salt,
      );

      await expectLater(
        service.unwrapKey(envelope: envelope, pin: '135790'),
        throwsA(anything),
      );
    });

    test(
      'KeyEnvelopeV1 map serialization is stable and round-trippable',
      () async {
        final service = QuraniKeyManagement(
          keystoreBridge: _PassthroughKeystoreBridge(),
        );
        final envelope = await service.wrapKey(
          purpose: KeyPurpose.audioKey,
          rawKey: Uint8List.fromList(
            List<int>.generate(32, (index) => 255 - index),
          ),
          pin: '246813',
          salt: Uint8List.fromList(
            List<int>.generate(16, (index) => index + 10),
          ),
        );

        final restored = KeyEnvelopeV1.fromMap(
          jsonDecode(jsonEncode(envelope.toMap())) as Map<String, dynamic>,
        );

        expect(restored.version, envelope.version);
        expect(restored.purpose, envelope.purpose);
        expect(restored.saltBase64, envelope.saltBase64);
        expect(restored.kdf.toMap(), envelope.kdf.toMap());
        expect(restored.outer.toMap(), envelope.outer.toMap());
      },
    );
  });
}

final class _PassthroughKeystoreBridge implements KeystorePlatformBridge {
  @override
  Future<KeystoreMasterKeyInfo> ensureMasterKey() async {
    return const KeystoreMasterKeyInfo(
      alias: 'QuraniMasterKey',
      aliasExists: true,
      algorithm: 'AES',
      configuredKeySizeBits: 256,
      transformation: 'AES/GCM/NoPadding',
      encodedIsNull: true,
      userAuthenticationRequired: false,
    );
  }

  @override
  Future<KeystoreOuterEnvelope> wrap({
    required Uint8List plaintext,
    required Uint8List aad,
  }) async {
    return KeystoreOuterEnvelope(
      version: 1,
      alias: 'QuraniMasterKey',
      algorithm: 'AES/GCM/NoPadding',
      ivBase64: base64Encode(List<int>.filled(12, 7)),
      ciphertextBase64: base64Encode(plaintext),
    );
  }

  @override
  Future<Uint8List> unwrap({
    required KeystoreOuterEnvelope envelope,
    required Uint8List aad,
  }) async {
    return Uint8List.fromList(base64Decode(envelope.ciphertextBase64));
  }
}
