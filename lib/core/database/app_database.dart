import 'package:drift/drift.dart';
import 'package:qurani/core/database/database_migrations.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [])
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => buildAppDatabaseMigrationStrategy(this);
}
