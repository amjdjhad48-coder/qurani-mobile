import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_migrations.dart';

void main() {
  group('AppDatabase migration infrastructure', () {
    test(
      'schemaVersion 5 creates Package 2 through Package 5 tables',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          expect(database.schemaVersion, 5);

          await database.customSelect('SELECT 1;').get();

          final tables = await _userTables(database);

          expect(tables, <String>[
            'attendance_records',
            'halaqah_days',
            'halaqahs',
            'recitations',
            'student_activity_periods',
            'student_progress_plans',
            'students',
            'support_program_periods',
            'support_program_settings',
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

    test('migrates the empty v1 database explicitly to schema v5', () async {
      final executor = NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute('PRAGMA user_version = 1;');
        },
      );

      final database = AppDatabase(executor);

      try {
        await database.customSelect('SELECT 1;').get();

        expect(await _userVersion(database), 5);

        final tables = await _userTables(database);

        expect(tables, contains('halaqahs'));
        expect(tables, contains('students'));
        expect(tables, contains('halaqah_days'));
        expect(tables, contains('attendance_records'));
        expect(tables, contains('recitations'));

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
      } finally {
        await database.close();
      }
    });

    test('migrates schema v2 explicitly to schema v5', () async {
      final executor = NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute(
            'CREATE TABLE halaqahs ('
            'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
            ');',
          );
          rawDatabase.execute('PRAGMA user_version = 2;');
        },
      );

      final database = AppDatabase(executor);

      try {
        await database.customSelect('SELECT 1;').get();

        expect(await _userVersion(database), 5);

        final tables = await _userTables(database);
        expect(tables, contains('students'));
        expect(tables, contains('student_progress_plans'));
        expect(tables, contains('student_activity_periods'));
        expect(tables, contains('halaqah_days'));
        expect(tables, contains('attendance_records'));
        expect(tables, contains('recitations'));

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
      } finally {
        await database.close();
      }
    });

    test('migrates schema v3 explicitly to schema v5', () async {
      final executor = NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute(
            'CREATE TABLE halaqahs ('
            'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
            ');',
          );

          rawDatabase.execute(
            'CREATE TABLE students ('
            'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            'halaqah_id INTEGER NOT NULL, '
            'FOREIGN KEY (halaqah_id) REFERENCES halaqahs(id) '
            'ON DELETE RESTRICT'
            ');',
          );

          rawDatabase.execute('PRAGMA user_version = 3;');
        },
      );

      final database = AppDatabase(executor);

      try {
        await database.customSelect('SELECT 1;').get();

        expect(await _userVersion(database), 5);

        final tables = await _userTables(database);
        expect(tables, contains('halaqah_days'));
        expect(tables, contains('attendance_records'));
        expect(tables, contains('recitations'));

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
      } finally {
        await database.close();
      }
    });

    test('migrates schema v4 explicitly to schema v5', () async {
      final executor = NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute(
            'CREATE TABLE halaqahs ('
            'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
            ');',
          );

          rawDatabase.execute(
            'CREATE TABLE students ('
            'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
            'halaqah_id INTEGER NOT NULL, '
            'FOREIGN KEY (halaqah_id) REFERENCES halaqahs(id) '
            'ON DELETE RESTRICT'
            ');',
          );

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

          rawDatabase.execute('PRAGMA user_version = 4;');
        },
      );

      final database = AppDatabase(executor);

      try {
        await database.customSelect('SELECT 1;').get();

        expect(await _userVersion(database), 5);

        final tables = await _userTables(database);
        expect(tables, contains('recitations'));

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
      } finally {
        await database.close();
      }
    });

    test('schema v5 keeps foreign keys enabled', () async {
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
          strategy.onUpgrade(database.createMigrator(), 5, 6),
          throwsA(isA<StateError>()),
        );
      } finally {
        await database.close();
      }
    });
  });
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
