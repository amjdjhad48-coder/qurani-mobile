import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/data/android_support_report_artifact_sharer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('qurani/report_artifact_share_test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const hash =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
  const name = 'qurani_weekly_2026-09-12_2026-09-16.xlsx';

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('report sharer sends verified bytes to ACTION_SEND chooser', () async {
    MethodCall? captured;

    messenger.setMockMethodCallHandler(channel, (call) async {
      captured = call;
      final args = Map<String, Object?>.from(call.arguments as Map);
      final bytes = args['bytes']! as Uint8List;

      return <String, Object?>{
        'launched': true,
        'action': 'android.intent.action.SEND',
        'mimeType': AndroidSupportReportArtifactExternalSharer.excelMimeType,
        'uri':
            'content://com.amjadjihad.qurani.p007.fileprovider/'
            'p0_07_share/$name',
        'authority': 'com.amjadjihad.qurani.p007.fileprovider',
        'scheme': 'content',
        'fileName': name,
        'bytes': bytes.length,
        'sha256': hash,
        'chooser': true,
      };
    });

    final sharer = AndroidSupportReportArtifactExternalSharer(channel: channel);

    await sharer.shareExcel(
      bytes: const <int>[1, 2, 3],
      sha256: hash,
      suggestedName: name,
    );

    expect(captured?.method, 'shareReportArtifact');

    final args = Map<String, Object?>.from(captured!.arguments as Map);
    expect(args['suggestedName'], name);
    expect(
      args['mimeType'],
      AndroidSupportReportArtifactExternalSharer.excelMimeType,
    );
    expect(args['bytes'], isA<Uint8List>());
    expect(args['sha256'], hash);
  });

  test(
    'invalid approved artifact hash is rejected before native share',
    () async {
      var calls = 0;

      messenger.setMockMethodCallHandler(channel, (call) async {
        calls += 1;
        return null;
      });

      final sharer = AndroidSupportReportArtifactExternalSharer(
        channel: channel,
      );

      await expectLater(
        sharer.shareExcel(
          bytes: const <int>[1, 2, 3],
          sha256: 'bad',
          suggestedName: name,
        ),
        throwsArgumentError,
      );

      expect(calls, 0);
    },
  );

  test(
    'native report share remains narrow and WhatsApp-capable via chooser',
    () async {
      final source = await File(
        'android/app/src/main/kotlin/com/amjadjihad/qurani/'
        'P007ExternalSharingBridge.kt',
      ).readAsString();
      final manifest = await File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsString();
      final paths = await File(
        'android/app/src/main/res/xml/p0_07_file_paths.xml',
      ).readAsString();

      expect(source, contains('"shareReportArtifact"'));
      expect(source, contains('Intent(Intent.ACTION_SEND)'));
      expect(source, contains('Intent.EXTRA_STREAM'));
      expect(source, contains('Intent.createChooser'));
      expect(source, contains('Intent.FLAG_GRANT_READ_URI_PERMISSION'));
      expect(source, contains('ClipData.newRawUri'));
      expect(source, contains('pendingReportArtifactFile = file'));
      expect(source, contains('pendingReportArtifactFile?.delete()'));
      expect(source, isNot(contains('setPackage("com.whatsapp")')));

      expect(manifest, contains(r'${applicationId}.p007.fileprovider'));
      expect(paths, contains('<cache-path'));
      expect(paths, contains('path="p0_07_share/"'));
      expect(paths, isNot(contains('<files-path')));
    },
  );

  test('mismatched native share proof is rejected', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      final args = Map<String, Object?>.from(call.arguments as Map);
      final bytes = args['bytes']! as Uint8List;

      return <String, Object?>{
        'launched': true,
        'action': 'android.intent.action.SEND',
        'mimeType': AndroidSupportReportArtifactExternalSharer.excelMimeType,
        'uri': 'content://test/$name',
        'authority': 'test',
        'scheme': 'content',
        'fileName': name,
        'bytes': bytes.length,
        'sha256':
            'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        'chooser': true,
      };
    });

    final sharer = AndroidSupportReportArtifactExternalSharer(channel: channel);

    await expectLater(
      sharer.shareExcel(
        bytes: const <int>[1, 2, 3],
        sha256: hash,
        suggestedName: name,
      ),
      throwsStateError,
    );
  });
}
