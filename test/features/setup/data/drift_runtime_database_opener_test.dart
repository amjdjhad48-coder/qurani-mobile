import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_connection_factory.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';

void main() {
  group('DriftRuntimeDatabaseOpener', () {
    test(
      'opens the published encrypted qurani.db with the correct DatabaseKey',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p2_07_runtime_db_',
        );
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        final file = File('${root.path}${Platform.pathSeparator}qurani.db');
        final key = Uint8List.fromList(
          List<int>.generate(32, (index) => index + 1),
        );

        final bootstrapDatabase = AppDatabase(
          DatabaseConnectionFactory.openEncrypted(
            databaseFile: file,
            databaseKey: key,
            tempDirectoryPath: root.path,
          ),
        );

        await bootstrapDatabase.customSelect('SELECT 1;').get();
        await bootstrapDatabase.close();

        final opener = DriftRuntimeDatabaseOpener(
          finalDatabaseFile: file,
          tempDirectoryPath: root.path,
        );

        final handle = await opener.open(databaseKey: key);
        expect(handle, isA<DriftRuntimeDatabaseHandle>());

        final driftHandle = handle as DriftRuntimeDatabaseHandle;
        expect(driftHandle.database.schemaVersion, 3);

        final versionRows = await driftHandle.database
            .customSelect('PRAGMA user_version;')
            .get();
        expect(versionRows.single.data.values.single, 3);

        await handle.close();
      },
    );

    test(
      'wrong DatabaseKey cannot open the published encrypted database',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p2_07_wrong_key_',
        );
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        final file = File('${root.path}${Platform.pathSeparator}qurani.db');
        final correctKey = Uint8List.fromList(List<int>.filled(32, 5));
        final wrongKey = Uint8List.fromList(List<int>.filled(32, 6));

        final bootstrapDatabase = AppDatabase(
          DatabaseConnectionFactory.openEncrypted(
            databaseFile: file,
            databaseKey: correctKey,
            tempDirectoryPath: root.path,
          ),
        );
        await bootstrapDatabase.customSelect('SELECT 1;').get();
        await bootstrapDatabase.close();

        final opener = DriftRuntimeDatabaseOpener(
          finalDatabaseFile: file,
          tempDirectoryPath: root.path,
        );

        await expectLater(
          opener.open(databaseKey: wrongKey),
          throwsA(anything),
        );
      },
    );

    test(
      'refuses a missing final database instead of creating a new one',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p2_07_missing_db_',
        );
        addTearDown(() async {
          if (await root.exists()) {
            await root.delete(recursive: true);
          }
        });

        final file = File('${root.path}${Platform.pathSeparator}qurani.db');
        final opener = DriftRuntimeDatabaseOpener(
          finalDatabaseFile: file,
          tempDirectoryPath: root.path,
        );

        await expectLater(
          opener.open(databaseKey: Uint8List.fromList(List<int>.filled(32, 4))),
          throwsStateError,
        );

        expect(await file.exists(), isFalse);
      },
    );
  });
}
