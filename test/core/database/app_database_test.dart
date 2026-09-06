import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_migrations.dart';

void main() {
  group('AppDatabase migration infrastructure', () {
    test('schemaVersion 2 creates only the Package 2 setup tables', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        expect(database.schemaVersion, 2);

        final userTables = await database
            .customSelect(
              "SELECT name FROM sqlite_master "
              "WHERE type = 'table' "
              "AND name NOT LIKE 'sqlite_%' "
              "ORDER BY name;",
            )
            .get();

        expect(
          userTables.map((row) => row.read<String>('name')).toList(),
          <String>[
            'halaqahs',
            'support_program_periods',
            'support_program_settings',
          ],
        );
      } finally {
        await database.close();
      }
    });

    test('migrates the empty v1 database explicitly to schema v2', () async {
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
        expect(userVersion.single.data.values.single, 2);

        final userTables = await database
            .customSelect(
              "SELECT name FROM sqlite_master "
              "WHERE type = 'table' "
              "AND name NOT LIKE 'sqlite_%' "
              "ORDER BY name;",
            )
            .get();

        expect(
          userTables.map((row) => row.read<String>('name')).toList(),
          <String>[
            'halaqahs',
            'support_program_periods',
            'support_program_settings',
          ],
        );

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
      } finally {
        await database.close();
      }
    });

    test('schema v2 keeps foreign keys enabled', () async {
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
          strategy.onUpgrade(database.createMigrator(), 2, 3),
          throwsA(isA<StateError>()),
        );
      } finally {
        await database.close();
      }
    });
  });
}
