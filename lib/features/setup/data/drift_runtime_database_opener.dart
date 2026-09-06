import 'dart:io';
import 'dart:typed_data';

import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_connection_factory.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';

final class DriftRuntimeDatabaseHandle implements RuntimeDatabaseHandle {
  DriftRuntimeDatabaseHandle(this.database);

  final AppDatabase database;

  @override
  Future<void> close() {
    return database.close();
  }
}

final class DriftRuntimeDatabaseOpener implements RuntimeDatabaseOpener {
  const DriftRuntimeDatabaseOpener({
    required this.finalDatabaseFile,
    required this.tempDirectoryPath,
  });

  final File finalDatabaseFile;
  final String tempDirectoryPath;

  @override
  Future<RuntimeDatabaseHandle> open({required Uint8List databaseKey}) async {
    if (!await finalDatabaseFile.exists()) {
      throw StateError(
        'Published Qurani database does not exist for runtime unlock.',
      );
    }

    final database = AppDatabase(
      DatabaseConnectionFactory.openEncrypted(
        databaseFile: finalDatabaseFile,
        databaseKey: databaseKey,
        tempDirectoryPath: tempDirectoryPath,
      ),
    );

    try {
      final userVersionRows = await database
          .customSelect('PRAGMA user_version;')
          .get();

      if (userVersionRows.length != 1) {
        throw StateError('Unable to read runtime database schema version.');
      }

      final userVersion = userVersionRows.single.data.values.single;
      if (userVersion != database.schemaVersion) {
        throw StateError(
          'Unexpected runtime database schema version: $userVersion.',
        );
      }

      await database.customSelect('SELECT 1;').get();

      return DriftRuntimeDatabaseHandle(database);
    } catch (_) {
      await database.close();
      rethrow;
    }
  }
}
