import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qurani/p0_spikes/p0_03_keystore_pin_spike.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testPin = '246813';
  const wrongPin = '135790';

  final salt = Uint8List.fromList(
    List<int>.generate(
      P003SecuritySpike.pinSaltBytes,
      (index) => index + 1,
      growable: false,
    ),
  );

  testWidgets(
    'P0-03 proves Android Keystore, two-layer key wrapping, and Argon2id',
    (tester) async {
      final spike = P003SecuritySpike();

      await spike.deleteMasterKey();

      try {
        final keyInfo = await spike.ensureMasterKey();

        expect(keyInfo.aliasExists, isTrue);

        expect(keyInfo.algorithm, 'AES');

        expect(keyInfo.configuredKeySizeBits, 256);

        expect(keyInfo.transformation, 'AES/GCM/NoPadding');

        expect(
          keyInfo.encodedIsNull,
          isTrue,
          reason: 'Android Keystore master key must not expose raw key bytes.',
        );

        expect(keyInfo.userAuthenticationRequired, isFalse);

        debugPrint('P0_03_KEYSTORE_MASTER_KEY=PASS');

        debugPrint('P0_03_KEY_NON_EXPORTABLE=PASS');

        final benchmark = await spike.benchmarkPinKdf(
          pin: testPin,
          salt: salt,
          measuredRuns: 5,
        );

        expect(benchmark.runMilliseconds, hasLength(5));

        for (var index = 0; index < benchmark.runMilliseconds.length; index++) {
          debugPrint(
            'P0_03_ARGON2_RUN_'
            '${index + 1}_MS='
            '${benchmark.runMilliseconds[index]}',
          );
        }

        debugPrint(
          'P0_03_ARGON2_PARAMS='
          'memory_kib='
          '${P003SecuritySpike.argonMemoryKiB},'
          'iterations='
          '${P003SecuritySpike.argonIterations},'
          'parallelism='
          '${P003SecuritySpike.argonParallelism},'
          'output_bytes='
          '${P003SecuritySpike.pinKekBytes}',
        );

        debugPrint(
          'P0_03_ARGON2_MEDIAN_MS='
          '${benchmark.medianMilliseconds}',
        );

        debugPrint(
          'P0_03_ARGON2_MIN_MS='
          '${benchmark.minimumMilliseconds}',
        );

        debugPrint(
          'P0_03_ARGON2_MAX_MS='
          '${benchmark.maximumMilliseconds}',
        );

        debugPrint('P0_03_ARGON2_BENCHMARK=PASS');

        final databaseKey = spike.randomKey256();

        final audioKey = spike.randomKey256();

        expect(
          p003BytesEqual(databaseKey, audioKey),
          isFalse,
          reason: 'DatabaseKey and AudioKey must be independent random keys.',
        );

        debugPrint('P0_03_INDEPENDENT_RANDOM_KEYS=PASS');

        final databaseEnvelope = await spike.wrapKey(
          rawKey: databaseKey,
          pin: testPin,
          salt: salt,
          keyLabel: 'DatabaseKey',
        );

        final audioEnvelope = await spike.wrapKey(
          rawKey: audioKey,
          pin: testPin,
          salt: salt,
          keyLabel: 'AudioKey',
        );

        final recoveredDatabaseKey = await spike.unwrapKey(
          envelope: databaseEnvelope,
          pin: testPin,
          salt: salt,
        );

        final recoveredAudioKey = await spike.unwrapKey(
          envelope: audioEnvelope,
          pin: testPin,
          salt: salt,
        );

        expect(p003BytesEqual(databaseKey, recoveredDatabaseKey), isTrue);

        expect(p003BytesEqual(audioKey, recoveredAudioKey), isTrue);

        debugPrint('P0_03_DATABASE_KEY_ROUNDTRIP=PASS');

        debugPrint('P0_03_AUDIO_KEY_ROUNDTRIP=PASS');

        Object? wrongPinError;

        try {
          await spike.unwrapKey(
            envelope: databaseEnvelope,
            pin: wrongPin,
            salt: salt,
          );
        } catch (error) {
          wrongPinError = error;

          debugPrint(
            'P0_03_WRONG_PIN_ERROR='
            '${error.runtimeType}',
          );
        }

        expect(
          wrongPinError,
          isNotNull,
          reason:
              'Wrong PIN must fail the inner PinKEK authenticated decryption.',
        );

        debugPrint('P0_03_WRONG_PIN_FAILURE=PASS');

        final bridge = P003KeystoreBridge();

        final tamperAad = Uint8List.fromList(
          utf8.encode('qurani:p0-03:tamper-test'),
        );

        final outerProbe = await bridge.wrap(
          plaintext: Uint8List.fromList(<int>[1, 2, 3, 4, 5]),
          aad: tamperAad,
        );

        final tamperedCiphertext = Uint8List.fromList(
          base64Decode(outerProbe.ciphertextBase64),
        );

        if (tamperedCiphertext.isEmpty) {
          fail('Outer ciphertext unexpectedly empty.');
        }

        tamperedCiphertext[0] ^= 0x01;

        final tamperedEnvelope = P003OuterEnvelope(
          version: outerProbe.version,
          alias: outerProbe.alias,
          algorithm: outerProbe.algorithm,
          ivBase64: outerProbe.ivBase64,
          ciphertextBase64: base64Encode(tamperedCiphertext),
        );

        Object? tamperError;

        try {
          await bridge.unwrap(envelope: tamperedEnvelope, aad: tamperAad);
        } on PlatformException catch (error) {
          tamperError = error;

          debugPrint(
            'P0_03_OUTER_TAMPER_ERROR='
            '${error.code}',
          );
        }

        expect(
          tamperError,
          isNotNull,
          reason: 'Tampering with the Keystore AES-GCM envelope must fail.',
        );

        debugPrint('P0_03_OUTER_TAMPER_FAILURE=PASS');

        debugPrint('QURANI_P0_03_KEYSTORE_PIN_PROOF_OK');
      } finally {
        await spike.deleteMasterKey();
      }
    },
  );
}
