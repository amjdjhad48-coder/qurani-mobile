import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/package8_primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/package8_support_report_artifact_lifecycle.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

enum Package8SupportReportApprovalStatus {
  approved,
  warningsNotConfirmed,
  sourceChangedDuringPreparation,
  primaryArtifactNotSatisfied,
}

abstract interface class WeeklySupportReportApprovalCandidateReloader {
  Future<WeeklySupportReportApprovalCandidate> reload({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  });
}

abstract interface class MonthlySupportReportApprovalCandidateReloader {
  Future<MonthlySupportReportApprovalCandidate> reload({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  });
}

final class Package8WeeklySupportReportApprovalOutcome {
  const Package8WeeklySupportReportApprovalOutcome({
    required this.status,
    this.artifactGateResult,
    this.preparedArtifact,
    this.snapshot,
  });

  final Package8SupportReportApprovalStatus status;
  final PrimaryReportArtifactGateResult? artifactGateResult;
  final PreparedPrimaryReportArtifact? preparedArtifact;
  final ApprovedWeeklySupportReportSnapshot? snapshot;

  bool get isApproved => status == Package8SupportReportApprovalStatus.approved;
}

final class Package8MonthlySupportReportApprovalOutcome {
  const Package8MonthlySupportReportApprovalOutcome({
    required this.status,
    this.artifactGateResult,
    this.preparedArtifact,
    this.snapshot,
  });

  final Package8SupportReportApprovalStatus status;
  final PrimaryReportArtifactGateResult? artifactGateResult;
  final PreparedPrimaryReportArtifact? preparedArtifact;
  final ApprovedMonthlySupportReportSnapshot? snapshot;

  bool get isApproved => status == Package8SupportReportApprovalStatus.approved;
}

final class Package8WeeklySupportReportApprovalCoordinator {
  const Package8WeeklySupportReportApprovalCoordinator({
    required this.repository,
    required this.artifactPreparer,
    required this.artifactVerifier,
    required this.sourceReloader,
    required this.artifactLifecycle,
  });

  final WeeklySupportReportAtomicApprovalRepository repository;
  final PrimaryReportArtifactPreparer artifactPreparer;
  final PreparedPrimaryReportArtifactVerifier artifactVerifier;
  final WeeklySupportReportApprovalCandidateReloader sourceReloader;
  final SupportReportApprovalArtifactLifecycle artifactLifecycle;

  Future<Package8WeeklySupportReportApprovalOutcome> approve({
    required int halaqahId,
    required WeeklySupportReportApprovalCandidate candidate,
    required DateTime approvedAtUtc,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }
    if (!candidate.warningsAccepted) {
      return const Package8WeeklySupportReportApprovalOutcome(
        status: Package8SupportReportApprovalStatus.warningsNotConfirmed,
      );
    }

    final preparedArtifact = await artifactPreparer.prepareWeekly(
      halaqahId: halaqahId,
      projection: candidate.projection,
      sourceFingerprint: candidate.sourceFingerprint,
    );

    try {
      final artifactGateResult = await Package8PrimaryReportArtifactGate(
        preparedArtifact: preparedArtifact,
        verifier: artifactVerifier,
      ).verify(candidate.artifactRequest);

      if (!artifactGateResult.isSatisfied) {
        await _cleanupPreparedBestEffort(artifactLifecycle, preparedArtifact);
        return Package8WeeklySupportReportApprovalOutcome(
          status:
              Package8SupportReportApprovalStatus.primaryArtifactNotSatisfied,
          artifactGateResult: artifactGateResult,
          preparedArtifact: preparedArtifact,
        );
      }

      final reloadedCandidate = await sourceReloader.reload(
        halaqahId: halaqahId,
        period: candidate.projection.period,
      );
      if (reloadedCandidate.sourceFingerprint != candidate.sourceFingerprint) {
        await _cleanupPreparedBestEffort(artifactLifecycle, preparedArtifact);
        return Package8WeeklySupportReportApprovalOutcome(
          status: Package8SupportReportApprovalStatus
              .sourceChangedDuringPreparation,
          artifactGateResult: artifactGateResult,
          preparedArtifact: preparedArtifact,
        );
      }

      final previousArtifact = await artifactLifecycle
          .currentWeeklyPrimaryArtifact(
            halaqahId: halaqahId,
            period: candidate.projection.period,
          );

      await repository.replaceApprovedWithPrimaryArtifact(
        halaqahId: halaqahId,
        projection: candidate.projection,
        sourceFingerprint: candidate.sourceFingerprint,
        approvedAtUtc: approvedAtUtc,
        primaryArtifact: _primaryExcelMetadata(preparedArtifact),
      );

      final snapshot = await repository.findApproved(
        halaqahId: halaqahId,
        period: candidate.projection.period,
      );
      if (snapshot == null ||
          snapshot.sourceFingerprint != candidate.sourceFingerprint) {
        throw StateError(
          'Approved weekly snapshot was not readable after atomic approval.',
        );
      }

      if (previousArtifact != null) {
        await _cleanupStoredBestEffort(artifactLifecycle, previousArtifact);
      }

      return Package8WeeklySupportReportApprovalOutcome(
        status: Package8SupportReportApprovalStatus.approved,
        artifactGateResult: artifactGateResult,
        preparedArtifact: preparedArtifact,
        snapshot: snapshot,
      );
    } catch (_) {
      await _cleanupPreparedBestEffort(artifactLifecycle, preparedArtifact);
      rethrow;
    }
  }
}

final class Package8MonthlySupportReportApprovalCoordinator {
  const Package8MonthlySupportReportApprovalCoordinator({
    required this.repository,
    required this.artifactPreparer,
    required this.artifactVerifier,
    required this.sourceReloader,
    required this.artifactLifecycle,
  });

  final MonthlySupportReportAtomicApprovalRepository repository;
  final PrimaryReportArtifactPreparer artifactPreparer;
  final PreparedPrimaryReportArtifactVerifier artifactVerifier;
  final MonthlySupportReportApprovalCandidateReloader sourceReloader;
  final SupportReportApprovalArtifactLifecycle artifactLifecycle;

  Future<Package8MonthlySupportReportApprovalOutcome> approve({
    required int halaqahId,
    required MonthlySupportReportApprovalCandidate candidate,
    required DateTime approvedAtUtc,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }
    if (candidate.projection.halaqahId != halaqahId) {
      throw ArgumentError(
        'Monthly approval halaqah does not match projection halaqah.',
      );
    }
    if (!candidate.warningsAccepted) {
      return const Package8MonthlySupportReportApprovalOutcome(
        status: Package8SupportReportApprovalStatus.warningsNotConfirmed,
      );
    }

    final preparedArtifact = await artifactPreparer.prepareMonthly(
      projection: candidate.projection,
      sourceFingerprint: candidate.sourceFingerprint,
    );

    try {
      final artifactGateResult = await Package8PrimaryReportArtifactGate(
        preparedArtifact: preparedArtifact,
        verifier: artifactVerifier,
      ).verify(candidate.artifactRequest);

      if (!artifactGateResult.isSatisfied) {
        await _cleanupPreparedBestEffort(artifactLifecycle, preparedArtifact);
        return Package8MonthlySupportReportApprovalOutcome(
          status:
              Package8SupportReportApprovalStatus.primaryArtifactNotSatisfied,
          artifactGateResult: artifactGateResult,
          preparedArtifact: preparedArtifact,
        );
      }

      final reloadedCandidate = await sourceReloader.reload(
        halaqahId: halaqahId,
        period: candidate.projection.period,
      );
      if (reloadedCandidate.sourceFingerprint != candidate.sourceFingerprint) {
        await _cleanupPreparedBestEffort(artifactLifecycle, preparedArtifact);
        return Package8MonthlySupportReportApprovalOutcome(
          status: Package8SupportReportApprovalStatus
              .sourceChangedDuringPreparation,
          artifactGateResult: artifactGateResult,
          preparedArtifact: preparedArtifact,
        );
      }

      final previousArtifact = await artifactLifecycle
          .currentMonthlyPrimaryArtifact(
            halaqahId: halaqahId,
            period: candidate.projection.period,
          );

      await repository.replaceApprovedWithPrimaryArtifact(
        halaqahId: halaqahId,
        projection: candidate.projection,
        sourceFingerprint: candidate.sourceFingerprint,
        approvedAtUtc: approvedAtUtc,
        primaryArtifact: _primaryExcelMetadata(preparedArtifact),
      );

      final snapshot = await repository.findApproved(
        halaqahId: halaqahId,
        period: candidate.projection.period,
      );
      if (snapshot == null ||
          snapshot.sourceFingerprint != candidate.sourceFingerprint) {
        throw StateError(
          'Approved monthly snapshot was not readable after atomic approval.',
        );
      }

      if (previousArtifact != null) {
        await _cleanupStoredBestEffort(artifactLifecycle, previousArtifact);
      }

      return Package8MonthlySupportReportApprovalOutcome(
        status: Package8SupportReportApprovalStatus.approved,
        artifactGateResult: artifactGateResult,
        preparedArtifact: preparedArtifact,
        snapshot: snapshot,
      );
    } catch (_) {
      await _cleanupPreparedBestEffort(artifactLifecycle, preparedArtifact);
      rethrow;
    }
  }
}

SupportReportExportArtifactMetadata _primaryExcelMetadata(
  PreparedPrimaryReportArtifact artifact,
) {
  return SupportReportExportArtifactMetadata(
    format: SupportReportExportFormat.excel,
    internalPath: artifact.internalPath,
    sha256: artifact.sha256,
    templateVersion: artifact.templateVersion,
    sizeBytes: artifact.sizeBytes,
  );
}

Future<void> _cleanupPreparedBestEffort(
  SupportReportApprovalArtifactLifecycle lifecycle,
  PreparedPrimaryReportArtifact artifact,
) async {
  try {
    await lifecycle.cleanupPreparedIfUnreferenced(artifact);
  } catch (_) {
    // A cleanup failure must not replace the approval outcome or DB failure.
  }
}

Future<void> _cleanupStoredBestEffort(
  SupportReportApprovalArtifactLifecycle lifecycle,
  SupportReportExportArtifactMetadata artifact,
) async {
  try {
    await lifecycle.cleanupStoredIfUnreferenced(artifact);
  } catch (_) {
    // Startup orphan cleanup can retry a non-critical post-commit cleanup.
  }
}
