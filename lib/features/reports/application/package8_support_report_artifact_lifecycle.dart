import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

abstract interface class SupportReportArtifactReferenceRepository {
  Future<SupportReportExportArtifactMetadata?> findWeeklyPrimaryArtifact({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  });

  Future<SupportReportExportArtifactMetadata?> findMonthlyPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  });

  Future<bool> isInternalPathReferenced(String internalPath);

  Future<Set<String>> referencedInternalPaths();
}

abstract interface class SupportReportArtifactFileCleanup {
  Future<bool> deleteArtifactIfExists({
    required String internalPath,
    required String sha256,
  });

  Future<int> cleanupUnreferencedArtifacts(Set<String> referencedInternalPaths);
}

abstract interface class SupportReportApprovalArtifactLifecycle {
  Future<SupportReportExportArtifactMetadata?> currentWeeklyPrimaryArtifact({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  });

  Future<SupportReportExportArtifactMetadata?> currentMonthlyPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  });

  Future<void> cleanupPreparedIfUnreferenced(
    PreparedPrimaryReportArtifact artifact,
  );

  Future<void> cleanupStoredIfUnreferenced(
    SupportReportExportArtifactMetadata artifact,
  );

  Future<int> cleanupOrphans();
}

final class Package8SupportReportArtifactLifecycle
    implements SupportReportApprovalArtifactLifecycle {
  const Package8SupportReportArtifactLifecycle({
    required this.referenceRepository,
    required this.fileCleanup,
  });

  final SupportReportArtifactReferenceRepository referenceRepository;
  final SupportReportArtifactFileCleanup fileCleanup;

  @override
  Future<SupportReportExportArtifactMetadata?> currentWeeklyPrimaryArtifact({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) {
    return referenceRepository.findWeeklyPrimaryArtifact(
      halaqahId: halaqahId,
      period: period,
    );
  }

  @override
  Future<SupportReportExportArtifactMetadata?> currentMonthlyPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) {
    return referenceRepository.findMonthlyPrimaryArtifact(
      halaqahId: halaqahId,
      period: period,
    );
  }

  @override
  Future<void> cleanupPreparedIfUnreferenced(
    PreparedPrimaryReportArtifact artifact,
  ) async {
    final isReferenced = await referenceRepository.isInternalPathReferenced(
      artifact.internalPath,
    );

    if (isReferenced) {
      return;
    }

    await fileCleanup.deleteArtifactIfExists(
      internalPath: artifact.internalPath,
      sha256: artifact.sha256,
    );
  }

  @override
  Future<void> cleanupStoredIfUnreferenced(
    SupportReportExportArtifactMetadata artifact,
  ) async {
    final isReferenced = await referenceRepository.isInternalPathReferenced(
      artifact.internalPath,
    );

    if (isReferenced) {
      return;
    }

    await fileCleanup.deleteArtifactIfExists(
      internalPath: artifact.internalPath,
      sha256: artifact.sha256,
    );
  }

  @override
  Future<int> cleanupOrphans() async {
    final referenced = await referenceRepository.referencedInternalPaths();

    return fileCleanup.cleanupUnreferencedArtifacts(
      Set<String>.unmodifiable(referenced),
    );
  }
}
