import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';

MigrationStrategy buildAppDatabaseMigrationStrategy(AppDatabase database) {
  return MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from == to) {
        return;
      }

      if (from == 1 && to == 2) {
        await migrator.createTable(database.halaqahs);
        await migrator.createTable(database.supportProgramSettings);
        await migrator.createTable(database.supportProgramPeriods);
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
