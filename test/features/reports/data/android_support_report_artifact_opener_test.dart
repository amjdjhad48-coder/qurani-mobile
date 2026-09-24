import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_opener.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('qurani/report_artifact_open_test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'Android opener sends verified bytes to ACTION_VIEW bridge contract',
    () async {
      MethodCall? captured;

      messenger.setMockMethodCallHandler(channel, (call) async {
        captured = call;
        final args = Map<String, Object?>.from(call.arguments as Map);

        return <String, Object?>{
          'launched': true,
          'action': 'android.intent.action.VIEW',
          'mimeType': AndroidSupportReportArtifactExternalOpener.excelMimeType,
          'sha256': args['sha256'],
          'scheme': 'content',
        };
      });

      final opener = AndroidSupportReportArtifactExternalOpener(
        channel: channel,
      );
      const hash =
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

      await opener.openExcel(bytes: const <int>[1, 2, 3], sha256: hash);

      expect(captured?.method, 'openReportArtifact');
      final args = Map<String, Object?>.from(captured!.arguments as Map);
      expect(args['sha256'], hash);
      expect(
        args['mimeType'],
        AndroidSupportReportArtifactExternalOpener.excelMimeType,
      );
      expect(args['bytes'], isA<Uint8List>());
      expect((args['bytes']! as Uint8List).toList(), <int>[1, 2, 3]);
    },
  );

  test(
    'Android opener rejects invalid hash before invoking native bridge',
    () async {
      var nativeCalls = 0;

      messenger.setMockMethodCallHandler(channel, (call) async {
        nativeCalls += 1;
        return null;
      });

      final opener = AndroidSupportReportArtifactExternalOpener(
        channel: channel,
      );

      await expectLater(
        opener.openExcel(bytes: const <int>[1], sha256: 'bad'),
        throwsArgumentError,
      );

      expect(nativeCalls, 0);
    },
  );

  test(
    'native report open remains limited to the dedicated cache FileProvider',
    () async {
      final kotlin = await File(
        'android/app/src/main/kotlin/com/amjadjihad/qurani/'
        'P007ExternalSharingBridge.kt',
      ).readAsString();
      final paths = await File(
        'android/app/src/main/res/xml/p0_07_file_paths.xml',
      ).readAsString();

      expect(kotlin, contains('"openReportArtifact"'));
      expect(kotlin, contains('Intent.ACTION_VIEW'));
      expect(kotlin, contains('FileProvider.getUriForFile'));
      expect(kotlin, contains('FLAG_GRANT_READ_URI_PERMISSION'));
      expect(kotlin, contains('SHARE_CACHE_DIRECTORY'));
      expect(kotlin, contains('reportArtifactPauseSeen'));

      expect(paths, contains('<cache-path'));
      expect(paths, contains('path="p0_07_share/"'));
      expect(paths, isNot(contains('<files-path')));
      expect(paths, isNot(contains('<root-path')));
      expect(paths, isNot(contains('<external-path')));
    },
  );

  test(
    'native report cache cleans stale process leftovers and pre-launch failures',
    () async {
      final kotlin = await File(
        'android/app/src/main/kotlin/com/amjadjihad/qurani/'
        'P007ExternalSharingBridge.kt',
      ).readAsString();

      final cleanupStart = kotlin.indexOf(
        'private fun cleanupStaleReportArtifactsOncePerProcess()',
      );
      final handleStart = kotlin.indexOf('fun handle(', cleanupStart);

      expect(cleanupStart, greaterThanOrEqualTo(0));
      expect(handleStart, greaterThan(cleanupStart));

      final startupCleanup = kotlin.substring(cleanupStart, handleStart);

      expect(startupCleanup, contains('reportArtifactStartupCleanupComplete'));
      expect(startupCleanup, contains('REPORT_ARTIFACT_EXTENSIONS.contains'));
      expect(
        startupCleanup,
        contains('Could not delete stale report cache artifact.'),
      );
      expect(startupCleanup, isNot(contains('deleteRecursively')));

      expect(kotlin, contains('@Volatile'));
      expect(
        kotlin,
        contains('private var reportArtifactStartupCleanupComplete = false'),
      );

      final preLaunchCleanupCatches = RegExp(
        r'catch \(error: Throwable\) \{\s*file\.delete\(\)\s*throw error\s*\}',
        multiLine: true,
      ).allMatches(kotlin).length;

      expect(preLaunchCleanupCatches, 2);
      expect(RegExp(r'file\.writeBytes\(bytes\)').allMatches(kotlin).length, 2);
    },
  );
}
