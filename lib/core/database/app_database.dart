import 'package:drift/drift.dart';
import 'package:qurani/core/database/database_migrations.dart';
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
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => buildAppDatabaseMigrationStrategy(this);
}
