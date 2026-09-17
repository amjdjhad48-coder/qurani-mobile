import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  const header = SupportReportHeaderSnapshot(
    teacherName: 'المعلم',
    halaqahName: 'الحلقة',
    organizationName: 'الجهة',
    policyVersion: 1,
    templateVersion: 1,
  );

  test(
    'history detail loads exact weekly approved snapshot read-only',
    () async {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));

      final snapshot = ApprovedWeeklySupportReportSnapshot(
        reportId: 41,
        halaqahId: 7,
        period: period,
        header: header,
        sourceFingerprint: 'weekly-fingerprint',
        approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
        students: const <ApprovedWeeklySupportReportStudentSnapshot>[],
        days: const <ApprovedWeeklySupportReportDaySnapshot>[],
      );

      final service = SupportReportHistoryDetailService(
        weeklyRepository: _WeeklyRepository(snapshot),
        monthlyRepository: _MonthlyRepository(null),
      );

      final item = SupportReportHistoryItem(
        reportId: 41,
        kind: SupportReportHistoryKind.weekly,
        periodStart: period.weekStart,
        periodEnd: period.weekEnd,
        header: header,
        sourceFingerprint: 'weekly-fingerprint',
        approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
      );

      final detail = await service.load(halaqahId: 7, item: item);

      expect(detail.weeklySnapshot, same(snapshot));
      expect(detail.monthlySnapshot, isNull);
    },
  );

  test(
    'history detail loads exact monthly approved snapshot read-only',
    () async {
      final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 1));

      final snapshot = ApprovedMonthlySupportReportSnapshot(
        reportId: 52,
        halaqahId: 7,
        period: period,
        header: header,
        sourceFingerprint: 'monthly-fingerprint',
        approvedAtUtc: DateTime.utc(2026, 9, 30, 10),
        students: const <ApprovedMonthlySupportReportStudentSnapshot>[],
      );

      final service = SupportReportHistoryDetailService(
        weeklyRepository: _WeeklyRepository(null),
        monthlyRepository: _MonthlyRepository(snapshot),
      );

      final item = SupportReportHistoryItem(
        reportId: 52,
        kind: SupportReportHistoryKind.monthly,
        periodStart: period.monthStart,
        periodEnd: period.monthEnd,
        header: header,
        sourceFingerprint: 'monthly-fingerprint',
        approvedAtUtc: DateTime.utc(2026, 9, 30, 10),
      );

      final detail = await service.load(halaqahId: 7, item: item);

      expect(detail.monthlySnapshot, same(snapshot));
      expect(detail.weeklySnapshot, isNull);
    },
  );

  test(
    'history detail rejects list item that mismatches immutable snapshot',
    () async {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));

      final snapshot = ApprovedWeeklySupportReportSnapshot(
        reportId: 41,
        halaqahId: 7,
        period: period,
        header: header,
        sourceFingerprint: 'actual',
        approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
        students: const <ApprovedWeeklySupportReportStudentSnapshot>[],
        days: const <ApprovedWeeklySupportReportDaySnapshot>[],
      );

      final service = SupportReportHistoryDetailService(
        weeklyRepository: _WeeklyRepository(snapshot),
        monthlyRepository: _MonthlyRepository(null),
      );

      final item = SupportReportHistoryItem(
        reportId: 41,
        kind: SupportReportHistoryKind.weekly,
        periodStart: period.weekStart,
        periodEnd: period.weekEnd,
        header: header,
        sourceFingerprint: 'different',
        approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
      );

      expect(
        () => service.load(halaqahId: 7, item: item),
        throwsA(isA<StateError>()),
      );
    },
  );
}

final class _WeeklyRepository implements WeeklySupportReportSnapshotRepository {
  const _WeeklyRepository(this.snapshot);

  final ApprovedWeeklySupportReportSnapshot? snapshot;

  @override
  Future<ApprovedWeeklySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    return snapshot;
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  }) {
    throw UnsupportedError('Read-only test repository.');
  }
}

final class _MonthlyRepository
    implements MonthlySupportReportSnapshotRepository {
  const _MonthlyRepository(this.snapshot);

  final ApprovedMonthlySupportReportSnapshot? snapshot;

  @override
  Future<ApprovedMonthlySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    return snapshot;
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  }) {
    throw UnsupportedError('Read-only test repository.');
  }
}
