import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';

class P003KeystoreInfo {
  const P003KeystoreInfo({
    required this.alias,
    required this.aliasExists,
    required this.algorithm,
    required this.configuredKeySizeBits,
    required this.transformation,
    required this.encodedIsNull,
    required this.userAuthenticationRequired,
  });

  factory P003KeystoreInfo.fromMap(Map<String, dynamic> map) {
    return P003KeystoreInfo(
      alias: map['alias'] as String,
      aliasExists: map['aliasExists'] as bool,
      algorithm: map['algorithm'] as String,
      configuredKeySizeBits: map['configuredKeySizeBits'] as int,
      transformation: map['transformation'] as String,
      encodedIsNull: map['encodedIsNull'] as bool,
      userAuthenticationRequired: map['userAuthenticationRequired'] as bool,
    );
  }

  final String alias;
  final bool aliasExists;
  final String algorithm;
  final int configuredKeySizeBits;
  final String transformation;
  final bool encodedIsNull;
  final bool userAuthenticationRequired;
}

class P003OuterEnvelope {
  const P003OuterEnvelope({
    required this.version,
    required this.alias,
    required this.algorithm,
    required this.ivBase64,
    required this.ciphertextBase64,
  });

  factory P003OuterEnvelope.fromMap(Map<String, dynamic> map) {
    return P003OuterEnvelope(
      version: map['version'] as int,
      alias: map['alias'] as String,
      algorithm: map['algorithm'] as String,
      ivBase64: map['ivBase64'] as String,
      ciphertextBase64: map['ciphertextBase64'] as String,
    );
  }

  final int version;
  final String alias;
  final String algorithm;
  final String ivBase64;
  final String ciphertextBase64;
}

class P003TwoLayerEnvelope {
  const P003TwoLayerEnvelope({
    required this.version,
    required this.keyLabel,
    required this.outer,
  });

  final int version;
  final String keyLabel;
  final P003OuterEnvelope outer;
}

class P003ArgonBenchmark {
  const P003ArgonBenchmark({
    required this.runMilliseconds,
    required this.medianMilliseconds,
    required this.minimumMilliseconds,
    required this.maximumMilliseconds,
  });

  final List<int> runMilliseconds;
  final int medianMilliseconds;
  final int minimumMilliseconds;
  final int maximumMilliseconds;
}

class P003KeystoreBridge {
  static const MethodChannel _channel = MethodChannel('qurani/p0_03_keystore');

  Future<P003KeystoreInfo> ensureMasterKey() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'ensureMasterKey',
    );

    if (result == null) {
      throw StateError('Android Keystore returned no key metadata.');
    }

    return P003KeystoreInfo.fromMap(result);
  }

  Future<P003OuterEnvelope> wrap({
    required Uint8List plaintext,
    required Uint8List aad,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'wrap',
      <String, dynamic>{
        'plaintextBase64': base64Encode(plaintext),
        'aadBase64': base64Encode(aad),
      },
    );

    if (result == null) {
      throw StateError('Android Keystore returned no wrapped envelope.');
    }

    return P003OuterEnvelope.fromMap(result);
  }

  Future<Uint8List> unwrap({
    required P003OuterEnvelope envelope,
    required Uint8List aad,
  }) async {
    final result = await _channel
        .invokeMethod<String>('unwrap', <String, dynamic>{
          'ivBase64': envelope.ivBase64,
          'ciphertextBase64': envelope.ciphertextBase64,
          'aadBase64': base64Encode(aad),
        });

    if (result == null) {
      throw StateError('Android Keystore returned no unwrapped bytes.');
    }

    return Uint8List.fromList(base64Decode(result));
  }

  Future<void> deleteMasterKey() async {
    final deleted = await _channel.invokeMethod<bool>('deleteMasterKey');

    if (deleted != true) {
      throw StateError('Unable to delete P0-03 test master key.');
    }
  }
}

class P003SecuritySpike {
  P003SecuritySpike({P003KeystoreBridge? keystoreBridge})
    : _keystoreBridge = keystoreBridge ?? P003KeystoreBridge();

  static const int envelopeVersion = 1;

  static const int pinSaltBytes = 16;
  static const int pinKekBytes = 32;

  static const int argonMemoryKiB = 19 * 1024;

  static const int argonIterations = 2;
  static const int argonParallelism = 1;

  final P003KeystoreBridge _keystoreBridge;

  final AesGcm _innerCipher = AesGcm.with256bits();

  final Random _secureRandom = Random.secure();

  Argon2id get _argon2id {
    return Argon2id(
      memory: argonMemoryKiB,
      parallelism: argonParallelism,
      iterations: argonIterations,
      hashLength: pinKekBytes,
    );
  }

  Future<P003KeystoreInfo> ensureMasterKey() {
    return _keystoreBridge.ensureMasterKey();
  }

  Future<void> deleteMasterKey() {
    return _keystoreBridge.deleteMasterKey();
  }

  Uint8List randomKey256() {
    return Uint8List.fromList(
      List<int>.generate(
        32,
        (_) => _secureRandom.nextInt(256),
        growable: false,
      ),
    );
  }

  Future<Uint8List> derivePinKek({
    required String pin,
    required Uint8List salt,
  }) async {
    if (salt.length != pinSaltBytes) {
      throw ArgumentError.value(
        salt.length,
        'salt.length',
        'Expected exactly 16 bytes.',
      );
    }

    final derivedKey = await _argon2id.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );

    final bytes = await derivedKey.extractBytes();

    if (bytes.length != pinKekBytes) {
      throw StateError('Argon2id did not produce 32 bytes.');
    }

    return Uint8List.fromList(bytes);
  }

  Future<P003ArgonBenchmark> benchmarkPinKdf({
    required String pin,
    required Uint8List salt,
    int measuredRuns = 5,
  }) async {
    if (measuredRuns < 1) {
      throw ArgumentError.value(
        measuredRuns,
        'measuredRuns',
        'Must be at least one.',
      );
    }

    final warmup = await derivePinKek(pin: pin, salt: salt);

    final timings = <int>[];

    for (var index = 0; index < measuredRuns; index++) {
      final stopwatch = Stopwatch()..start();

      final derived = await derivePinKek(pin: pin, salt: salt);

      stopwatch.stop();

      if (!_bytesEqual(warmup, derived)) {
        throw StateError('Argon2id output changed for identical PIN and salt.');
      }

      timings.add(stopwatch.elapsedMilliseconds);
    }

    final sorted = List<int>.from(timings)..sort();

    final median = sorted[sorted.length ~/ 2];

    return P003ArgonBenchmark(
      runMilliseconds: List<int>.unmodifiable(timings),
      medianMilliseconds: median,
      minimumMilliseconds: sorted.first,
      maximumMilliseconds: sorted.last,
    );
  }

  Future<P003TwoLayerEnvelope> wrapKey({
    required Uint8List rawKey,
    required String pin,
    required Uint8List salt,
    required String keyLabel,
  }) async {
    if (rawKey.length != 32) {
      throw ArgumentError.value(
        rawKey.length,
        'rawKey.length',
        'Expected a 256-bit key.',
      );
    }

    final pinKekBytes = await derivePinKek(pin: pin, salt: salt);

    final pinKek = SecretKey(pinKekBytes);

    final innerAad = _innerAad(keyLabel);

    final innerBox = await _innerCipher.encrypt(
      rawKey,
      secretKey: pinKek,
      aad: innerAad,
    );

    final innerPayload = utf8.encode(
      jsonEncode(<String, dynamic>{
        'version': envelopeVersion,
        'keyLabel': keyLabel,
        'nonceBase64': base64Encode(innerBox.nonce),
        'ciphertextBase64': base64Encode(innerBox.cipherText),
        'macBase64': base64Encode(innerBox.mac.bytes),
      }),
    );

    final outer = await _keystoreBridge.wrap(
      plaintext: Uint8List.fromList(innerPayload),
      aad: _outerAad(keyLabel: keyLabel, salt: salt),
    );

    return P003TwoLayerEnvelope(
      version: envelopeVersion,
      keyLabel: keyLabel,
      outer: outer,
    );
  }

  Future<Uint8List> unwrapKey({
    required P003TwoLayerEnvelope envelope,
    required String pin,
    required Uint8List salt,
  }) async {
    if (envelope.version != envelopeVersion) {
      throw StateError('Unsupported P0-03 envelope version.');
    }

    final innerPayload = await _keystoreBridge.unwrap(
      envelope: envelope.outer,
      aad: _outerAad(keyLabel: envelope.keyLabel, salt: salt),
    );

    final decoded = jsonDecode(utf8.decode(innerPayload));

    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid inner key envelope.');
    }

    if (decoded['version'] != envelopeVersion ||
        decoded['keyLabel'] != envelope.keyLabel) {
      throw StateError('Inner envelope metadata mismatch.');
    }

    final innerBox = SecretBox(
      base64Decode(decoded['ciphertextBase64'] as String),
      nonce: base64Decode(decoded['nonceBase64'] as String),
      mac: Mac(base64Decode(decoded['macBase64'] as String)),
    );

    final pinKekBytes = await derivePinKek(pin: pin, salt: salt);

    final clearText = await _innerCipher.decrypt(
      innerBox,
      secretKey: SecretKey(pinKekBytes),
      aad: _innerAad(envelope.keyLabel),
    );

    if (clearText.length != 32) {
      throw StateError('Unwrapped key is not 256-bit.');
    }

    return Uint8List.fromList(clearText);
  }

  Uint8List _innerAad(String keyLabel) {
    return Uint8List.fromList(utf8.encode('qurani:p0-03:inner:v1:$keyLabel'));
  }

  Uint8List _outerAad({required String keyLabel, required Uint8List salt}) {
    return Uint8List.fromList(
      utf8.encode(
        'qurani:p0-03:outer:v1:'
        '$keyLabel:'
        '${base64Encode(salt)}:'
        '$argonMemoryKiB:'
        '$argonIterations:'
        '$argonParallelism:'
        '$pinKekBytes',
      ),
    );
  }
}

bool p003BytesEqual(List<int> first, List<int> second) {
  return _bytesEqual(first, second);
}

bool _bytesEqual(List<int> first, List<int> second) {
  if (first.length != second.length) {
    return false;
  }

  var difference = 0;

  for (var index = 0; index < first.length; index++) {
    difference |= first[index] ^ second[index];
  }

  return difference == 0;
}
