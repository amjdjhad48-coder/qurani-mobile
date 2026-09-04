import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qurani/core/security/key_management.dart';

final class AndroidKeystoreBridge implements KeystorePlatformBridge {
  AndroidKeystoreBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'qurani/security_keystore';

  final MethodChannel _channel;

  @override
  Future<KeystoreMasterKeyInfo> ensureMasterKey() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'ensureMasterKey',
    );

    if (result == null) {
      throw StateError('Android Keystore returned no master-key metadata.');
    }

    return KeystoreMasterKeyInfo(
      alias: result['alias'] as String,
      aliasExists: result['aliasExists'] as bool,
      algorithm: result['algorithm'] as String,
      configuredKeySizeBits: result['configuredKeySizeBits'] as int,
      transformation: result['transformation'] as String,
      encodedIsNull: result['encodedIsNull'] as bool,
      userAuthenticationRequired: result['userAuthenticationRequired'] as bool,
    );
  }

  @override
  Future<KeystoreOuterEnvelope> wrap({
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

    return KeystoreOuterEnvelope.fromMap(result);
  }

  @override
  Future<Uint8List> unwrap({
    required KeystoreOuterEnvelope envelope,
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
}
