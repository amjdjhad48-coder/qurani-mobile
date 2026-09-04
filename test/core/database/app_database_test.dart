import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_migrations.dart';

void main() {
  group('AppDatabase migration infrastructure', () {
    test('starts with schemaVersion 1 and no product/dummy tables', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        expect(database.schemaVersion, 1);

        final userTables = await database
            .customSelect(
              "SELECT name FROM sqlite_master "
              "WHERE type = 'table' "
              "AND name NOT LIKE 'sqlite_%' "
              "ORDER BY name;",
            )
            .get();

        expect(
          userTables,
          isEmpty,
          reason: 'Package 1 must not create product tables or a dummy table.',
        );
      } finally {
        await database.close();
      }
    });

    test('initial schema passes integrity and foreign-key checks', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await database.customSelect('SELECT 1;').get();

        await expectLater(verifyDatabaseAfterSchemaChange(database), completes);

        final foreignKeys = await database
            .customSelect('PRAGMA foreign_keys;')
            .get();

        expect(foreignKeys, hasLength(1));
        expect(foreignKeys.single.data.values.single, 1);
      } finally {
        await database.close();
      }
    });

    test('unknown future migration paths fail explicitly', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final strategy = database.migration;

        await expectLater(
          strategy.onUpgrade(database.createMigrator(), 1, 2),
          throwsA(isA<StateError>()),
        );
      } finally {
        await database.close();
      }
    });
  });
}
