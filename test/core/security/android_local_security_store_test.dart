import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/android_local_security_store.dart';
import 'package:qurani/core/security/local_security_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('qurani/local_security_store');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('AndroidLocalSecurityStore implements LocalSecurityStore', () {
    final store = AndroidLocalSecurityStore(channel: channel);

    expect(store, isA<LocalSecurityStore>());
    expect(
      AndroidLocalSecurityStore.channelName,
      'qurani/local_security_store',
    );
  });

  test('read returns null when no local security payload exists', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'read');
      return null;
    });

    final store = AndroidLocalSecurityStore(channel: channel);

    await expectLater(store.read(), completion(isNull));
  });

  test('read decodes the native plaintext payload', () async {
    final expected = Uint8List.fromList(<int>[1, 2, 3, 200, 255]);

    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'read');
      return base64Encode(expected);
    });

    final store = AndroidLocalSecurityStore(channel: channel);
    final actual = await store.read();

    expect(actual, isNotNull);
    expect(actual, orderedEquals(expected));
  });

  test('read rejects an empty payload returned by native storage', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'read');
      return '';
    });

    final store = AndroidLocalSecurityStore(channel: channel);

    await expectLater(store.read(), throwsFormatException);
  });

  test('write sends base64 payload and never accepts empty data', () async {
    final expected = Uint8List.fromList(<int>[4, 5, 6, 240]);
    MethodCall? captured;

    messenger.setMockMethodCallHandler(channel, (call) async {
      captured = call;
      return null;
    });

    final store = AndroidLocalSecurityStore(channel: channel);

    await store.write(expected);

    expect(captured, isNotNull);
    expect(captured!.method, 'write');

    final arguments = Map<Object?, Object?>.from(captured!.arguments as Map);
    expect(
      base64Decode(arguments['payloadBase64']! as String),
      orderedEquals(expected),
    );

    await expectLater(store.write(Uint8List(0)), throwsArgumentError);
  });

  test('clear delegates deletion to the native atomic store', () async {
    var calls = 0;

    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'clear');
      calls += 1;
      return null;
    });

    final store = AndroidLocalSecurityStore(channel: channel);
    await store.clear();

    expect(calls, 1);
  });
}
