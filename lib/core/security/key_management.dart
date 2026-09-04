import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

enum KeyPurpose {
  databaseKey('DatabaseKey'),
  audioKey('AudioKey');

  const KeyPurpose(this.wireName);

  final String wireName;

  static KeyPurpose parse(String value) {
    return values.firstWhere(
      (purpose) => purpose.wireName == value,
      orElse: () => throw FormatException('Unsupported key purpose: $value'),
    );
  }
}

final class KdfParametersV1 {
  const KdfParametersV1({
    this.algorithm = 'argon2id',
    this.memoryKiB = 19456,
    this.iterations = 2,
    this.parallelism = 1,
    this.outputBytes = 32,
  });

  final String algorithm;
  final int memoryKiB;
  final int iterations;
  final int parallelism;
  final int outputBytes;

  Map<String, Object> toMap() {
    return <String, Object>{
      'algorithm': algorithm,
      'memoryKiB': memoryKiB,
      'iterations': iterations,
      'parallelism': parallelism,
      'outputBytes': outputBytes,
    };
  }

  factory KdfParametersV1.fromMap(Map<String, dynamic> map) {
    return KdfParametersV1(
      algorithm: map['algorithm'] as String,
      memoryKiB: map['memoryKiB'] as int,
      iterations: map['iterations'] as int,
      parallelism: map['parallelism'] as int,
      outputBytes: map['outputBytes'] as int,
    );
  }
}

final class KeystoreMasterKeyInfo {
  const KeystoreMasterKeyInfo({
    required this.alias,
    required this.aliasExists,
    required this.algorithm,
    required this.configuredKeySizeBits,
    required this.transformation,
    required this.encodedIsNull,
    required this.userAuthenticationRequired,
  });

  final String alias;
  final bool aliasExists;
  final String algorithm;
  final int configuredKeySizeBits;
  final String transformation;
  final bool encodedIsNull;
  final bool userAuthenticationRequired;
}

final class KeystoreOuterEnvelope {
  const KeystoreOuterEnvelope({
    required this.version,
    required this.alias,
    required this.algorithm,
    required this.ivBase64,
    required this.ciphertextBase64,
  });

  final int version;
  final String alias;
  final String algorithm;
  final String ivBase64;
  final String ciphertextBase64;

  Map<String, Object> toMap() {
    return <String, Object>{
      'version': version,
      'alias': alias,
      'algorithm': algorithm,
      'ivBase64': ivBase64,
      'ciphertextBase64': ciphertextBase64,
    };
  }

  factory KeystoreOuterEnvelope.fromMap(Map<String, dynamic> map) {
    return KeystoreOuterEnvelope(
      version: map['version'] as int,
      alias: map['alias'] as String,
      algorithm: map['algorithm'] as String,
      ivBase64: map['ivBase64'] as String,
      ciphertextBase64: map['ciphertextBase64'] as String,
    );
  }
}

final class KeyEnvelopeV1 {
  const KeyEnvelopeV1({
    required this.version,
    required this.purpose,
    required this.saltBase64,
    required this.kdf,
    required this.outer,
  });

  static const int supportedVersion = 1;

  final int version;
  final KeyPurpose purpose;
  final String saltBase64;
  final KdfParametersV1 kdf;
  final KeystoreOuterEnvelope outer;

  Map<String, Object> toMap() {
    return <String, Object>{
      'version': version,
      'purpose': purpose.wireName,
      'saltBase64': saltBase64,
      'kdf': kdf.toMap(),
      'outer': outer.toMap(),
    };
  }

  factory KeyEnvelopeV1.fromMap(Map<String, dynamic> map) {
    return KeyEnvelopeV1(
      version: map['version'] as int,
      purpose: KeyPurpose.parse(map['purpose'] as String),
      saltBase64: map['saltBase64'] as String,
      kdf: KdfParametersV1.fromMap(
        Map<String, dynamic>.from(map['kdf'] as Map),
      ),
      outer: KeystoreOuterEnvelope.fromMap(
        Map<String, dynamic>.from(map['outer'] as Map),
      ),
    );
  }
}

abstract interface class KeystorePlatformBridge {
  Future<KeystoreMasterKeyInfo> ensureMasterKey();

  Future<KeystoreOuterEnvelope> wrap({
    required Uint8List plaintext,
    required Uint8List aad,
  });

  Future<Uint8List> unwrap({
    required KeystoreOuterEnvelope envelope,
    required Uint8List aad,
  });
}

abstract interface class KeyManagement {
  Uint8List generateRandomKey();

  Uint8List generateSalt();

  Future<KeystoreMasterKeyInfo> ensureMasterKey();

  Future<KeyEnvelopeV1> wrapKey({
    required KeyPurpose purpose,
    required Uint8List rawKey,
    required String pin,
    Uint8List? salt,
  });

  Future<Uint8List> unwrapKey({
    required KeyEnvelopeV1 envelope,
    required String pin,
  });
}

final class QuraniKeyManagement implements KeyManagement {
  QuraniKeyManagement({required this._keystoreBridge, Random? secureRandom})
    : _secureRandom = secureRandom ?? Random.secure();

  static const int keyBytes = 32;
  static const int saltBytes = 16;
  static const String masterKeyAlias = 'QuraniMasterKey';
  static const String masterKeyAlgorithm = 'AES';
  static const String masterKeyTransformation = 'AES/GCM/NoPadding';
  static const int masterKeyBits = 256;
  static const KdfParametersV1 currentKdf = KdfParametersV1();

  final KeystorePlatformBridge _keystoreBridge;
  final Random _secureRandom;
  final AesGcm _innerCipher = AesGcm.with256bits();

  @override
  Uint8List generateRandomKey() => _randomBytes(keyBytes);

  @override
  Uint8List generateSalt() => _randomBytes(saltBytes);

  @override
  Future<KeystoreMasterKeyInfo> ensureMasterKey() async {
    final info = await _keystoreBridge.ensureMasterKey();

    if (!info.aliasExists ||
        info.alias != masterKeyAlias ||
        info.algorithm != masterKeyAlgorithm ||
        info.configuredKeySizeBits != masterKeyBits ||
        info.transformation != masterKeyTransformation ||
        !info.encodedIsNull ||
        info.userAuthenticationRequired) {
      throw StateError('Android Keystore master key metadata is invalid.');
    }

    return info;
  }

  @override
  Future<KeyEnvelopeV1> wrapKey({
    required KeyPurpose purpose,
    required Uint8List rawKey,
    required String pin,
    Uint8List? salt,
  }) async {
    _validateRawKey(rawKey);
    _validatePin(pin);

    final effectiveSalt = Uint8List.fromList(salt ?? generateSalt());
    _validateSalt(effectiveSalt);

    final pinKekBytes = await _derivePinKek(
      pin: pin,
      salt: effectiveSalt,
      kdf: currentKdf,
    );

    final innerBox = await _innerCipher.encrypt(
      rawKey,
      secretKey: SecretKey(pinKekBytes),
      aad: _innerAad(purpose),
    );

    final innerPayload = Uint8List.fromList(
      utf8.encode(
        jsonEncode(<String, Object>{
          'version': KeyEnvelopeV1.supportedVersion,
          'purpose': purpose.wireName,
          'algorithm': 'AES-256-GCM',
          'nonceBase64': base64Encode(innerBox.nonce),
          'ciphertextBase64': base64Encode(innerBox.cipherText),
          'macBase64': base64Encode(innerBox.mac.bytes),
        }),
      ),
    );

    final outer = await _keystoreBridge.wrap(
      plaintext: innerPayload,
      aad: _outerAad(purpose: purpose, salt: effectiveSalt, kdf: currentKdf),
    );

    _validateOuterEnvelope(outer);

    return KeyEnvelopeV1(
      version: KeyEnvelopeV1.supportedVersion,
      purpose: purpose,
      saltBase64: base64Encode(effectiveSalt),
      kdf: currentKdf,
      outer: outer,
    );
  }

  @override
  Future<Uint8List> unwrapKey({
    required KeyEnvelopeV1 envelope,
    required String pin,
  }) async {
    _validatePin(pin);
    _validateEnvelope(envelope);

    final salt = Uint8List.fromList(base64Decode(envelope.saltBase64));
    _validateSalt(salt);

    final innerPayload = await _keystoreBridge.unwrap(
      envelope: envelope.outer,
      aad: _outerAad(purpose: envelope.purpose, salt: salt, kdf: envelope.kdf),
    );

    final decoded = jsonDecode(utf8.decode(innerPayload));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid inner key envelope.');
    }

    if (decoded['version'] != KeyEnvelopeV1.supportedVersion ||
        decoded['purpose'] != envelope.purpose.wireName ||
        decoded['algorithm'] != 'AES-256-GCM') {
      throw StateError('Inner key envelope metadata mismatch.');
    }

    final innerBox = SecretBox(
      base64Decode(decoded['ciphertextBase64'] as String),
      nonce: base64Decode(decoded['nonceBase64'] as String),
      mac: Mac(base64Decode(decoded['macBase64'] as String)),
    );

    final pinKekBytes = await _derivePinKek(
      pin: pin,
      salt: salt,
      kdf: envelope.kdf,
    );

    final clearText = await _innerCipher.decrypt(
      innerBox,
      secretKey: SecretKey(pinKekBytes),
      aad: _innerAad(envelope.purpose),
    );

    if (clearText.length != keyBytes) {
      throw StateError('Unwrapped key is not 256-bit.');
    }

    return Uint8List.fromList(clearText);
  }

  Future<Uint8List> _derivePinKek({
    required String pin,
    required Uint8List salt,
    required KdfParametersV1 kdf,
  }) async {
    _validateSupportedKdf(kdf);

    final algorithm = Argon2id(
      memory: kdf.memoryKiB,
      iterations: kdf.iterations,
      parallelism: kdf.parallelism,
      hashLength: kdf.outputBytes,
    );

    final key = await algorithm.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );

    final bytes = await key.extractBytes();
    if (bytes.length != kdf.outputBytes) {
      throw StateError('Argon2id returned an unexpected output length.');
    }

    return Uint8List.fromList(bytes);
  }

  Uint8List _innerAad(KeyPurpose purpose) {
    return Uint8List.fromList(
      utf8.encode('qurani:key-envelope:v1:inner:${purpose.wireName}'),
    );
  }

  Uint8List _outerAad({
    required KeyPurpose purpose,
    required Uint8List salt,
    required KdfParametersV1 kdf,
  }) {
    return Uint8List.fromList(
      utf8.encode(
        'qurani:key-envelope:v1:outer:'
        '${purpose.wireName}:'
        '${kdf.algorithm}:'
        '${kdf.memoryKiB}:'
        '${kdf.iterations}:'
        '${kdf.parallelism}:'
        '${kdf.outputBytes}:'
        '${base64Encode(salt)}',
      ),
    );
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(
        length,
        (_) => _secureRandom.nextInt(256),
        growable: false,
      ),
    );
  }

  void _validateEnvelope(KeyEnvelopeV1 envelope) {
    if (envelope.version != KeyEnvelopeV1.supportedVersion) {
      throw StateError('Unsupported KeyEnvelope version: ${envelope.version}');
    }

    _validateSupportedKdf(envelope.kdf);
    _validateOuterEnvelope(envelope.outer);
  }

  void _validateSupportedKdf(KdfParametersV1 kdf) {
    if (kdf.algorithm != currentKdf.algorithm ||
        kdf.memoryKiB != currentKdf.memoryKiB ||
        kdf.iterations != currentKdf.iterations ||
        kdf.parallelism != currentKdf.parallelism ||
        kdf.outputBytes != currentKdf.outputBytes) {
      throw StateError('Unsupported KeyEnvelopeV1 KDF parameters.');
    }
  }

  void _validateOuterEnvelope(KeystoreOuterEnvelope outer) {
    if (outer.version != KeyEnvelopeV1.supportedVersion ||
        outer.alias != masterKeyAlias ||
        outer.algorithm != masterKeyTransformation ||
        outer.ivBase64.isEmpty ||
        outer.ciphertextBase64.isEmpty) {
      throw StateError('Invalid Android Keystore outer envelope.');
    }
  }

  void _validateRawKey(Uint8List rawKey) {
    if (rawKey.length != keyBytes) {
      throw ArgumentError.value(
        rawKey.length,
        'rawKey.length',
        'Expected exactly 32 bytes / 256 bits.',
      );
    }
  }

  void _validateSalt(Uint8List salt) {
    if (salt.length != saltBytes) {
      throw ArgumentError.value(
        salt.length,
        'salt.length',
        'Expected exactly 16 bytes.',
      );
    }
  }

  void _validatePin(String pin) {
    if (pin.isEmpty) {
      throw ArgumentError.value(pin, 'pin', 'PIN must not be empty.');
    }
  }
}
