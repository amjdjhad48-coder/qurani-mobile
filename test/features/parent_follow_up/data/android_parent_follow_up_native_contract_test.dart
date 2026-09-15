import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Package 6 Android parent follow up gateway', () {
    test('production methods coexist with P0 bridge', () {
      final source = File(
        'android/app/src/main/kotlin/'
        'com/amjadjihad/qurani/'
        'P007ExternalSharingBridge.kt',
      ).readAsStringSync();

      expect(source, contains('"shareWhatsAppText"'));
      expect(source, contains('"openSmsComposer"'));

      expect(source, contains('"openParentWhatsApp"'));
      expect(source, contains('"openParentSms"'));

      expect(source, contains('https://wa.me/'));
      expect(source, contains('appendQueryParameter("text", message)'));

      expect(source, contains('Intent.ACTION_SENDTO'));
      expect(source, contains('Uri.fromParts('));
      expect(source, contains('"smsto"'));
      expect(source, contains('putExtra("sms_body", message)'));
    });

    test('production bridge validates payload arguments', () {
      final source = File(
        'android/app/src/main/kotlin/'
        'com/amjadjihad/qurani/'
        'P007ExternalSharingBridge.kt',
      ).readAsStringSync();

      expect(source, contains('requireParentFollowUpRecipient'));
      expect(source, contains('requireParentFollowUpText'));
      expect(source, contains('Recipient must be a normalized E.164 number.'));
    });

    test('manifest requests no SMS contacts '
        'or broad package permission', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, isNot(contains('android.permission.SEND_SMS')));

      expect(manifest, isNot(contains('android.permission.READ_CONTACTS')));

      expect(manifest, isNot(contains('android.permission.WRITE_CONTACTS')));

      expect(
        manifest,
        isNot(contains('android.permission.QUERY_ALL_PACKAGES')),
      );
    });
  });
}
