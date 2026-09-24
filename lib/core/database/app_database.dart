import 'package:drift/drift.dart';
import 'package:qurani/core/database/database_migrations.dart';
import 'package:qurani/features/daily_halaqah/data/tables/halaqah_day_tables.dart';
import 'package:qurani/features/parent_follow_up/data/tables/parent_follow_up_tables.dart';
import 'package:qurani/features/reports/data/tables/support_report_tables.dart';
import 'package:qurani/features/recitation/data/tables/recitation_tables.dart';
import 'package:qurani/features/setup/data/tables/setup_tables.dart';
import 'package:qurani/features/students/data/tables/student_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Halaqahs,
    SupportProgramSettings,
    SupportProgramPeriods,
    Students,
    StudentProgressPlans,
    StudentActivityPeriods,
    HalaqahDays,
    AttendanceRecords,
    Recitations,
    ParentFollowUps,
    SupportWeeklyReports,
    SupportWeeklyReportStudents,
    SupportWeeklyReportDays,
    SupportWeeklyReportDayEntries,
    SupportMonthlyReports,
    SupportMonthlyReportStudents,
    SupportMonthlyReportDays,
    SupportMonthlyReportDayEntries,
    ReportExportArtifacts,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => buildAppDatabaseMigrationStrategy(this);
}
