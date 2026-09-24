import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/package8_support_report_approval_reloaders.dart';
import 'package:qurani/features/reports/application/weekly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  group('Package 8 production approval candidate reloaders', () {
    test(
      'weekly reload rebuilds a fresh candidate from current source',
      () async {
        final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));
        final repository = _FakeSupportReportSourceRepository(
          _weeklySource(period),
        );
        final reloader = ProductionWeeklySupportReportApprovalCandidateReloader(
          sourceRepository: repository,
          projectionBuilder: const WeeklySupportReportProjectionBuilder(
            localDateResolver: _UtcDateResolver(),
          ),
        );

        final candidate = await reloader.reload(halaqahId: 1, period: period);

        expect(repository.lastHalaqahId, 1);
        expect(repository.lastPeriod!.weekStart, period.weekStart);
        expect(candidate.projection.period.weekStart, period.weekStart);
        expect(candidate.projection.days, hasLength(5));
        expect(candidate.sourceFingerprint, hasLength(64));
        expect(candidate.warningsConfirmed, isFalse);
      },
    );

    test(
      'monthly reload rebuilds from the currently approved weekly snapshots',
      () async {
        final period = MonthlySupportReportPeriod.forDate(
          DateTime(2026, 9, 15),
        );
        final weekly = _approvedWeeklySnapshot();
        final repository = _FakeApprovedWeeklyReportsForMonthRepository(
          <ApprovedWeeklySupportReportSnapshot>[weekly],
        );
        final reloader =
            ProductionMonthlySupportReportApprovalCandidateReloader(
              weeklyRepository: repository,
              generalCenterNameLoader: (_) async => 'المركز',
            );

        final candidate = await reloader.reload(halaqahId: 1, period: period);

        expect(repository.lastHalaqahId, 1);
        expect(repository.lastPeriod!.monthStart, period.monthStart);
        expect(candidate.projection.halaqahId, 1);
        expect(candidate.projection.weeklyInputs, hasLength(1));
        expect(
          candidate.projection.weeklyInputs.single.reportId,
          weekly.reportId,
        );
        expect(candidate.sourceFingerprint, hasLength(64));
        expect(candidate.warningsConfirmed, isFalse);
      },
    );
  });
}

WeeklySupportReportSource _weeklySource(WeeklySupportReportPeriod period) {
  return WeeklySupportReportSource(
    period: period,
    halaqah: const SupportReportHalaqahSource(
      id: 1,
      teacherName: 'المعلم',
      halaqahName: 'الحلقة',
      centerName: 'المركز',
    ),
    supportPeriods: <SupportReportSupportPeriodSource>[
      SupportReportSupportPeriodSource(
        id: 10,
        organizationName: 'الجهة',
        startedAtUtc: DateTime.utc(2026, 9, 1),
        endedAtUtc: null,
      ),
    ],
    students: const <SupportReportStudentSource>[],
    days: const <SupportReportDaySource>[],
    attendance: const <SupportReportAttendanceSource>[],
    newMemorization: const <SupportReportNewMemorizationSource>[],
  );
}

ApprovedWeeklySupportReportSnapshot _approvedWeeklySnapshot() {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 5));

  return ApprovedWeeklySupportReportSnapshot(
    reportId: 101,
    halaqahId: 1,
    period: period,
    header: const SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'الحلقة',
      organizationName: 'الجهة',
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    sourceFingerprint:
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    approvedAtUtc: DateTime.utc(2026, 9, 10, 12),
    students: const <ApprovedWeeklySupportReportStudentSnapshot>[],
    days: period.officialDates
        .map(
          (date) => ApprovedWeeklySupportReportDaySnapshot(
            snapshotRowId: date.day,
            localDate: date,
            dayKind: SupportReportDayKind.normal,
            entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[],
          ),
        )
        .toList(growable: false),
  );
}

final class _UtcDateResolver implements SupportReportLocalDateResolver {
  const _UtcDateResolver();

  @override
  DateTime localDateFromUtc(DateTime utc) {
    return DateTime(utc.year, utc.month, utc.day);
  }
}

final class _FakeSupportReportSourceRepository
    implements SupportReportSourceRepository {
  _FakeSupportReportSourceRepository(this.source);

  final WeeklySupportReportSource source;
  int? lastHalaqahId;
  WeeklySupportReportPeriod? lastPeriod;

  @override
  Future<WeeklySupportReportSource> readWeeklySource({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    lastHalaqahId = halaqahId;
    lastPeriod = period;
    return source;
  }
}

final class _FakeApprovedWeeklyReportsForMonthRepository
    implements ApprovedWeeklySupportReportsForMonthRepository {
  _FakeApprovedWeeklyReportsForMonthRepository(this.snapshots);

  final List<ApprovedWeeklySupportReportSnapshot> snapshots;
  int? lastHalaqahId;
  MonthlySupportReportPeriod? lastPeriod;

  @override
  Future<List<ApprovedWeeklySupportReportSnapshot>>
  findApprovedIntersectingMonth({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    lastHalaqahId = halaqahId;
    lastPeriod = period;
    return snapshots;
  }
}
