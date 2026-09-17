import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';

enum WeeklySupportReportApprovalOutcomeStatus {
  approved,
  warningsNotConfirmed,
  primaryArtifactNotSatisfied,
}

enum WeeklySupportReportSnapshotFreshness { noApprovedSnapshot, current, stale }

final class WeeklySupportReportApprovalOutcome {
  const WeeklySupportReportApprovalOutcome({
    required this.status,
    this.artifactGateResult,
    this.snapshot,
  });

  final WeeklySupportReportApprovalOutcomeStatus status;
  final PrimaryReportArtifactGateResult? artifactGateResult;
  final ApprovedWeeklySupportReportSnapshot? snapshot;

  bool get isApproved =>
      status == WeeklySupportReportApprovalOutcomeStatus.approved;
}

final class WeeklySupportReportSnapshotComparison {
  const WeeklySupportReportSnapshotComparison({
    required this.freshness,
    required this.currentSourceFingerprint,
    this.approvedSnapshot,
  });

  final WeeklySupportReportSnapshotFreshness freshness;
  final String currentSourceFingerprint;
  final ApprovedWeeklySupportReportSnapshot? approvedSnapshot;

  bool get isStale => freshness == WeeklySupportReportSnapshotFreshness.stale;
}

final class WeeklySupportReportApprovalService {
  const WeeklySupportReportApprovalService({required this.repository});

  final WeeklySupportReportSnapshotRepository repository;

  Future<WeeklySupportReportApprovalOutcome> approve({
    required int halaqahId,
    required WeeklySupportReportApprovalCandidate candidate,
    required PrimaryReportArtifactGate artifactGate,
    required DateTime approvedAtUtc,
  }) async {
    if (!candidate.warningsAccepted) {
      return const WeeklySupportReportApprovalOutcome(
        status: WeeklySupportReportApprovalOutcomeStatus.warningsNotConfirmed,
      );
    }

    final artifactGateResult = await artifactGate.verify(
      candidate.artifactRequest,
    );

    if (!artifactGateResult.isSatisfied) {
      return WeeklySupportReportApprovalOutcome(
        status: WeeklySupportReportApprovalOutcomeStatus
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
        'Approved weekly snapshot was not readable after approval.',
      );
    }

    return WeeklySupportReportApprovalOutcome(
      status: WeeklySupportReportApprovalOutcomeStatus.approved,
      artifactGateResult: artifactGateResult,
      snapshot: snapshot,
    );
  }

  Future<WeeklySupportReportSnapshotComparison> compareWithApproved({
    required int halaqahId,
    required WeeklySupportReportApprovalCandidate candidate,
  }) async {
    final approved = await repository.findApproved(
      halaqahId: halaqahId,
      period: candidate.projection.period,
    );

    if (approved == null) {
      return WeeklySupportReportSnapshotComparison(
        freshness: WeeklySupportReportSnapshotFreshness.noApprovedSnapshot,
        currentSourceFingerprint: candidate.sourceFingerprint,
      );
    }

    final freshness = approved.sourceFingerprint == candidate.sourceFingerprint
        ? WeeklySupportReportSnapshotFreshness.current
        : WeeklySupportReportSnapshotFreshness.stale;

    return WeeklySupportReportSnapshotComparison(
      freshness: freshness,
      currentSourceFingerprint: candidate.sourceFingerprint,
      approvedSnapshot: approved,
    );
  }
}
