import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/pin_verifier_v1.dart';

void main() {
  final fixedSalt = Uint8List.fromList(
    List<int>.generate(
      QuraniKeyManagement.saltBytes,
      (index) => index + 1,
      growable: false,
    ),
  );

  group('PinVerifierV1', () {
    test(
      'uses the approved Argon2id metadata and HMAC-SHA256 contract',
      () async {
        final service = PinVerifierV1Service();

        final verifier = await service.create(pin: '482731', salt: fixedSalt);

        expect(verifier.version, PinVerifierV1.supportedVersion);
        expect(verifier.algorithm, PinVerifierV1.algorithmName);
        expect(verifier.saltBase64, base64Encode(fixedSalt));
        expect(verifier.kdf.algorithm, 'argon2id');
        expect(verifier.kdf.memoryKiB, 19456);
        expect(verifier.kdf.iterations, 2);
        expect(verifier.kdf.parallelism, 1);
        expect(verifier.kdf.outputBytes, 32);
        expect(
          base64Decode(verifier.verifierBase64),
          hasLength(PinVerifierV1.verifierBytes),
        );

        expect(await service.verify(pin: '482731', verifier: verifier), isTrue);
        expect(
          await service.verify(pin: '482732', verifier: verifier),
          isFalse,
        );
      },
    );

    test('is deterministic for the same PIN and dedicated salt', () async {
      final service = PinVerifierV1Service();

      final first = await service.create(pin: '482731', salt: fixedSalt);
      final second = await service.create(pin: '482731', salt: fixedSalt);

      expect(first.verifierBase64, second.verifierBase64);
    });

    test(
      'rejects weak PIN creation and malformed verification input',
      () async {
        final service = PinVerifierV1Service();

        await expectLater(
          service.create(pin: '123456', salt: fixedSalt),
          throwsArgumentError,
        );

        final verifier = await service.create(pin: '482731', salt: fixedSalt);

        await expectLater(
          service.verify(pin: '12345', verifier: verifier),
          throwsArgumentError,
        );
      },
    );

    test('rejects unsupported metadata before verification', () async {
      final service = PinVerifierV1Service();

      final valid = await service.create(pin: '482731', salt: fixedSalt);

      final unsupported = PinVerifierV1(
        version: 2,
        saltBase64: valid.saltBase64,
        verifierBase64: valid.verifierBase64,
      );

      await expectLater(
        service.verify(pin: '482731', verifier: unsupported),
        throwsFormatException,
      );
    });

    test('tampered verifier fails authentication comparison', () async {
      final service = PinVerifierV1Service();

      final valid = await service.create(pin: '482731', salt: fixedSalt);
      final tamperedBytes = base64Decode(valid.verifierBase64);
      tamperedBytes[0] ^= 1;

      final tampered = PinVerifierV1(
        saltBase64: valid.saltBase64,
        verifierBase64: base64Encode(tamperedBytes),
      );

      expect(await service.verify(pin: '482731', verifier: tampered), isFalse);
    });
  });
}
