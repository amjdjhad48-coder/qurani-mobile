import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:qurani/core/security/local_security_store.dart';

final class AndroidLocalSecurityStore implements LocalSecurityStore {
  AndroidLocalSecurityStore({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'qurani/local_security_store';

  final MethodChannel _channel;

  @override
  Future<Uint8List?> read() async {
    final payloadBase64 = await _channel.invokeMethod<String>('read');

    if (payloadBase64 == null) {
      return null;
    }

    final payload = base64Decode(payloadBase64);
    if (payload.isEmpty) {
      throw const FormatException(
        'LocalSecurityStore returned an empty encrypted payload.',
      );
    }

    return Uint8List.fromList(payload);
  }

  @override
  Future<void> write(Uint8List payload) async {
    if (payload.isEmpty) {
      throw ArgumentError.value(
        payload.length,
        'payload.length',
        'LocalSecurityStore payload must not be empty.',
      );
    }

    await _channel.invokeMethod<void>('write', <String, Object>{
      'payloadBase64': base64Encode(payload),
    });
  }

  @override
  Future<void> clear() {
    return _channel.invokeMethod<void>('clear');
  }
}
