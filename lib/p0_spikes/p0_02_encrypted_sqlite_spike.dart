import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

part 'p0_02_encrypted_sqlite_spike.g.dart';

class P002ProbeRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get payload => text()();
}

@DriftDatabase(tables: [P002ProbeRecords])
class P002SpikeDatabase extends _$P002SpikeDatabase {
  P002SpikeDatabase({
    required File file,
    required String rawKeyHex,
    required String tempDirectoryPath,
  }) : super(
         _openEncrypted(
           file: file,
           rawKeyHex: rawKeyHex,
           tempDirectoryPath: tempDirectoryPath,
         ),
       );

  @override
  int get schemaVersion => 1;

  Future<int> insertProbe(String payload) {
    return into(
      p002ProbeRecords,
    ).insert(P002ProbeRecordsCompanion.insert(payload: payload));
  }

  Future<List<String>> readPayloads() async {
    final rows = await select(p002ProbeRecords).get();

    return rows.map((row) => row.payload).toList(growable: false);
  }

  static QueryExecutor _openEncrypted({
    required File file,
    required String rawKeyHex,
    required String tempDirectoryPath,
  }) {
    _validateRawKey(rawKeyHex);

    return NativeDatabase.createInBackground(
      file,
      isolateSetup: () {
        sqlite.sqlite3.tempDirectory = tempDirectoryPath;
      },
      setup: (rawDb) {
        final cipherAvailability = rawDb.select('PRAGMA cipher;');

        if (cipherAvailability.isEmpty) {
          throw StateError('SQLite3MultipleCiphers is not available.');
        }

        rawDb.execute("PRAGMA cipher = 'chacha20';");

        final configuredCipher = rawDb.select('PRAGMA cipher;');

        if (configuredCipher.isEmpty) {
          throw StateError('Unable to read configured cipher.');
        }

        final cipherName = configuredCipher.rows.first.first
            ?.toString()
            .toLowerCase();

        if (cipherName != 'chacha20') {
          throw StateError('Unexpected cipher: $cipherName');
        }

        rawDb.execute("PRAGMA key = 'raw:$rawKeyHex';");
      },
    );
  }

  static void _validateRawKey(String rawKeyHex) {
    final validRawKey = RegExp(r'^[0-9a-fA-F]{64}$');

    if (!validRawKey.hasMatch(rawKeyHex)) {
      throw ArgumentError.value(
        rawKeyHex,
        'rawKeyHex',
        'Expected exactly 32 bytes encoded as 64 hex characters.',
      );
    }
  }
}
