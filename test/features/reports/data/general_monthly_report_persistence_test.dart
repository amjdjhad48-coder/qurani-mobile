import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/data/drift_monthly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  test(
    'general monthly snapshot persists without sponsor policy sentinels',
    () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await database.customSelect('SELECT 1;').get();

      await database.customStatement(
        "INSERT INTO halaqahs "
        "(id, teacher_name, halaqah_name, center_name, "
        "created_at_utc, updated_at_utc) "
        "VALUES (1, 'المعلم', 'حلقة النور', 'مركز النور', "
        "'2026-09-01T00:00:00.000Z', '2026-09-01T00:00:00.000Z');",
      );

      await database.customStatement(
        "INSERT INTO students "
        "(id, halaqah_id, student_name, father_name, age_years, "
        "guardian_country_code, guardian_national_number, "
        "previous_memorization_text, support_student_number, "
        "display_order, is_active) "
        "VALUES (1, 1, 'أحمد', 'محمد', 12, '+967', "
        "'771234567', 'حفظ سابق', NULL, 1, 1);",
      );

      final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));

      final projection = MonthlySupportReportProjection(
        halaqahId: 1,
        period: period,
        header: const SupportReportHeaderSnapshot(
          teacherName: 'المعلم',
          halaqahName: 'حلقة النور',
          organizationName: 'مركز النور',
          reportContext: SupportReportContext.general,
          policyVersion: SupportReportPolicy.policyVersion,
          templateVersion: SupportReportPolicy.templateVersion,
        ),
        students: const <MonthlySupportReportStudentProjection>[
          MonthlySupportReportStudentProjection(
            sourceStudentId: 1,
            studentName: 'أحمد',
            supportStudentNumber: null,
            currentJuz: 2,
            dailyPlanText: 'نصف وجه',
            monthlyGoalQuarterFaces: null,
            achievedQuarterFaces: 8,
            absenceDays: 0,
            goalCompleted: null,
            displayOrder: 1,
          ),
        ],
        days: const <MonthlySupportReportDayProjection>[],
        weeklyInputs: const <MonthlySupportReportWeeklyInputIdentity>[],
        missingItems: const <ReportMissingItem>[],
      );

      final repo = DriftMonthlySupportReportSnapshotRepository(database);

      await repo.replaceApproved(
        halaqahId: 1,
        projection: projection,
        sourceFingerprint: 'general-monthly-source',
        approvedAtUtc: DateTime.utc(2026, 9, 20, 12),
      );

      final snapshot = await repo.findApproved(halaqahId: 1, period: period);

      expect(snapshot, isNotNull);
      expect(snapshot!.header.reportContext, SupportReportContext.general);

      final student = snapshot.students.single;

      expect(student.supportStudentNumber, isNull);
      expect(student.monthlyGoalQuarterFaces, isNull);
      expect(student.goalCompleted, isNull);
      expect(student.achievedQuarterFaces, 8);

      final row = await database
          .select(database.supportMonthlyReportStudents)
          .getSingle();

      expect(row.supportStudentNumberSnapshot, isNull);
      expect(row.monthlyGoalQuarterFacesSnapshot, isNull);
      expect(row.goalCompleted, isNull);
    },
  );
}
