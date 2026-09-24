import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/monthly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/application/package8_support_report_approval_coordinator.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

final class ProductionWeeklySupportReportApprovalCandidateReloader
    implements WeeklySupportReportApprovalCandidateReloader {
  const ProductionWeeklySupportReportApprovalCandidateReloader({
    required this.sourceRepository,
    this.projectionBuilder = const WeeklySupportReportProjectionBuilder(),
    this.candidateService = const WeeklySupportReportApprovalCandidateService(),
  });

  final SupportReportSourceRepository sourceRepository;
  final WeeklySupportReportProjectionBuilder projectionBuilder;
  final WeeklySupportReportApprovalCandidateService candidateService;

  @override
  Future<WeeklySupportReportApprovalCandidate> reload({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    final source = await sourceRepository.readWeeklySource(
      halaqahId: halaqahId,
      period: period,
    );

    if (source.halaqah.id != halaqahId) {
      throw StateError(
        'Reloaded weekly report source does not belong to the active halaqah.',
      );
    }

    final projection = projectionBuilder.build(source);

    if (projection.period.weekStart != period.weekStart ||
        projection.period.weekEnd != period.weekEnd) {
      throw StateError(
        'Reloaded weekly report projection changed the requested period.',
      );
    }

    return candidateService.buildCandidate(projection: projection);
  }
}

final class ProductionMonthlySupportReportApprovalCandidateReloader
    implements MonthlySupportReportApprovalCandidateReloader {
  const ProductionMonthlySupportReportApprovalCandidateReloader({
    required this.weeklyRepository,
    required this.generalCenterNameLoader,
    this.projectionBuilder = const MonthlySupportReportProjectionBuilder(),
    this.candidateService =
        const MonthlySupportReportApprovalCandidateService(),
  });

  final ApprovedWeeklySupportReportsForMonthRepository weeklyRepository;
  final Future<String> Function(int halaqahId) generalCenterNameLoader;
  final MonthlySupportReportProjectionBuilder projectionBuilder;
  final MonthlySupportReportApprovalCandidateService candidateService;

  @override
  Future<MonthlySupportReportApprovalCandidate> reload({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    final weeklySnapshots = await weeklyRepository
        .findApprovedIntersectingMonth(halaqahId: halaqahId, period: period);

    final centerName = (await generalCenterNameLoader(halaqahId)).trim();

    if (centerName.isEmpty) {
      throw StateError(
        'Reloaded monthly report source has an empty halaqah center identity.',
      );
    }

    final projection = projectionBuilder.build(
      period: period,
      approvedWeeklySnapshots: weeklySnapshots,
      centerName: centerName,
    );

    if (projection.halaqahId != halaqahId) {
      throw StateError(
        'Reloaded monthly report projection does not belong to the active halaqah.',
      );
    }

    if (projection.period.monthStart != period.monthStart ||
        projection.period.monthEnd != period.monthEnd) {
      throw StateError(
        'Reloaded monthly report projection changed the requested period.',
      );
    }

    return candidateService.buildCandidate(projection: projection);
  }
}
