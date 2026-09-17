import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/data/drift_approved_weekly_reports_for_month_repository.dart';
import 'package:qurani/features/reports/data/drift_weekly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('DriftApprovedWeeklySupportReportsForMonthRepository', () {
    test(
      'returns only approved weekly snapshots whose stored week intersects the month',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        addTearDown(database.close);

        await _seedIdentity(database);

        final weeklyRepository = DriftWeeklySupportReportSnapshotRepository(
          database,
        );

        await _approveWeek(
          weeklyRepository,
          weekDate: DateTime(2026, 8, 22),
          fingerprint: 'outside-august',
        );

        await _approveWeek(
          weeklyRepository,
          weekDate: DateTime(2026, 8, 29),
          fingerprint: 'cross-month',
        );

        await _approveWeek(
          weeklyRepository,
          weekDate: DateTime(2026, 9, 5),
          fingerprint: 'inside-september',
        );

        await database.customStatement(
          "INSERT INTO support_weekly_reports ("
          "halaqah_id, week_start_date, week_end_date, status, "
          "teacher_name_snapshot, halaqah_name_snapshot, "
          "organization_name_snapshot, policy_version, template_version"
          ") VALUES ("
          "1, '2026-09-12', '2026-09-16', 'draft', "
          "'المعلم', 'الحلقة', 'الجهة', 1, 1"
          ");",
        );

        final repository = DriftApprovedWeeklySupportReportsForMonthRepository(
          database,
        );

        final snapshots = await repository.findApprovedIntersectingMonth(
          halaqahId: 1,
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
        );

        expect(
          snapshots.map((snapshot) => snapshot.sourceFingerprint).toList(),
          <String>['cross-month', 'inside-september'],
        );

        expect(
          snapshots.map((snapshot) => snapshot.period.weekStart).toList(),
          <DateTime>[DateTime(2026, 8, 29), DateTime(2026, 9, 5)],
        );
      },
    );

    test('monthly source read never creates monthly snapshot rows', () async {
      final database = AppDatabase(NativeDatabase.memory());

      addTearDown(database.close);

      await _seedIdentity(database);

      final weeklyRepository = DriftWeeklySupportReportSnapshotRepository(
        database,
      );

      await _approveWeek(
        weeklyRepository,
        weekDate: DateTime(2026, 9, 5),
        fingerprint: 'approved-week',
      );

      final repository = DriftApprovedWeeklySupportReportsForMonthRepository(
        database,
      );

      await repository.findApprovedIntersectingMonth(
        halaqahId: 1,
        period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
      );

      final monthlyReports = await database
          .select(database.supportMonthlyReports)
          .get();

      final monthlyStudents = await database
          .select(database.supportMonthlyReportStudents)
          .get();

      expect(monthlyReports, isEmpty);

      expect(monthlyStudents, isEmpty);
    });
  });
}

Future<void> _seedIdentity(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'الحلقة', 'المركز', "
    "'2026-08-01T10:00:00.000Z', "
    "'2026-08-01T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "1, 1, 'أحمد', 'محمد', 12, '+967', "
    "'771234567', 'حفظ سابق', 1, 1"
    ");",
  );
}

Future<void> _approveWeek(
  DriftWeeklySupportReportSnapshotRepository repository, {
  required DateTime weekDate,
  required String fingerprint,
}) {
  return repository.replaceApproved(
    halaqahId: 1,
    projection: _weeklyProjection(weekDate),
    sourceFingerprint: fingerprint,
    approvedAtUtc: DateTime.utc(
      weekDate.year,
      weekDate.month,
      weekDate.day,
      18,
    ),
  );
}

WeeklySupportReportProjection _weeklyProjection(DateTime weekDate) {
  final period = WeeklySupportReportPeriod.forDate(weekDate);

  final days = <WeeklySupportReportDayProjection>[];

  for (final date in period.officialDates) {
    days.add(
      WeeklySupportReportDayProjection(
        localDate: date,
        dayKind: SupportReportDayKind.normal,
        entries: <WeeklySupportReportDayEntryProjection>[
          WeeklySupportReportDayEntryProjection(
            sourceStudentId: 1,
            attendanceStatus: SupportReportAttendanceStatus.present,
          ),
        ],
      ),
    );
  }

  return WeeklySupportReportProjection(
    period: period,
    header: const SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'الحلقة',
      organizationName: 'الجهة',
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: const <WeeklySupportReportStudentProjection>[
      WeeklySupportReportStudentProjection(
        sourceStudentId: 1,
        supportStudentNumber: 'SUP-001',
        studentName: 'أحمد',
        currentJuz: 2,
        dailyPlanText: 'نصف وجه',
        displayOrder: 1,
      ),
    ],
    days: days,
    missingItems: const <ReportMissingItem>[],
  );
}
