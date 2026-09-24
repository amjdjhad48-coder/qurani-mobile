import 'package:flutter/services.dart';
import 'package:qurani/features/reports/data/verified_support_report_pdf_generator.dart';

enum SupportReportPdfSaveOutcome { saved, cancelled }

final class AndroidSupportReportPdfExternalActions {
  AndroidSupportReportPdfExternalActions({
    MethodChannel? externalSharingChannel,
    MethodChannel? safChannel,
  }) : _externalSharingChannel =
           externalSharingChannel ??
           const MethodChannel(externalSharingChannelName),
       _safChannel = safChannel ?? const MethodChannel(safChannelName);

  static const String externalSharingChannelName =
      'qurani/p0_07_external_sharing';
  static const String safChannelName = 'qurani/p0_06_saf';
  static const String pdfMimeType = 'application/pdf';

  final MethodChannel _externalSharingChannel;
  final MethodChannel _safChannel;

  Future<void> openPdf(VerifiedSupportReportPdf pdf) async {
    _validate(pdf);

    final raw = await _externalSharingChannel
        .invokeMethod<Object?>('openReportArtifact', <String, Object?>{
          'bytes': Uint8List.fromList(pdf.bytes),
          'sha256': pdf.sha256,
          'mimeType': pdfMimeType,
        });

    final result = _map(raw);
    final expectedCacheName = '${pdf.sha256}.pdf';

    if (result['launched'] != true ||
        result['action'] != 'android.intent.action.VIEW' ||
        result['mimeType'] != pdfMimeType ||
        result['sha256'] != pdf.sha256 ||
        result['scheme'] != 'content' ||
        result['fileName'] != expectedCacheName ||
        result['bytes'] != pdf.bytes.length) {
      throw StateError('Android PDF opener returned an invalid result.');
    }
  }

  Future<SupportReportPdfSaveOutcome> savePdf(
    VerifiedSupportReportPdf pdf,
  ) async {
    _validate(pdf);

    final raw = await _safChannel
        .invokeMethod<Object?>('saveBytes', <String, Object?>{
          'bytes': Uint8List.fromList(pdf.bytes),
          'suggestedName': pdf.fileName,
          'mimeType': pdfMimeType,
        });

    final result = _map(raw);
    final status = result['status']?.toString();

    if (status == 'cancelled') {
      if (result['suggestedName'] != pdf.fileName ||
          result['mimeType'] != pdfMimeType) {
        throw StateError('Android PDF SAF cancellation result is invalid.');
      }

      return SupportReportPdfSaveOutcome.cancelled;
    }

    if (status != 'saved') {
      throw StateError('Android PDF SAF returned an unexpected status.');
    }

    final sourceSha = result['sha256']?.toString().toLowerCase();
    final reopenedSha = result['reopenedSha256']?.toString().toLowerCase();

    if (result['suggestedName'] != pdf.fileName ||
        result['mimeType'] != pdfMimeType ||
        result['bytes'] != pdf.bytes.length ||
        result['reopenedBytes'] != pdf.bytes.length ||
        sourceSha != pdf.sha256 ||
        reopenedSha != pdf.sha256 ||
        result['roundTripMatches'] != true ||
        result['uri']?.toString().isEmpty != false) {
      throw StateError('Android PDF SAF round-trip proof is invalid.');
    }

    return SupportReportPdfSaveOutcome.saved;
  }

  Future<void> sharePdf(VerifiedSupportReportPdf pdf) async {
    _validate(pdf);

    final raw = await _externalSharingChannel
        .invokeMethod<Object?>('shareReportArtifact', <String, Object?>{
          'bytes': Uint8List.fromList(pdf.bytes),
          'sha256': pdf.sha256,
          'suggestedName': pdf.fileName,
          'mimeType': pdfMimeType,
        });

    final result = _map(raw);

    if (result['launched'] != true ||
        result['action'] != 'android.intent.action.SEND' ||
        result['mimeType'] != pdfMimeType ||
        result['sha256'] != pdf.sha256 ||
        result['scheme'] != 'content' ||
        result['fileName'] != pdf.fileName ||
        result['bytes'] != pdf.bytes.length ||
        result['chooser'] != true) {
      throw StateError(
        'Android PDF sharer returned an invalid chooser result.',
      );
    }
  }

  void _validate(VerifiedSupportReportPdf pdf) {
    if (pdf.bytes.isEmpty || pdf.sizeBytes != pdf.bytes.length) {
      throw StateError('Verified PDF bytes are empty or internally invalid.');
    }

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(pdf.sha256)) {
      throw StateError('Verified PDF exposes an invalid SHA-256 hash.');
    }

    final fileName = pdf.fileName.trim();

    if (fileName.isEmpty ||
        fileName.contains('/') ||
        fileName.contains(r'\') ||
        !fileName.toLowerCase().endsWith('.pdf')) {
      throw StateError('Verified PDF exposes an invalid file name.');
    }
  }
}

Map<String, Object?> _map(Object? raw) {
  if (raw is! Map) {
    throw const FormatException('Expected a map from the Android PDF bridge.');
  }

  return raw.map((key, value) => MapEntry(key.toString(), value));
}
