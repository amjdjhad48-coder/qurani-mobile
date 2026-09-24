import 'package:flutter/services.dart';
import 'package:qurani/features/reports/application/support_report_artifact_save_service.dart';

final class AndroidSupportReportArtifactSafSaver
    implements SupportReportArtifactExternalSaver {
  AndroidSupportReportArtifactSafSaver({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'qurani/p0_06_saf';
  static const String excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  final MethodChannel _channel;

  @override
  Future<SupportReportApprovedArtifactSaveOutcome> saveExcel({
    required List<int> bytes,
    required String sha256,
    required String suggestedName,
  }) async {
    final normalizedHash = sha256.trim().toLowerCase();
    final normalizedName = suggestedName.trim();

    if (bytes.isEmpty) {
      throw ArgumentError.value(
        bytes,
        'bytes',
        'Excel bytes must not be empty.',
      );
    }

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(normalizedHash)) {
      throw ArgumentError.value(
        sha256,
        'sha256',
        'Excel SHA-256 must be 64 hexadecimal characters.',
      );
    }

    if (normalizedName.isEmpty ||
        normalizedName.contains('/') ||
        normalizedName.contains(r'\') ||
        !normalizedName.toLowerCase().endsWith('.xlsx')) {
      throw ArgumentError.value(
        suggestedName,
        'suggestedName',
        'Excel suggested name must be a simple .xlsx file name.',
      );
    }

    final raw = await _channel
        .invokeMethod<Object?>('saveBytes', <String, Object>{
          'bytes': Uint8List.fromList(bytes),
          'suggestedName': normalizedName,
          'mimeType': excelMimeType,
        });

    final result = _stringKeyedMap(raw);
    final status = result['status'];

    if (result['suggestedName'] != normalizedName ||
        result['mimeType'] != excelMimeType) {
      throw StateError(
        'Android SAF saver returned mismatched request metadata.',
      );
    }

    if (status == 'cancelled') {
      return SupportReportApprovedArtifactSaveOutcome.cancelled;
    }

    if (status != 'saved') {
      throw StateError('Android SAF saver returned an unexpected status.');
    }

    final uriText = result['uri'];
    final savedBytes = result['bytes'];
    final reopenedBytes = result['reopenedBytes'];
    final sourceSha = result['sha256'];
    final reopenedSha = result['reopenedSha256'];
    final roundTripMatches = result['roundTripMatches'];

    if (uriText is! String ||
        Uri.tryParse(uriText)?.scheme != 'content' ||
        savedBytes != bytes.length ||
        reopenedBytes != bytes.length ||
        sourceSha is! String ||
        reopenedSha is! String ||
        sourceSha.toLowerCase() != normalizedHash ||
        reopenedSha.toLowerCase() != normalizedHash ||
        roundTripMatches != true) {
      throw StateError(
        'Android SAF saver did not prove an exact saved Excel round-trip.',
      );
    }

    return SupportReportApprovedArtifactSaveOutcome.saved;
  }
}

Map<String, Object?> _stringKeyedMap(Object? raw) {
  if (raw is! Map) {
    throw const FormatException('Expected a map from Android SAF saver.');
  }

  return raw.map((key, value) => MapEntry(key.toString(), value));
}
