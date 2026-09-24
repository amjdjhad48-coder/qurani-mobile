import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/monthly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

final class MonthlySupportReportReview {
  const MonthlySupportReportReview({
    required this.candidate,
    required this.comparison,
  });

  final MonthlySupportReportApprovalCandidate candidate;
  final MonthlySupportReportSnapshotComparison comparison;

  MonthlySupportReportProjection get projection => candidate.projection;

  bool get hasWarnings => projection.missingItems.isNotEmpty;

  bool get isStale => comparison.isStale;
}

final class MonthlySupportReportReviewService {
  const MonthlySupportReportReviewService({
    required this.weeklyRepository,
    required this.snapshotRepository,
    this.projectionBuilder = const MonthlySupportReportProjectionBuilder(),
    this.candidateService =
        const MonthlySupportReportApprovalCandidateService(),
  });

  final ApprovedWeeklySupportReportsForMonthRepository weeklyRepository;
  final MonthlySupportReportSnapshotRepository snapshotRepository;
  final MonthlySupportReportProjectionBuilder projectionBuilder;
  final MonthlySupportReportApprovalCandidateService candidateService;

  Future<MonthlySupportReportReview> load({
    required int halaqahId,
    required DateTime localDate,
    String? centerName,
  }) async {
    final period = MonthlySupportReportPeriod.forDate(localDate);

    final weeklySnapshots = await weeklyRepository
        .findApprovedIntersectingMonth(halaqahId: halaqahId, period: period);

    final projection = projectionBuilder.build(
      period: period,
      approvedWeeklySnapshots: weeklySnapshots,
      centerName: centerName,
    );

    if (projection.halaqahId != halaqahId) {
      throw StateError(
        'Monthly report projection does not belong to the active halaqah.',
      );
    }

    final candidate = await candidateService.buildCandidate(
      projection: projection,
    );

    final comparison = await MonthlySupportReportApprovalService(
      repository: snapshotRepository,
    ).compareWithApproved(halaqahId: halaqahId, candidate: candidate);

    return MonthlySupportReportReview(
      candidate: candidate,
      comparison: comparison,
    );
  }
}
