import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/pin_policy.dart';

final class PinVerifierV1 {
  const PinVerifierV1({
    this.version = supportedVersion,
    this.algorithm = algorithmName,
    required this.saltBase64,
    this.kdf = QuraniKeyManagement.currentKdf,
    required this.verifierBase64,
  });

  static const int supportedVersion = 1;
  static const String algorithmName = 'HMAC-SHA256';
  static const String verifierMessage = 'qurani:pin-verifier:v1';
  static const int verifierBytes = 32;

  final int version;
  final String algorithm;
  final String saltBase64;
  final KdfParametersV1 kdf;
  final String verifierBase64;

  Map<String, Object> toMap() {
    return <String, Object>{
      'version': version,
      'algorithm': algorithm,
      'saltBase64': saltBase64,
      'kdf': kdf.toMap(),
      'verifierBase64': verifierBase64,
    };
  }

  factory PinVerifierV1.fromMap(Map<String, dynamic> map) {
    return PinVerifierV1(
      version: map['version'] as int,
      algorithm: map['algorithm'] as String,
      saltBase64: map['saltBase64'] as String,
      kdf: KdfParametersV1.fromMap(
        Map<String, dynamic>.from(map['kdf'] as Map),
      ),
      verifierBase64: map['verifierBase64'] as String,
    );
  }

  void validate() {
    if (version != supportedVersion) {
      throw FormatException('Unsupported PinVerifier version: $version');
    }

    if (algorithm != algorithmName) {
      throw FormatException('Unsupported PinVerifier algorithm: $algorithm');
    }

    _validateKdf(kdf);

    final salt = _decodeBase64(saltBase64, fieldName: 'saltBase64');
    if (salt.length != QuraniKeyManagement.saltBytes) {
      throw const FormatException('PinVerifier salt must be exactly 16 bytes.');
    }

    final verifier = _decodeBase64(verifierBase64, fieldName: 'verifierBase64');
    if (verifier.length != verifierBytes) {
      throw const FormatException('PinVerifier HMAC must be exactly 32 bytes.');
    }
  }

  static Uint8List _decodeBase64(String value, {required String fieldName}) {
    try {
      return base64Decode(value);
    } on FormatException {
      throw FormatException('Invalid Base64 in PinVerifier.$fieldName.');
    }
  }

  static void _validateKdf(KdfParametersV1 kdf) {
    const approved = QuraniKeyManagement.currentKdf;

    if (kdf.algorithm != approved.algorithm ||
        kdf.memoryKiB != approved.memoryKiB ||
        kdf.iterations != approved.iterations ||
        kdf.parallelism != approved.parallelism ||
        kdf.outputBytes != approved.outputBytes) {
      throw const FormatException('Unsupported PinVerifierV1 KDF parameters.');
    }
  }
}

final class PinVerifierV1Service {
  PinVerifierV1Service({Random? secureRandom})
    : _secureRandom = secureRandom ?? Random.secure();

  final Random _secureRandom;
  final Hmac _hmac = Hmac.sha256();

  Future<PinVerifierV1> create({required String pin, Uint8List? salt}) async {
    if (!PinPolicy.isValid(pin)) {
      throw ArgumentError.value(
        pin,
        'pin',
        'PIN must satisfy the approved six-digit PIN policy.',
      );
    }

    final effectiveSalt = Uint8List.fromList(
      salt ?? _randomBytes(QuraniKeyManagement.saltBytes),
    );
    _validateSalt(effectiveSalt);

    final pinKek = await _derivePinKek(pin: pin, salt: effectiveSalt);

    try {
      final mac = await _hmac.calculateMac(
        utf8.encode(PinVerifierV1.verifierMessage),
        secretKey: SecretKey(pinKek),
      );

      if (mac.bytes.length != PinVerifierV1.verifierBytes) {
        throw StateError('HMAC-SHA256 did not produce 32 bytes.');
      }

      return PinVerifierV1(
        saltBase64: base64Encode(effectiveSalt),
        verifierBase64: base64Encode(mac.bytes),
      );
    } finally {
      pinKek.fillRange(0, pinKek.length, 0);
    }
  }

  Future<bool> verify({
    required String pin,
    required PinVerifierV1 verifier,
  }) async {
    _validatePinFormat(pin);
    verifier.validate();

    final salt = base64Decode(verifier.saltBase64);
    final expected = base64Decode(verifier.verifierBase64);

    final pinKek = await _derivePinKek(
      pin: pin,
      salt: Uint8List.fromList(salt),
    );

    try {
      final actual = await _hmac.calculateMac(
        utf8.encode(PinVerifierV1.verifierMessage),
        secretKey: SecretKey(pinKek),
      );

      return _constantTimeEquals(expected, actual.bytes);
    } finally {
      pinKek.fillRange(0, pinKek.length, 0);
    }
  }

  Future<Uint8List> _derivePinKek({
    required String pin,
    required Uint8List salt,
  }) async {
    _validateSalt(salt);

    const kdf = QuraniKeyManagement.currentKdf;
    final algorithm = Argon2id(
      memory: kdf.memoryKiB,
      parallelism: kdf.parallelism,
      iterations: kdf.iterations,
      hashLength: kdf.outputBytes,
    );

    final secretKey = await algorithm.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
    final bytes = await secretKey.extractBytes();

    if (bytes.length != kdf.outputBytes) {
      throw StateError('Argon2id returned an unexpected output length.');
    }

    return Uint8List.fromList(bytes);
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

  static void _validateSalt(Uint8List salt) {
    if (salt.length != QuraniKeyManagement.saltBytes) {
      throw ArgumentError.value(
        salt.length,
        'salt.length',
        'PinVerifierV1 salt must be exactly 16 bytes.',
      );
    }
  }

  static void _validatePinFormat(String pin) {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw ArgumentError.value(
        pin,
        'pin',
        'PIN verification requires exactly six decimal digits.',
      );
    }
  }

  static bool _constantTimeEquals(List<int> first, List<int> second) {
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
