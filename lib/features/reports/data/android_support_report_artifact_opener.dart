import 'package:flutter/services.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/support_report_artifact_open_service.dart';
import 'package:qurani/features/reports/data/support_report_artifact_file_store.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';

final class VerifiedSupportReportApprovedArtifactBytesReader
    implements SupportReportApprovedArtifactBytesReader {
  const VerifiedSupportReportApprovedArtifactBytesReader({
    required this.fileStore,
  });

  final SupportReportArtifactFileStore fileStore;

  @override
  Future<List<int>> readVerified({
    required SupportReportExportArtifactMetadata artifact,
    required SupportReportArtifactKind kind,
    required String sourceFingerprint,
    required int policyVersion,
  }) {
    return fileStore.readVerifiedPreparedBytes(
      PreparedPrimaryReportArtifact(
        kind: kind,
        sourceFingerprint: sourceFingerprint,
        policyVersion: policyVersion,
        templateVersion: artifact.templateVersion,
        internalPath: artifact.internalPath,
        sha256: artifact.sha256,
        sizeBytes: artifact.sizeBytes,
      ),
    );
  }
}

final class AndroidSupportReportArtifactExternalOpener
    implements SupportReportArtifactExternalOpener {
  AndroidSupportReportArtifactExternalOpener({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('qurani/p0_07_external_sharing');

  static const String excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  final MethodChannel _channel;

  @override
  Future<void> openExcel({
    required List<int> bytes,
    required String sha256,
  }) async {
    final normalizedHash = sha256.trim().toLowerCase();

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

    final raw = await _channel
        .invokeMethod<Object?>('openReportArtifact', <String, Object?>{
          'bytes': Uint8List.fromList(bytes),
          'sha256': normalizedHash,
          'mimeType': excelMimeType,
        });

    final result = _stringKeyedMap(raw);

    if (result['launched'] != true ||
        result['action'] != 'android.intent.action.VIEW' ||
        result['mimeType'] != excelMimeType ||
        result['sha256'] != normalizedHash ||
        result['scheme'] != 'content') {
      throw StateError(
        'Android report artifact opener returned an invalid launch result.',
      );
    }
  }
}

Map<String, Object?> _stringKeyedMap(Object? raw) {
  if (raw is! Map) {
    throw const FormatException(
      'Expected a map from Android report artifact opener.',
    );
  }

  return raw.map((key, value) => MapEntry(key.toString(), value));
}
