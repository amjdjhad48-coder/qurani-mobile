import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_migrations.dart';

void main() {
  group('AppDatabase migration infrastructure', () {
    test('schemaVersion 3 creates Package 2 and Package 3 tables', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await database.customSelect('SELECT 1;').get();

        expect(database.schemaVersion, 3);
        expect(await _userTables(database), <String>[
          'halaqahs',
          'student_activity_periods',
          'student_progress_plans',
          'students',
          'support_program_periods',
          'support_program_settings',
        ]);
      } finally {
        await database.close();
      }
    });

    test('migrates the empty v1 database explicitly to schema v3', () async {
      final executor = NativeDatabase.memory(
        setup: (rawDatabase) {
          rawDatabase.execute('PRAGMA user_version = 1;');
        },
      );

      final database = AppDatabase(executor);

      try {
        await database.customSelect('SELECT 1;').get();

        final userVersion = await database
            .customSelect('PRAGMA user_version;')
            .get();

        expect(userVersion, hasLength(1));
        expect(userVersion.single.data.values.single, 3);

        expect(await _userTables(database), <String>[
          'halaqahs',
          'student_activity_periods',
          'student_progress_plans',
          'students',
          'support_program_periods',
          'support_program_settings',
        ]);

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
      } finally {
        await database.close();
      }
    });

    test('migrates schema v2 explicitly to schema v3', () async {
      final package2Sql = await _readPackage2CreateSql();

      final executor = NativeDatabase.memory(
        setup: (rawDatabase) {
          for (final sql in package2Sql) {
            rawDatabase.execute(sql);
          }
          rawDatabase.execute('PRAGMA user_version = 2;');
        },
      );

      final database = AppDatabase(executor);

      try {
        await database.customSelect('SELECT 1;').get();

        final userVersion = await database
            .customSelect('PRAGMA user_version;')
            .get();

        expect(userVersion.single.data.values.single, 3);

        expect(await _userTables(database), <String>[
          'halaqahs',
          'student_activity_periods',
          'student_progress_plans',
          'students',
          'support_program_periods',
          'support_program_settings',
        ]);

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
      } finally {
        await database.close();
      }
    });

    test('schema v3 keeps foreign keys enabled', () async {
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
          strategy.onUpgrade(database.createMigrator(), 3, 4),
          throwsA(isA<StateError>()),
        );
      } finally {
        await database.close();
      }
    });
  });
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

Future<List<String>> _readPackage2CreateSql() async {
  final database = AppDatabase(NativeDatabase.memory());

  try {
    await database.customSelect('SELECT 1;').get();

    const tables = <String>[
      'halaqahs',
      'support_program_periods',
      'support_program_settings',
    ];

    final placeholders = List<String>.filled(tables.length, '?').join(',');

    final rows = await database
        .customSelect(
          "SELECT sql FROM sqlite_master "
          "WHERE type = 'table' "
          "AND name IN ($placeholders) "
          "ORDER BY name;",
          variables: <Variable<Object>>[
            for (final table in tables) Variable<String>(table),
          ],
        )
        .get();

    expect(rows, hasLength(3));

    return rows.map((row) => row.read<String>('sql')).toList(growable: false);
  } finally {
    await database.close();
  }
}
