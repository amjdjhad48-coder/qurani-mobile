import 'package:flutter/services.dart';
import 'package:qurani/features/reports/application/support_report_artifact_share_service.dart';

final class AndroidSupportReportArtifactExternalSharer
    implements SupportReportArtifactExternalSharer {
  AndroidSupportReportArtifactExternalSharer({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'qurani/p0_07_external_sharing';
  static const String excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  final MethodChannel _channel;

  @override
  Future<void> shareExcel({
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
        .invokeMethod<Object?>('shareReportArtifact', <String, Object?>{
          'bytes': Uint8List.fromList(bytes),
          'sha256': normalizedHash,
          'suggestedName': normalizedName,
          'mimeType': excelMimeType,
        });

    final result = _stringKeyedMap(raw);

    if (result['launched'] != true ||
        result['action'] != 'android.intent.action.SEND' ||
        result['mimeType'] != excelMimeType ||
        result['sha256'] != normalizedHash ||
        result['scheme'] != 'content' ||
        result['fileName'] != normalizedName ||
        result['bytes'] != bytes.length ||
        result['chooser'] != true) {
      throw StateError(
        'Android report artifact sharer returned an invalid chooser result.',
      );
    }
  }
}

Map<String, Object?> _stringKeyedMap(Object? raw) {
  if (raw is! Map) {
    throw const FormatException(
      'Expected a map from Android report artifact sharer.',
    );
  }

  return raw.map((key, value) => MapEntry(key.toString(), value));
}
