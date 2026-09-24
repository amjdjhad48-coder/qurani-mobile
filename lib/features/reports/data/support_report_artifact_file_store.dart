import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_generator.dart';

final class SupportReportArtifactFileStore
    implements
        PreparedPrimaryReportArtifactVerifier,
        SupportReportArtifactFileCleanup {
  const SupportReportArtifactFileStore({
    required Directory applicationSupportDirectory,
  }) : this._(applicationSupportDirectory);

  const SupportReportArtifactFileStore._(this._applicationSupportDirectory);

  static const String artifactsDirectoryName = 'report_artifacts';

  final Directory _applicationSupportDirectory;

  Future<PreparedPrimaryReportArtifact> stageVerifiedExcel({
    required VerifiedSupportReportExcel excel,
    required int policyVersion,
  }) async {
    if (policyVersion <= 0) {
      throw ArgumentError.value(
        policyVersion,
        'policyVersion',
        'Policy version must be positive.',
      );
    }

    final expectedHash = excel.sha256.trim().toLowerCase();

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(expectedHash)) {
      throw StateError('Verified Excel exposes an invalid SHA-256 hash.');
    }

    if (excel.bytes.isEmpty || excel.sizeBytes != excel.bytes.length) {
      throw StateError('Verified Excel bytes are empty or internally invalid.');
    }

    final calculatedHash = await _sha256(excel.bytes);

    if (calculatedHash != expectedHash) {
      throw StateError(
        'Verified Excel bytes no longer match their declared SHA-256 hash.',
      );
    }

    final artifactsDirectory = Directory(
      '${_applicationSupportDirectory.path}'
      '${Platform.pathSeparator}'
      '$artifactsDirectoryName',
    );

    if (!await artifactsDirectory.exists()) {
      await artifactsDirectory.create(recursive: true);
    }

    final fileName = '$expectedHash.xlsx';
    final relativePath = '$artifactsDirectoryName/$fileName';
    final finalFile = File(
      '${artifactsDirectory.path}${Platform.pathSeparator}$fileName',
    );
    final stagingFile = File(
      '${finalFile.path}.staging.${DateTime.now().microsecondsSinceEpoch}',
    );

    try {
      await stagingFile.writeAsBytes(excel.bytes, flush: true);

      final stagedVerification = await _verifyFile(
        file: stagingFile,
        expectedHash: expectedHash,
        expectedSize: excel.sizeBytes,
      );

      if (!stagedVerification.isValid) {
        throw StateError(
          stagedVerification.reason ??
              'Staged Excel failed file-integrity verification.',
        );
      }

      if (await finalFile.exists()) {
        final currentVerification = await _verifyFile(
          file: finalFile,
          expectedHash: expectedHash,
          expectedSize: excel.sizeBytes,
        );

        if (!currentVerification.isValid) {
          throw StateError(
            'A content-addressed report artifact already exists with '
            'unexpected bytes.',
          );
        }

        await stagingFile.delete();
      } else {
        await stagingFile.rename(finalFile.path);
      }

      final publishedVerification = await _verifyFile(
        file: finalFile,
        expectedHash: expectedHash,
        expectedSize: excel.sizeBytes,
      );

      if (!publishedVerification.isValid) {
        throw StateError(
          publishedVerification.reason ??
              'Published Excel failed file-integrity verification.',
        );
      }

      return PreparedPrimaryReportArtifact(
        kind: excel.kind,
        sourceFingerprint: excel.sourceFingerprint,
        policyVersion: policyVersion,
        templateVersion: excel.templateVersion,
        internalPath: relativePath,
        sha256: expectedHash,
        sizeBytes: excel.sizeBytes,
      );
    } catch (_) {
      if (await stagingFile.exists()) {
        await stagingFile.delete();
      }

      rethrow;
    }
  }

  Future<List<int>> readVerifiedPreparedBytes(
    PreparedPrimaryReportArtifact artifact,
  ) async {
    final expectedRelativePath =
        '$artifactsDirectoryName/${artifact.sha256}.xlsx';

    if (artifact.internalPath != expectedRelativePath) {
      throw StateError(
        'Prepared Excel artifact uses an unexpected private-storage path.',
      );
    }

    final file = File(
      '${_applicationSupportDirectory.path}'
      '${Platform.pathSeparator}'
      '${artifact.internalPath.replaceAll('/', Platform.pathSeparator)}',
    );

    if (!await file.exists()) {
      throw StateError('Prepared Excel artifact file does not exist.');
    }

    final stat = await file.stat();

    if (stat.type != FileSystemEntityType.file ||
        stat.size != artifact.sizeBytes) {
      throw StateError(
        'Prepared Excel artifact file size does not match metadata.',
      );
    }

    final bytes = await file.readAsBytes();

    if (bytes.length != artifact.sizeBytes) {
      throw StateError(
        'Prepared Excel artifact bytes do not match metadata size.',
      );
    }

    final actualHash = await _sha256(bytes);

    if (actualHash != artifact.sha256) {
      throw StateError(
        'Prepared Excel artifact SHA-256 does not match metadata.',
      );
    }

    return List<int>.unmodifiable(bytes);
  }

  @override
  Future<PreparedPrimaryReportArtifactVerification> verifyPrepared(
    PreparedPrimaryReportArtifact artifact,
  ) async {
    final expectedRelativePath =
        '$artifactsDirectoryName/${artifact.sha256}.xlsx';

    if (artifact.internalPath != expectedRelativePath) {
      return const PreparedPrimaryReportArtifactVerification.invalid(
        reason:
            'Prepared Excel artifact uses an unexpected private-storage path.',
      );
    }

    final file = File(
      '${_applicationSupportDirectory.path}'
      '${Platform.pathSeparator}'
      '${artifact.internalPath.replaceAll('/', Platform.pathSeparator)}',
    );

    return _verifyFile(
      file: file,
      expectedHash: artifact.sha256,
      expectedSize: artifact.sizeBytes,
    );
  }

  @override
  Future<bool> deleteArtifactIfExists({
    required String internalPath,
    required String sha256,
  }) async {
    final normalizedHash = sha256.trim().toLowerCase();

    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(normalizedHash)) {
      throw ArgumentError.value(
        sha256,
        'sha256',
        'Artifact SHA-256 must be a 64-character hexadecimal value.',
      );
    }

    final normalizedPath = internalPath.trim();
    final expectedRelativePath = '$artifactsDirectoryName/$normalizedHash.xlsx';

    if (normalizedPath != expectedRelativePath) {
      throw ArgumentError.value(
        internalPath,
        'internalPath',
        'Artifact path is not the canonical private Excel path.',
      );
    }

    final file = File(
      '${_applicationSupportDirectory.path}'
      '${Platform.pathSeparator}'
      '${normalizedPath.replaceAll('/', Platform.pathSeparator)}',
    );
    final type = await FileSystemEntity.type(file.path, followLinks: false);

    if (type == FileSystemEntityType.notFound) {
      return false;
    }

    if (type != FileSystemEntityType.file) {
      throw StateError(
        'Canonical report artifact path does not resolve to a regular file.',
      );
    }

    await file.delete();
    return true;
  }

  @override
  Future<int> cleanupUnreferencedArtifacts(
    Set<String> referencedInternalPaths,
  ) async {
    final artifactsDirectory = Directory(
      '${_applicationSupportDirectory.path}'
      '${Platform.pathSeparator}'
      '$artifactsDirectoryName',
    );
    final directoryType = await FileSystemEntity.type(
      artifactsDirectory.path,
      followLinks: false,
    );

    if (directoryType == FileSystemEntityType.notFound) {
      return 0;
    }

    if (directoryType != FileSystemEntityType.directory) {
      throw StateError(
        'Report artifacts path does not resolve to a regular directory.',
      );
    }

    final referenced = referencedInternalPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toSet();

    final canonicalPattern = RegExp(r'^[0-9a-f]{64}\.xlsx$');
    final stagingPattern = RegExp(r'^[0-9a-f]{64}\.xlsx\.staging\.\d+$');
    var deleted = 0;

    await for (final entity in artifactsDirectory.list(followLinks: false)) {
      final type = await FileSystemEntity.type(entity.path, followLinks: false);

      if (type != FileSystemEntityType.file) {
        continue;
      }

      final fileName = entity.path.split(Platform.pathSeparator).last;

      if (stagingPattern.hasMatch(fileName)) {
        await File(entity.path).delete();
        deleted++;
        continue;
      }

      if (!canonicalPattern.hasMatch(fileName)) {
        continue;
      }

      final relativePath = '$artifactsDirectoryName/$fileName';

      if (referenced.contains(relativePath)) {
        continue;
      }

      await File(entity.path).delete();
      deleted++;
    }

    return deleted;
  }

  Future<PreparedPrimaryReportArtifactVerification> _verifyFile({
    required File file,
    required String expectedHash,
    required int expectedSize,
  }) async {
    if (!await file.exists()) {
      return const PreparedPrimaryReportArtifactVerification.invalid(
        reason: 'Prepared Excel artifact file does not exist.',
      );
    }

    final stat = await file.stat();

    if (stat.type != FileSystemEntityType.file || stat.size != expectedSize) {
      return const PreparedPrimaryReportArtifactVerification.invalid(
        reason: 'Prepared Excel artifact file size does not match metadata.',
      );
    }

    final bytes = await file.readAsBytes();
    final actualHash = await _sha256(bytes);

    if (actualHash != expectedHash) {
      return const PreparedPrimaryReportArtifactVerification.invalid(
        reason: 'Prepared Excel artifact SHA-256 does not match metadata.',
      );
    }

    return const PreparedPrimaryReportArtifactVerification.valid();
  }

  Future<String> _sha256(List<int> bytes) async {
    final hash = await Sha256().hash(bytes);

    return hash.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
