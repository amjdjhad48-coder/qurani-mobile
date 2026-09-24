import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/support_report_artifact_save_service.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_saf_saver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('qurani/report_artifact_saf_save_test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const hash =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
  const name = 'qurani_weekly_2026-09-07_2026-09-13.xlsx';

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'SAF saver validates exact saved round-trip against approved hash',
    () async {
      MethodCall? captured;

      messenger.setMockMethodCallHandler(channel, (call) async {
        captured = call;
        final args = Map<String, Object?>.from(call.arguments as Map);
        final bytes = args['bytes']! as Uint8List;

        return <String, Object?>{
          'status': 'saved',
          'uri': 'content://test/primary%3ADownload%2F$name',
          'bytes': bytes.length,
          'reopenedBytes': bytes.length,
          'sha256': hash.toUpperCase(),
          'reopenedSha256': hash.toUpperCase(),
          'roundTripMatches': true,
          'suggestedName': args['suggestedName'],
          'mimeType': args['mimeType'],
        };
      });

      final saver = AndroidSupportReportArtifactSafSaver(channel: channel);

      final outcome = await saver.saveExcel(
        bytes: const <int>[1, 2, 3],
        sha256: hash,
        suggestedName: name,
      );

      expect(outcome, SupportReportApprovedArtifactSaveOutcome.saved);
      expect(captured?.method, 'saveBytes');

      final args = Map<String, Object?>.from(captured!.arguments as Map);
      expect(args['suggestedName'], name);
      expect(
        args['mimeType'],
        AndroidSupportReportArtifactSafSaver.excelMimeType,
      );
      expect(args['bytes'], isA<Uint8List>());
    },
  );

  test('SAF cancellation is a normal outcome', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = Map<String, Object?>.from(call.arguments as Map);

      return <String, Object?>{
        'status': 'cancelled',
        'suggestedName': args['suggestedName'],
        'mimeType': args['mimeType'],
      };
    });

    final saver = AndroidSupportReportArtifactSafSaver(channel: channel);

    final outcome = await saver.saveExcel(
      bytes: const <int>[1, 2, 3],
      sha256: hash,
      suggestedName: name,
    );

    expect(outcome, SupportReportApprovedArtifactSaveOutcome.cancelled);
  });

  test('SAF saved result with wrong reopened hash is rejected', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = Map<String, Object?>.from(call.arguments as Map);
      final bytes = args['bytes']! as Uint8List;

      return <String, Object?>{
        'status': 'saved',
        'uri': 'content://test/primary%3ADownload%2F$name',
        'bytes': bytes.length,
        'reopenedBytes': bytes.length,
        'sha256': hash.toUpperCase(),
        'reopenedSha256':
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        'roundTripMatches': true,
        'suggestedName': args['suggestedName'],
        'mimeType': args['mimeType'],
      };
    });

    final saver = AndroidSupportReportArtifactSafSaver(channel: channel);

    await expectLater(
      saver.saveExcel(
        bytes: const <int>[1, 2, 3],
        sha256: hash,
        suggestedName: name,
      ),
      throwsStateError,
    );
  });

  test(
    'production SAF remains ACTION_CREATE_DOCUMENT with read-back proof',
    () async {
      final bridge = await File(
        'android/app/src/main/kotlin/com/amjadjihad/qurani/P006SafBridge.kt',
      ).readAsString();
      final manifest = await File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsString();

      expect(bridge, contains('Intent.ACTION_CREATE_DOCUMENT'));
      expect(bridge, contains('Intent.CATEGORY_OPENABLE'));
      expect(bridge, contains('Intent.EXTRA_TITLE'));
      expect(bridge, contains('openOutputStream'));
      expect(bridge, contains('openInputStream'));
      expect(bridge, contains('"roundTripMatches"'));
      expect(bridge, contains('REQUEST_CREATE_DOCUMENT'));

      expect(manifest, isNot(contains('WRITE_EXTERNAL_STORAGE')));
      expect(manifest, isNot(contains('MANAGE_EXTERNAL_STORAGE')));
    },
  );
}
