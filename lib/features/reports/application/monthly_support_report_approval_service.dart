import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';

enum MonthlySupportReportApprovalOutcomeStatus {
  approved,
  warningsNotConfirmed,
  primaryArtifactNotSatisfied,
}

enum MonthlySupportReportSnapshotFreshness {
  noApprovedSnapshot,
  current,
  stale,
}

final class MonthlySupportReportApprovalOutcome {
  const MonthlySupportReportApprovalOutcome({
    required this.status,
    this.artifactGateResult,
    this.snapshot,
  });

  final MonthlySupportReportApprovalOutcomeStatus status;
  final PrimaryReportArtifactGateResult? artifactGateResult;
  final ApprovedMonthlySupportReportSnapshot? snapshot;

  bool get isApproved =>
      status == MonthlySupportReportApprovalOutcomeStatus.approved;
}

final class MonthlySupportReportSnapshotComparison {
  const MonthlySupportReportSnapshotComparison({
    required this.freshness,
    required this.currentSourceFingerprint,
    this.approvedSnapshot,
  });

  final MonthlySupportReportSnapshotFreshness freshness;
  final String currentSourceFingerprint;
  final ApprovedMonthlySupportReportSnapshot? approvedSnapshot;

  bool get isStale => freshness == MonthlySupportReportSnapshotFreshness.stale;
}

final class MonthlySupportReportApprovalService {
  const MonthlySupportReportApprovalService({required this.repository});

  final MonthlySupportReportSnapshotRepository repository;

  Future<MonthlySupportReportApprovalOutcome> approve({
    required int halaqahId,
    required MonthlySupportReportApprovalCandidate candidate,
    required PrimaryReportArtifactGate artifactGate,
    required DateTime approvedAtUtc,
  }) async {
    if (candidate.projection.halaqahId != halaqahId) {
      throw ArgumentError(
        'Monthly approval halaqah does not match projection halaqah.',
      );
    }

    if (!candidate.warningsAccepted) {
      return const MonthlySupportReportApprovalOutcome(
        status: MonthlySupportReportApprovalOutcomeStatus.warningsNotConfirmed,
      );
    }

    final artifactGateResult = await artifactGate.verify(
      candidate.artifactRequest,
    );

    if (!artifactGateResult.isSatisfied) {
      return MonthlySupportReportApprovalOutcome(
        status: MonthlySupportReportApprovalOutcomeStatus
            .primaryArtifactNotSatisfied,
        artifactGateResult: artifactGateResult,
      );
    }

    await repository.replaceApproved(
      halaqahId: halaqahId,
      projection: candidate.projection,
      sourceFingerprint: candidate.sourceFingerprint,
      approvedAtUtc: approvedAtUtc,
    );

    final snapshot = await repository.findApproved(
      halaqahId: halaqahId,
      period: candidate.projection.period,
    );

    if (snapshot == null) {
      throw StateError(
        'Approved monthly snapshot was not readable after approval.',
      );
    }

    return MonthlySupportReportApprovalOutcome(
      status: MonthlySupportReportApprovalOutcomeStatus.approved,
      artifactGateResult: artifactGateResult,
      snapshot: snapshot,
    );
  }

  Future<MonthlySupportReportSnapshotComparison> compareWithApproved({
    required int halaqahId,
    required MonthlySupportReportApprovalCandidate candidate,
  }) async {
    if (candidate.projection.halaqahId != halaqahId) {
      throw ArgumentError(
        'Monthly comparison halaqah does not match projection halaqah.',
      );
    }

    final approved = await repository.findApproved(
      halaqahId: halaqahId,
      period: candidate.projection.period,
    );

    if (approved == null) {
      return MonthlySupportReportSnapshotComparison(
        freshness: MonthlySupportReportSnapshotFreshness.noApprovedSnapshot,
        currentSourceFingerprint: candidate.sourceFingerprint,
      );
    }

    final freshness = approved.sourceFingerprint == candidate.sourceFingerprint
        ? MonthlySupportReportSnapshotFreshness.current
        : MonthlySupportReportSnapshotFreshness.stale;

    return MonthlySupportReportSnapshotComparison(
      freshness: freshness,
      currentSourceFingerprint: candidate.sourceFingerprint,
      approvedSnapshot: approved,
    );
  }
}
