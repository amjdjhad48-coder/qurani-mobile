import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';

MigrationStrategy buildAppDatabaseMigrationStrategy(AppDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createPackage6Indexes(database);
    },
    onUpgrade: (migrator, from, to) async {
      if (from == to) {
        return;
      }

      if (from == 1 && to == 2) {
        await _createPackage2Schema(database, migrator);
        return;
      }

      if (from == 2 && to == 3) {
        await _createPackage3Schema(database, migrator);
        return;
      }

      if (from == 3 && to == 4) {
        await _createPackage4Schema(database, migrator);
        return;
      }

      if (from == 4 && to == 5) {
        await _createPackage5Schema(database, migrator);
        return;
      }

      if (from == 5 && to == 6) {
        await _createPackage6Schema(database, migrator);
        return;
      }

      if (from == 1 && to == 3) {
        await _createPackage2Schema(database, migrator);
        await _createPackage3Schema(database, migrator);
        return;
      }

      if (from == 2 && to == 4) {
        await _createPackage3Schema(database, migrator);
        await _createPackage4Schema(database, migrator);
        return;
      }

      if (from == 1 && to == 4) {
        await _createPackage2Schema(database, migrator);
        await _createPackage3Schema(database, migrator);
        await _createPackage4Schema(database, migrator);
        return;
      }

      if (from == 3 && to == 5) {
        await _createPackage4Schema(database, migrator);
        await _createPackage5Schema(database, migrator);
        return;
      }

      if (from == 2 && to == 5) {
        await _createPackage3Schema(database, migrator);
        await _createPackage4Schema(database, migrator);
        await _createPackage5Schema(database, migrator);
        return;
      }

      if (from == 1 && to == 5) {
        await _createPackage2Schema(database, migrator);
        await _createPackage3Schema(database, migrator);
        await _createPackage4Schema(database, migrator);
        await _createPackage5Schema(database, migrator);
        return;
      }

      if (from == 4 && to == 6) {
        await _createPackage5Schema(database, migrator);
        await _createPackage6Schema(database, migrator);
        return;
      }

      if (from == 3 && to == 6) {
        await _createPackage4Schema(database, migrator);
        await _createPackage5Schema(database, migrator);
        await _createPackage6Schema(database, migrator);
        return;
      }

      if (from == 2 && to == 6) {
        await _createPackage3Schema(database, migrator);
        await _createPackage4Schema(database, migrator);
        await _createPackage5Schema(database, migrator);
        await _createPackage6Schema(database, migrator);
        return;
      }

      if (from == 1 && to == 6) {
        await _createPackage2Schema(database, migrator);
        await _createPackage3Schema(database, migrator);
        await _createPackage4Schema(database, migrator);
        await _createPackage5Schema(database, migrator);
        await _createPackage6Schema(database, migrator);
        return;
      }

      if (to == 7 && from >= 1 && from <= 6) {
        if (from <= 1) {
          await _createPackage2Schema(database, migrator);
        }
        if (from <= 2) {
          await _createPackage3Schema(database, migrator);
        }
        if (from <= 3) {
          await _createPackage4Schema(database, migrator);
        }
        if (from <= 4) {
          await _createPackage5Schema(database, migrator);
        }
        if (from <= 5) {
          await _createPackage6Schema(database, migrator);
        }

        await _createPackage7Schema(database, migrator);
        return;
      }
      throw StateError(
        'Unsupported Qurani database migration path: $from -> $to. '
        'Every schema change must add an explicit tested migration.',
      );
    },
    beforeOpen: (details) async {
      await database.customStatement('PRAGMA foreign_keys = ON;');

      if (details.wasCreated || details.hadUpgrade) {
        await verifyDatabaseAfterSchemaChange(database);
      }
    },
  );
}

Future<void> _createPackage2Schema(
  AppDatabase database,
  Migrator migrator,
) async {
  await migrator.createTable(database.halaqahs);
  await migrator.createTable(database.supportProgramSettings);
  await migrator.createTable(database.supportProgramPeriods);
}

Future<void> _createPackage3Schema(
  AppDatabase database,
  Migrator migrator,
) async {
  await migrator.createTable(database.students);
  await migrator.createTable(database.studentProgressPlans);
  await migrator.createTable(database.studentActivityPeriods);
}

Future<void> _createPackage4Schema(
  AppDatabase database,
  Migrator migrator,
) async {
  await migrator.createTable(database.halaqahDays);
  await migrator.createTable(database.attendanceRecords);
}

Future<void> _createPackage5Schema(
  AppDatabase database,
  Migrator migrator,
) async {
  await migrator.createTable(database.recitations);
}

Future<void> _createPackage6Schema(
  AppDatabase database,
  Migrator migrator,
) async {
  await migrator.createTable(database.parentFollowUps);
  await _createPackage6Indexes(database);
}

Future<void> _createPackage7Schema(
  AppDatabase database,
  Migrator migrator,
) async {
  await migrator.createTable(database.supportWeeklyReports);
  await migrator.createTable(database.supportWeeklyReportStudents);
  await migrator.createTable(database.supportWeeklyReportDays);
  await migrator.createTable(database.supportWeeklyReportDayEntries);
  await migrator.createTable(database.supportMonthlyReports);
  await migrator.createTable(database.supportMonthlyReportStudents);
}

Future<void> _createPackage6Indexes(AppDatabase database) async {
  await database.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS '
    'idx_parent_follow_ups_daily_unique '
    'ON parent_follow_ups(day_id, student_id) '
    "WHERE type = 'daily';",
  );

  await database.customStatement(
    'CREATE UNIQUE INDEX IF NOT EXISTS '
    'idx_parent_follow_ups_pending_correction_unique '
    'ON parent_follow_ups(day_id, student_id) '
    "WHERE type = 'attendance_correction' "
    "AND status = 'pending';",
  );
}

Future<void> verifyDatabaseAfterSchemaChange(AppDatabase database) async {
  final integrityRows = await database
      .customSelect('PRAGMA integrity_check;')
      .get();

  if (integrityRows.length != 1) {
    throw StateError(
      'PRAGMA integrity_check returned ${integrityRows.length} rows.',
    );
  }

  final integrityValues = integrityRows.single.data.values.toList(
    growable: false,
  );

  if (integrityValues.length != 1 ||
      integrityValues.single.toString().toLowerCase() != 'ok') {
    throw StateError(
      'PRAGMA integrity_check failed: ${integrityRows.single.data}.',
    );
  }

  final foreignKeyRows = await database
      .customSelect('PRAGMA foreign_key_check;')
      .get();

  if (foreignKeyRows.isNotEmpty) {
    throw StateError(
      'PRAGMA foreign_key_check found violations: '
      '${foreignKeyRows.map((row) => row.data).toList(growable: false)}',
    );
  }
}
