import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

final class SupportReportHistoryDetail {
  SupportReportHistoryDetail.weekly({
    required this.item,
    required ApprovedWeeklySupportReportSnapshot snapshot,
  }) : weeklySnapshot = snapshot,
       monthlySnapshot = null {
    if (item.kind != SupportReportHistoryKind.weekly) {
      throw ArgumentError(
        'Weekly history detail requires a weekly history item.',
      );
    }
  }

  SupportReportHistoryDetail.monthly({
    required this.item,
    required ApprovedMonthlySupportReportSnapshot snapshot,
  }) : weeklySnapshot = null,
       monthlySnapshot = snapshot {
    if (item.kind != SupportReportHistoryKind.monthly) {
      throw ArgumentError(
        'Monthly history detail requires a monthly history item.',
      );
    }
  }

  final SupportReportHistoryItem item;
  final ApprovedWeeklySupportReportSnapshot? weeklySnapshot;
  final ApprovedMonthlySupportReportSnapshot? monthlySnapshot;
}

final class SupportReportHistoryDetailService {
  const SupportReportHistoryDetailService({
    required this.weeklyRepository,
    required this.monthlyRepository,
  });

  final WeeklySupportReportSnapshotRepository weeklyRepository;
  final MonthlySupportReportSnapshotRepository monthlyRepository;

  Future<SupportReportHistoryDetail> load({
    required int halaqahId,
    required SupportReportHistoryItem item,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    return switch (item.kind) {
      SupportReportHistoryKind.weekly => _loadWeekly(
        halaqahId: halaqahId,
        item: item,
      ),
      SupportReportHistoryKind.monthly => _loadMonthly(
        halaqahId: halaqahId,
        item: item,
      ),
    };
  }

  Future<SupportReportHistoryDetail> _loadWeekly({
    required int halaqahId,
    required SupportReportHistoryItem item,
  }) async {
    final period = WeeklySupportReportPeriod.forDate(item.periodStart);

    if (period.weekStart != item.periodStart ||
        period.weekEnd != item.periodEnd) {
      throw StateError(
        'Weekly history period does not match the approved item.',
      );
    }

    final snapshot = await weeklyRepository.findApproved(
      halaqahId: halaqahId,
      period: period,
    );

    if (snapshot == null) {
      throw StateError('Approved weekly history snapshot was not found.');
    }

    _verifyIdentity(
      item: item,
      reportId: snapshot.reportId,
      sourceFingerprint: snapshot.sourceFingerprint,
      policyVersion: snapshot.header.policyVersion,
      templateVersion: snapshot.header.templateVersion,
    );

    return SupportReportHistoryDetail.weekly(item: item, snapshot: snapshot);
  }

  Future<SupportReportHistoryDetail> _loadMonthly({
    required int halaqahId,
    required SupportReportHistoryItem item,
  }) async {
    final period = MonthlySupportReportPeriod.forDate(item.periodStart);

    if (period.monthStart != item.periodStart ||
        period.monthEnd != item.periodEnd) {
      throw StateError(
        'Monthly history period does not match the approved item.',
      );
    }

    final snapshot = await monthlyRepository.findApproved(
      halaqahId: halaqahId,
      period: period,
    );

    if (snapshot == null) {
      throw StateError('Approved monthly history snapshot was not found.');
    }

    _verifyIdentity(
      item: item,
      reportId: snapshot.reportId,
      sourceFingerprint: snapshot.sourceFingerprint,
      policyVersion: snapshot.header.policyVersion,
      templateVersion: snapshot.header.templateVersion,
    );

    return SupportReportHistoryDetail.monthly(item: item, snapshot: snapshot);
  }

  void _verifyIdentity({
    required SupportReportHistoryItem item,
    required int reportId,
    required String sourceFingerprint,
    required int policyVersion,
    required int templateVersion,
  }) {
    if (reportId != item.reportId ||
        sourceFingerprint != item.sourceFingerprint ||
        policyVersion != item.header.policyVersion ||
        templateVersion != item.header.templateVersion) {
      throw StateError(
        'Approved history list item no longer matches its immutable snapshot.',
      );
    }
  }
}
