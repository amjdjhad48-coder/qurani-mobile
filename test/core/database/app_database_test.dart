import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_migrations.dart';

void main() {
  group('AppDatabase migration infrastructure', () {
    test(
      'schemaVersion 7 creates Package 2 through Package 7 tables',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          expect(database.schemaVersion, 7);

          await database.customSelect('SELECT 1;').get();

          final tables = await _userTables(database);

          expect(tables, <String>[
            'attendance_records',
            'halaqah_days',
            'halaqahs',
            'parent_follow_ups',
            'recitations',
            'student_activity_periods',
            'student_progress_plans',
            'students',
            'support_monthly_report_students',
            'support_monthly_reports',
            'support_program_periods',
            'support_program_settings',
            'support_weekly_report_day_entries',
            'support_weekly_report_days',
            'support_weekly_report_students',
            'support_weekly_reports',
          ]);

          await expectLater(
            verifyDatabaseAfterSchemaChange(database),
            completes,
          );
        } finally {
          await database.close();
        }
      },
    );

    for (final version in <int>[1, 2, 3, 4, 5, 6]) {
      test('migrates schema v$version explicitly to schema v7', () async {
        final executor = _legacyExecutor(version);
        final database = AppDatabase(executor);

        try {
          await database.customSelect('SELECT 1;').get();

          expect(await _userVersion(database), 7);

          final tables = await _userTables(database);

          expect(tables, contains('parent_follow_ups'));
          expect(tables, contains('support_weekly_reports'));
          expect(tables, contains('support_monthly_reports'));

          if (version <= 4) {
            expect(tables, contains('recitations'));
          }

          await expectLater(
            verifyDatabaseAfterSchemaChange(database),
            completes,
          );
        } finally {
          await database.close();
        }
      });
    }

    test('schema v7 keeps foreign keys enabled', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await database.customSelect('SELECT 1;').get();

        final foreignKeys = await database
            .customSelect('PRAGMA foreign_keys;')
            .get();

        expect(foreignKeys, hasLength(1));
        expect(foreignKeys.single.data.values.single, 1);
      } finally {
        await database.close();
      }
    });

    test('unknown future migration paths still fail explicitly', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final strategy = database.migration;

        await expectLater(
          strategy.onUpgrade(database.createMigrator(), 7, 8),
          throwsA(isA<StateError>()),
        );
      } finally {
        await database.close();
      }
    });
  });
}

NativeDatabase _legacyExecutor(int version) {
  return NativeDatabase.memory(
    setup: (rawDatabase) {
      rawDatabase.execute('PRAGMA foreign_keys = ON;');

      if (version >= 2) {
        rawDatabase.execute(
          'CREATE TABLE halaqahs ('
          'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
          ');',
        );
      }

      if (version >= 3) {
        rawDatabase.execute(
          'CREATE TABLE students ('
          'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          'halaqah_id INTEGER NOT NULL, '
          'FOREIGN KEY (halaqah_id) REFERENCES halaqahs(id) '
          'ON DELETE RESTRICT'
          ');',
        );
      }

      if (version >= 4) {
        rawDatabase.execute(
          'CREATE TABLE halaqah_days ('
          'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          'halaqah_id INTEGER NOT NULL, '
          'day_date TEXT NOT NULL, '
          'status TEXT NOT NULL, '
          'FOREIGN KEY (halaqah_id) REFERENCES halaqahs(id) '
          'ON DELETE RESTRICT'
          ');',
        );

        rawDatabase.execute(
          'CREATE TABLE attendance_records ('
          'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          'day_id INTEGER NOT NULL, '
          'student_id INTEGER NOT NULL, '
          'status TEXT NOT NULL, '
          'FOREIGN KEY (day_id) REFERENCES halaqah_days(id) '
          'ON DELETE RESTRICT, '
          'FOREIGN KEY (student_id) REFERENCES students(id) '
          'ON DELETE RESTRICT'
          ');',
        );
      }

      if (version >= 5) {
        rawDatabase.execute(
          'CREATE TABLE recitations ('
          'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          'day_id INTEGER NOT NULL, '
          'student_id INTEGER NOT NULL, '
          'FOREIGN KEY (day_id) REFERENCES halaqah_days(id) '
          'ON DELETE RESTRICT, '
          'FOREIGN KEY (student_id) REFERENCES students(id) '
          'ON DELETE RESTRICT'
          ');',
        );
      }

      if (version >= 6) {
        rawDatabase.execute(
          'CREATE TABLE parent_follow_ups ('
          'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
          'day_id INTEGER NOT NULL, '
          'student_id INTEGER NOT NULL, '
          'type TEXT NOT NULL, '
          "status TEXT NOT NULL DEFAULT 'pending', "
          'corrects_follow_up_id INTEGER NULL, '
          'attendance_status_snapshot TEXT NULL, '
          'snapshot_message TEXT NULL, '
          'channel_snapshot TEXT NULL, '
          'recipient_snapshot TEXT NULL, '
          'FOREIGN KEY (day_id) REFERENCES halaqah_days(id) '
          'ON DELETE RESTRICT, '
          'FOREIGN KEY (student_id) REFERENCES students(id) '
          'ON DELETE RESTRICT, '
          'FOREIGN KEY (corrects_follow_up_id) '
          'REFERENCES parent_follow_ups(id) ON DELETE RESTRICT'
          ');',
        );
      }
      rawDatabase.execute('PRAGMA user_version = $version;');
    },
  );
}

Future<int> _userVersion(AppDatabase database) async {
  final rows = await database.customSelect('PRAGMA user_version;').get();

  return rows.single.data.values.single as int;
}

Future<List<String>> _userTables(AppDatabase database) async {
  final rows = await database
      .customSelect(
        "SELECT name FROM sqlite_master "
        "WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' "
        "ORDER BY name;",
      )
      .get();

  return rows.map((row) => row.read<String>('name')).toList(growable: false);
}
