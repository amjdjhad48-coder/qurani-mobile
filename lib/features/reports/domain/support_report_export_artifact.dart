enum SupportReportExportFormat {
  excel('excel'),
  pdf('pdf');

  const SupportReportExportFormat(this.storageValue);

  final String storageValue;
}

final class SupportReportExportArtifactMetadata {
  SupportReportExportArtifactMetadata({
    required this.format,
    required String internalPath,
    required String sha256,
    required this.templateVersion,
    required this.sizeBytes,
  }) : internalPath = internalPath.trim(),
       sha256 = sha256.trim().toLowerCase() {
    if (this.internalPath.isEmpty) {
      throw ArgumentError.value(
        internalPath,
        'internalPath',
        'Artifact internal path must not be empty.',
      );
    }

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(this.sha256)) {
      throw ArgumentError.value(
        sha256,
        'sha256',
        'Artifact SHA-256 must be a 64-character hexadecimal value.',
      );
    }

    if (templateVersion <= 0) {
      throw ArgumentError.value(
        templateVersion,
        'templateVersion',
        'Artifact template version must be positive.',
      );
    }

    if (sizeBytes <= 0) {
      throw ArgumentError.value(
        sizeBytes,
        'sizeBytes',
        'Artifact size must be positive.',
      );
    }
  }

  final SupportReportExportFormat format;
  final String internalPath;
  final String sha256;
  final int templateVersion;
  final int sizeBytes;
}
