import 'dart:convert';
import 'dart:typed_data';

import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/security/pin_verifier_v1.dart';

enum SetupStateV1 {
  preparing('preparing'),
  ready('ready');

  const SetupStateV1(this.wireName);

  final String wireName;

  static SetupStateV1 parse(String value) {
    return values.firstWhere(
      (state) => state.wireName == value,
      orElse: () => throw FormatException('Unsupported setup state: $value'),
    );
  }
}

final class LocalSecurityStateV1 {
  const LocalSecurityStateV1({
    this.version = supportedVersion,
    required this.setupState,
    this.pinVerifier,
    this.failedAttemptCount = 0,
    this.lockedUntilUtc,
    this.databaseKeyEnvelope,
    this.audioKeyEnvelope,
  });

  static const int supportedVersion = 1;

  final int version;
  final SetupStateV1 setupState;
  final PinVerifierV1? pinVerifier;
  final int failedAttemptCount;
  final DateTime? lockedUntilUtc;
  final KeyEnvelopeV1? databaseKeyEnvelope;
  final KeyEnvelopeV1? audioKeyEnvelope;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'version': version,
      'setupState': setupState.wireName,
      'pinVerifier': pinVerifier?.toMap(),
      'failedAttemptCount': failedAttemptCount,
      'lockedUntilUtc': lockedUntilUtc?.toIso8601String(),
      'databaseKeyEnvelope': databaseKeyEnvelope?.toMap(),
      'audioKeyEnvelope': audioKeyEnvelope?.toMap(),
    };
  }

  factory LocalSecurityStateV1.fromMap(Map<String, dynamic> map) {
    final lockedUntilText = map['lockedUntilUtc'] as String?;

    return LocalSecurityStateV1(
      version: map['version'] as int,
      setupState: SetupStateV1.parse(map['setupState'] as String),
      pinVerifier: map['pinVerifier'] == null
          ? null
          : PinVerifierV1.fromMap(
              Map<String, dynamic>.from(map['pinVerifier'] as Map),
            ),
      failedAttemptCount: map['failedAttemptCount'] as int,
      lockedUntilUtc: lockedUntilText == null
          ? null
          : DateTime.parse(lockedUntilText),
      databaseKeyEnvelope: map['databaseKeyEnvelope'] == null
          ? null
          : KeyEnvelopeV1.fromMap(
              Map<String, dynamic>.from(map['databaseKeyEnvelope'] as Map),
            ),
      audioKeyEnvelope: map['audioKeyEnvelope'] == null
          ? null
          : KeyEnvelopeV1.fromMap(
              Map<String, dynamic>.from(map['audioKeyEnvelope'] as Map),
            ),
    );
  }

  void validate() {
    if (version != supportedVersion) {
      throw FormatException('Unsupported LocalSecurityState version: $version');
    }

    if (failedAttemptCount < 0) {
      throw const FormatException(
        'failedAttemptCount must be zero or greater.',
      );
    }

    if (lockedUntilUtc != null && !lockedUntilUtc!.isUtc) {
      throw const FormatException('lockedUntilUtc must be a UTC DateTime.');
    }

    pinVerifier?.validate();

    if (databaseKeyEnvelope != null) {
      _validateEnvelope(
        databaseKeyEnvelope!,
        expectedPurpose: KeyPurpose.databaseKey,
      );
    }

    if (audioKeyEnvelope != null) {
      _validateEnvelope(
        audioKeyEnvelope!,
        expectedPurpose: KeyPurpose.audioKey,
      );
    }

    if (setupState == SetupStateV1.ready) {
      if (pinVerifier == null ||
          databaseKeyEnvelope == null ||
          audioKeyEnvelope == null) {
        throw const FormatException(
          'Ready LocalSecurityStateV1 requires PIN verifier and both key envelopes.',
        );
      }
    }
  }

  static void _validateEnvelope(
    KeyEnvelopeV1 envelope, {
    required KeyPurpose expectedPurpose,
  }) {
    if (envelope.version != KeyEnvelopeV1.supportedVersion) {
      throw const FormatException(
        'Unsupported KeyEnvelope version in LocalSecurityStateV1.',
      );
    }

    if (envelope.purpose != expectedPurpose) {
      throw FormatException(
        'Unexpected KeyEnvelope purpose: ${envelope.purpose.wireName}',
      );
    }

    final salt = _decodeBase64(
      envelope.saltBase64,
      fieldName: '${expectedPurpose.wireName}.saltBase64',
    );
    if (salt.length != QuraniKeyManagement.saltBytes) {
      throw const FormatException('KeyEnvelope salt must be exactly 16 bytes.');
    }

    const approvedKdf = QuraniKeyManagement.currentKdf;
    final kdf = envelope.kdf;
    if (kdf.algorithm != approvedKdf.algorithm ||
        kdf.memoryKiB != approvedKdf.memoryKiB ||
        kdf.iterations != approvedKdf.iterations ||
        kdf.parallelism != approvedKdf.parallelism ||
        kdf.outputBytes != approvedKdf.outputBytes) {
      throw const FormatException(
        'Unsupported KeyEnvelope KDF in LocalSecurityStateV1.',
      );
    }

    final outer = envelope.outer;
    if (outer.version != KeyEnvelopeV1.supportedVersion ||
        outer.alias != QuraniKeyManagement.masterKeyAlias ||
        outer.algorithm != QuraniKeyManagement.masterKeyTransformation ||
        outer.ivBase64.isEmpty ||
        outer.ciphertextBase64.isEmpty) {
      throw const FormatException(
        'Invalid KeyEnvelope outer metadata in LocalSecurityStateV1.',
      );
    }

    _decodeBase64(
      outer.ivBase64,
      fieldName: '${expectedPurpose.wireName}.outer.ivBase64',
    );
    _decodeBase64(
      outer.ciphertextBase64,
      fieldName: '${expectedPurpose.wireName}.outer.ciphertextBase64',
    );
  }

  static Uint8List _decodeBase64(String value, {required String fieldName}) {
    try {
      return base64Decode(value);
    } on FormatException {
      throw FormatException(
        'Invalid Base64 in LocalSecurityStateV1.$fieldName.',
      );
    }
  }
}

final class LocalSecurityStateV1Codec {
  const LocalSecurityStateV1Codec();

  Uint8List encode(LocalSecurityStateV1 state) {
    state.validate();

    return Uint8List.fromList(utf8.encode(jsonEncode(state.toMap())));
  }

  LocalSecurityStateV1 decode(Uint8List payload) {
    if (payload.isEmpty) {
      throw const FormatException(
        'LocalSecurityStateV1 payload must not be empty.',
      );
    }

    final decoded = jsonDecode(utf8.decode(payload));
    if (decoded is! Map) {
      throw const FormatException(
        'LocalSecurityStateV1 payload must be a JSON object.',
      );
    }

    final state = LocalSecurityStateV1.fromMap(
      Map<String, dynamic>.from(decoded),
    );
    state.validate();

    return state;
  }
}
