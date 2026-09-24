import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';

void main() {
  group('Support report schema', () {
    test(
      'keeps Package 7 tables and adds Package 8 monthly detail tables',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await database.customSelect('SELECT 1;').get();

          final rows = await database
              .customSelect(
                "SELECT name FROM sqlite_master "
                "WHERE type = 'table' "
                "AND name LIKE 'support_%report%' "
                "ORDER BY name;",
              )
              .get();

          final names = rows
              .map((row) => row.read<String>('name'))
              .toList(growable: false);

          expect(names, <String>[
            'support_monthly_report_day_entries',
            'support_monthly_report_days',
            'support_monthly_report_students',
            'support_monthly_reports',
            'support_weekly_report_day_entries',
            'support_weekly_report_days',
            'support_weekly_report_students',
            'support_weekly_reports',
          ]);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'weekly approved snapshot enforces header and period uniqueness',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedIdentity(database);

          await _insertApprovedWeekly(database);

          await expectLater(
            _insertApprovedWeekly(database, id: 2),
            throwsA(anything),
          );

          await expectLater(
            database.customStatement(
              "INSERT INTO support_weekly_reports ("
              "halaqah_id, week_start_date, week_end_date, status, "
              "teacher_name_snapshot, halaqah_name_snapshot, "
              "organization_name_snapshot, policy_version, template_version"
              ") VALUES ("
              "1, '2026-09-19', '2026-09-23', 'approved', "
              "'المعلم', 'الحلقة', 'الجهة', 1, 1"
              ");",
            ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'warning-compatible nullable fields and approved children cascade',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedIdentity(database);
          await _insertApprovedWeekly(database);

          await database.customStatement(
            "INSERT INTO support_weekly_report_students ("
            "id, report_id, source_student_id, "
            "support_student_number_snapshot, student_name_snapshot, "
            "current_juz_snapshot, daily_plan_text_snapshot, "
            "monthly_goal_quarter_faces_snapshot, display_order_snapshot"
            ") VALUES ("
            "1, 1, 1, NULL, 'أحمد', NULL, NULL, 80, 1"
            ");",
          );

          await database.customStatement(
            "INSERT INTO support_weekly_report_days "
            "(id, report_id, day_date, day_kind) "
            "VALUES (1, 1, '2026-09-12', 'missing');",
          );

          await database.customStatement(
            "INSERT INTO support_weekly_report_day_entries ("
            "id, report_day_id, report_student_id, "
            "attendance_status_snapshot, achieved_quarter_faces, entry_order"
            ") VALUES (1, 1, 1, NULL, 0, 1);",
          );

          await expectLater(
            database.customStatement(
              "INSERT INTO support_weekly_report_days "
              "(report_id, day_date, day_kind) "
              "VALUES (1, '2026-09-13', 'closed');",
            ),
            throwsA(anything),
          );

          final entryColumns = await database
              .customSelect(
                'PRAGMA table_info(support_weekly_report_day_entries);',
              )
              .get();

          final columnNames = entryColumns
              .map((row) => row.read<String>('name'))
              .toSet();

          expect(columnNames, isNot(contains('evaluation')));
          expect(columnNames, isNot(contains('error_count')));

          await database.customStatement(
            'DELETE FROM support_weekly_reports WHERE id = 1;',
          );

          for (final table in <String>[
            'support_weekly_report_students',
            'support_weekly_report_days',
            'support_weekly_report_day_entries',
          ]) {
            final row = await database
                .customSelect('SELECT COUNT(*) AS row_count FROM $table;')
                .getSingle();

            expect(row.read<int>('row_count'), 0);
          }
        } finally {
          await database.close();
        }
      },
    );

    test(
      'day entry requires canonical attendance and all-or-none Quran range',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedIdentity(database);
          await _insertApprovedWeekly(database);

          await database.customStatement(
            "INSERT INTO support_weekly_report_students ("
            "id, report_id, source_student_id, student_name_snapshot, "
            "monthly_goal_quarter_faces_snapshot, display_order_snapshot"
            ") VALUES (1, 1, 1, 'أحمد', 80, 1);",
          );

          await database.customStatement(
            "INSERT INTO support_weekly_report_days "
            "(id, report_id, day_date, day_kind) "
            "VALUES (1, 1, '2026-09-14', 'normal');",
          );

          await database.customStatement(
            "INSERT INTO support_weekly_report_day_entries ("
            "report_day_id, report_student_id, attendance_status_snapshot, "
            "achieved_quarter_faces, start_surah_snapshot, "
            "start_ayah_snapshot, end_surah_snapshot, end_ayah_snapshot, "
            "entry_order"
            ") VALUES ("
            "1, 1, 'present', 4, 2, 1, 2, 5, 1"
            ");",
          );

          await expectLater(
            database.customStatement(
              "INSERT INTO support_weekly_report_day_entries ("
              "report_day_id, report_student_id, attendance_status_snapshot, "
              "achieved_quarter_faces, start_surah_snapshot, entry_order"
              ") VALUES (1, 1, 'late', 1, 2, 2);",
            ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'monthly snapshot enforces one report per month and aggregate bounds',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedIdentity(database);

          await database.customStatement(
            "INSERT INTO support_monthly_reports ("
            "id, halaqah_id, month_start_date, month_end_date, status, "
            "teacher_name_snapshot, halaqah_name_snapshot, "
            "organization_name_snapshot, policy_version, template_version, "
            "source_fingerprint, approved_at_utc"
            ") VALUES ("
            "1, 1, '2026-09-01', '2026-09-30', 'approved', "
            "'المعلم', 'الحلقة', 'الجهة', 1, 1, "
            "'monthly-fingerprint', '2026-10-01T10:00:00.000Z'"
            ");",
          );

          await database.customStatement(
            "INSERT INTO support_monthly_report_students ("
            "report_id, source_student_id, student_name_snapshot, "
            "monthly_goal_quarter_faces_snapshot, achieved_quarter_faces, "
            "absence_days, goal_completed, display_order_snapshot"
            ") VALUES (1, 1, 'أحمد', 80, 79, 2, 0, 1);",
          );

          await expectLater(
            database.customStatement(
              "INSERT INTO support_monthly_reports ("
              "halaqah_id, month_start_date, month_end_date, status, "
              "teacher_name_snapshot, halaqah_name_snapshot, "
              "organization_name_snapshot, policy_version, template_version, "
              "source_fingerprint, approved_at_utc"
              ") VALUES ("
              "1, '2026-09-01', '2026-09-30', 'approved', "
              "'المعلم', 'الحلقة', 'الجهة', 1, 1, "
              "'other', '2026-10-01T11:00:00.000Z'"
              ");",
            ),
            throwsA(anything),
          );

          await expectLater(
            database.customStatement(
              "INSERT INTO support_monthly_report_students ("
              "report_id, source_student_id, student_name_snapshot, "
              "monthly_goal_quarter_faces_snapshot, achieved_quarter_faces, "
              "absence_days, goal_completed, display_order_snapshot"
              ") VALUES (1, 1, 'أحمد', 80, -1, 0, 0, 2);",
            ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );
  });
}

Future<void> _seedIdentity(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'الحلقة', 'المركز', "
    "'2026-09-01T10:00:00.000Z', "
    "'2026-09-01T10:00:00.000Z'"
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

Future<void> _insertApprovedWeekly(AppDatabase database, {int id = 1}) {
  return database.customStatement(
    "INSERT INTO support_weekly_reports ("
    "id, halaqah_id, week_start_date, week_end_date, status, "
    "teacher_name_snapshot, halaqah_name_snapshot, "
    "organization_name_snapshot, policy_version, template_version, "
    "source_fingerprint, approved_at_utc"
    ") VALUES ("
    "$id, 1, '2026-09-12', '2026-09-16', 'approved', "
    "'المعلم', 'الحلقة', 'الجهة', 1, 1, "
    "'weekly-fingerprint', '2026-09-17T10:00:00.000Z'"
    ");",
  );
}
