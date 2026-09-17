import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/weekly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class WeeklySupportReportReview {
  const WeeklySupportReportReview({
    required this.source,
    required this.candidate,
    required this.comparison,
  });

  final WeeklySupportReportSource source;
  final WeeklySupportReportApprovalCandidate candidate;
  final WeeklySupportReportSnapshotComparison comparison;

  WeeklySupportReportProjection get projection => candidate.projection;

  bool get hasWarnings => projection.missingItems.isNotEmpty;

  bool get isStale => comparison.isStale;

  int? sourceDayIdFor(DateTime localDate) {
    final expectedDate = _dateText(SupportReportPolicy.dateOnly(localDate));

    for (final day in source.days) {
      if (day.dayDate == expectedDate) {
        return day.id;
      }
    }

    return null;
  }

  String _dateText(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}

final class WeeklySupportReportReviewService {
  const WeeklySupportReportReviewService({
    required this.sourceRepository,
    required this.snapshotRepository,
    this.projectionBuilder = const WeeklySupportReportProjectionBuilder(),
    this.candidateService = const WeeklySupportReportApprovalCandidateService(),
  });

  final SupportReportSourceRepository sourceRepository;
  final WeeklySupportReportSnapshotRepository snapshotRepository;
  final WeeklySupportReportProjectionBuilder projectionBuilder;
  final WeeklySupportReportApprovalCandidateService candidateService;

  Future<WeeklySupportReportReview> load({
    required int halaqahId,
    required DateTime localDate,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    final period = WeeklySupportReportPeriod.forDate(localDate);

    final source = await sourceRepository.readWeeklySource(
      halaqahId: halaqahId,
      period: period,
    );

    final projection = projectionBuilder.build(source);

    final candidate = await candidateService.buildCandidate(
      projection: projection,
    );

    final comparison = await WeeklySupportReportApprovalService(
      repository: snapshotRepository,
    ).compareWithApproved(halaqahId: halaqahId, candidate: candidate);

    return WeeklySupportReportReview(
      source: source,
      candidate: candidate,
      comparison: comparison,
    );
  }
}
