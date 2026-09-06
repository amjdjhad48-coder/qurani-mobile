import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const mainActivityPath =
      'android/app/src/main/kotlin/com/amjadjihad/qurani/MainActivity.kt';
  const manifestPath = 'android/app/src/main/AndroidManifest.xml';

  test('P2-11 applies FLAG_SECURE to the Android activity', () {
    final source = File(mainActivityPath).readAsStringSync();

    expect(
      source,
      contains('window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)'),
    );
    expect(source, contains('import android.view.WindowManager'));
  });

  test('P2-11 guards Android 13 recents screenshots with API 33 check', () {
    final source = File(mainActivityPath).readAsStringSync();

    final guardIndex = source.indexOf(
      'if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)',
    );
    final recentsIndex = source.indexOf('setRecentsScreenshotEnabled(false)');

    expect(guardIndex, greaterThanOrEqualTo(0));
    expect(recentsIndex, greaterThan(guardIndex));
    expect(source, contains('import android.os.Build'));
    expect(source, contains('import android.os.Bundle'));
  });

  test('P2-11 protects Recent Apps content without hiding the app task', () {
    final source = File(mainActivityPath).readAsStringSync();
    final manifest = File(manifestPath).readAsStringSync();

    expect(source, isNot(contains('excludeFromRecents')));
    expect(manifest, isNot(contains('android:excludeFromRecents="true"')));
  });
}
