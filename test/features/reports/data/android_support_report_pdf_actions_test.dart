import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/android_support_report_pdf_actions.dart';
import 'package:qurani/features/reports/data/verified_support_report_pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const externalChannel = MethodChannel('qurani/pdf_external_actions_test');
  const safChannel = MethodChannel('qurani/pdf_saf_actions_test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() async {
    messenger.setMockMethodCallHandler(externalChannel, null);
    messenger.setMockMethodCallHandler(safChannel, null);
  });

  test('open PDF passes verified bytes through ACTION_VIEW contract', () async {
    MethodCall? captured;

    messenger.setMockMethodCallHandler(externalChannel, (call) async {
      captured = call;
      final args = Map<String, Object?>.from(call.arguments as Map);
      final bytes = args['bytes']! as Uint8List;

      return <String, Object?>{
        'launched': true,
        'action': 'android.intent.action.VIEW',
        'mimeType': AndroidSupportReportPdfExternalActions.pdfMimeType,
        'scheme': 'content',
        'fileName': '$_hash.pdf',
        'bytes': bytes.length,
        'sha256': _hash,
      };
    });

    final actions = AndroidSupportReportPdfExternalActions(
      externalSharingChannel: externalChannel,
      safChannel: safChannel,
    );

    await actions.openPdf(_pdf());

    expect(captured?.method, 'openReportArtifact');
    final args = Map<String, Object?>.from(captured!.arguments as Map);
    expect(args['mimeType'], 'application/pdf');
    expect(args['sha256'], _hash);
    expect(args['bytes'], isA<Uint8List>());
  });

  test('save PDF uses generic SAF and validates reopened hash', () async {
    MethodCall? captured;

    messenger.setMockMethodCallHandler(safChannel, (call) async {
      captured = call;
      final args = Map<String, Object?>.from(call.arguments as Map);
      final bytes = args['bytes']! as Uint8List;

      return <String, Object?>{
        'status': 'saved',
        'uri': 'content://documents/qurani-weekly.pdf',
        'bytes': bytes.length,
        'reopenedBytes': bytes.length,
        'sha256': _hash.toUpperCase(),
        'reopenedSha256': _hash.toUpperCase(),
        'roundTripMatches': true,
        'suggestedName': _fileName,
        'mimeType': 'application/pdf',
      };
    });

    final actions = AndroidSupportReportPdfExternalActions(
      externalSharingChannel: externalChannel,
      safChannel: safChannel,
    );

    final outcome = await actions.savePdf(_pdf());

    expect(outcome, SupportReportPdfSaveOutcome.saved);
    expect(captured?.method, 'saveBytes');
    final args = Map<String, Object?>.from(captured!.arguments as Map);
    expect(args['suggestedName'], _fileName);
    expect(args['mimeType'], 'application/pdf');
  });

  test('PDF SAF cancellation is a normal outcome', () async {
    messenger.setMockMethodCallHandler(safChannel, (call) async {
      return <String, Object?>{
        'status': 'cancelled',
        'suggestedName': _fileName,
        'mimeType': 'application/pdf',
      };
    });

    final actions = AndroidSupportReportPdfExternalActions(
      externalSharingChannel: externalChannel,
      safChannel: safChannel,
    );

    expect(
      await actions.savePdf(_pdf()),
      SupportReportPdfSaveOutcome.cancelled,
    );
  });

  test('share PDF passes verified bytes through ACTION_SEND chooser', () async {
    MethodCall? captured;

    messenger.setMockMethodCallHandler(externalChannel, (call) async {
      captured = call;
      final args = Map<String, Object?>.from(call.arguments as Map);
      final bytes = args['bytes']! as Uint8List;

      return <String, Object?>{
        'launched': true,
        'action': 'android.intent.action.SEND',
        'mimeType': 'application/pdf',
        'scheme': 'content',
        'fileName': _fileName,
        'bytes': bytes.length,
        'sha256': _hash,
        'chooser': true,
      };
    });

    final actions = AndroidSupportReportPdfExternalActions(
      externalSharingChannel: externalChannel,
      safChannel: safChannel,
    );

    await actions.sharePdf(_pdf());

    expect(captured?.method, 'shareReportArtifact');
    final args = Map<String, Object?>.from(captured!.arguments as Map);
    expect(args['suggestedName'], _fileName);
    expect(args['mimeType'], 'application/pdf');
  });

  test(
    'native report cache accepts only Excel or PDF MIME-extension pairs',
    () async {
      final source = await File(
        'android/app/src/main/kotlin/com/amjadjihad/qurani/'
        'P007ExternalSharingBridge.kt',
      ).readAsString();

      expect(source, contains('REPORT_PDF_MIME_TYPE'));
      expect(source, contains('"application/pdf"'));
      expect(source, contains('REPORT_ARTIFACT_EXTENSIONS'));
      expect(source, contains('"xlsx", "pdf"'));
      expect(source, contains(r'"$expectedSha256.$extension"'));
      expect(source, contains(r'suggestedName.endsWith(".$extension"'));
      expect(source, contains('Intent(Intent.ACTION_VIEW)'));
      expect(source, contains('Intent(Intent.ACTION_SEND)'));
      expect(source, contains('pendingReportArtifactFile?.delete()'));
    },
  );

  test('invalid PDF filename fails before platform invocation', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(externalChannel, (call) async {
      calls += 1;
      return null;
    });

    final actions = AndroidSupportReportPdfExternalActions(
      externalSharingChannel: externalChannel,
      safChannel: safChannel,
    );

    await expectLater(
      actions.sharePdf(_pdf(fileName: '../bad.pdf')),
      throwsStateError,
    );

    expect(calls, 0);
  });
}

const _hash =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
const _fileName = 'qurani_weekly_2026-09-12_2026-09-16.pdf';

VerifiedSupportReportPdf _pdf({String fileName = _fileName}) {
  return VerifiedSupportReportPdf(
    kind: SupportReportArtifactKind.weekly,
    fileName: fileName,
    sourceFingerprint: 'approved-source',
    templateVersion: 1,
    sha256: _hash,
    bytes: const <int>[37, 80, 68, 70, 45, 49, 46, 55, 10, 37, 37, 69, 79, 70],
  );
}
