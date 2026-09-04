import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

final class DatabaseConnectionFactory {
  const DatabaseConnectionFactory._();

  static const int databaseKeyBytes = 32;
  static const String cipherName = 'chacha20';

  static QueryExecutor openEncrypted({
    required File databaseFile,
    required Uint8List databaseKey,
    required String tempDirectoryPath,
  }) {
    validateDatabaseKey(databaseKey);

    if (databaseFile.path.trim().isEmpty) {
      throw ArgumentError.value(
        databaseFile.path,
        'databaseFile.path',
        'Database path must not be empty.',
      );
    }

    if (tempDirectoryPath.trim().isEmpty) {
      throw ArgumentError.value(
        tempDirectoryPath,
        'tempDirectoryPath',
        'Temporary directory path must not be empty.',
      );
    }

    final rawKeyHex = _hexEncode(databaseKey);

    return NativeDatabase.createInBackground(
      databaseFile,
      isolateSetup: () {
        sqlite.sqlite3.tempDirectory = tempDirectoryPath;
      },
      setup: (rawDb) {
        final cipherAvailability = rawDb.select('PRAGMA cipher;');

        if (cipherAvailability.isEmpty) {
          throw StateError('SQLite3MultipleCiphers is not available.');
        }

        rawDb.execute("PRAGMA cipher = '$cipherName';");

        final configuredCipher = rawDb.select('PRAGMA cipher;');
        if (configuredCipher.isEmpty) {
          throw StateError('Unable to read configured SQLite cipher.');
        }

        final configuredName = configuredCipher.rows.first.first
            ?.toString()
            .toLowerCase();

        if (configuredName != cipherName) {
          throw StateError('Unexpected SQLite cipher: $configuredName');
        }

        rawDb.execute("PRAGMA key = 'raw:$rawKeyHex';");
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }

  static void validateDatabaseKey(Uint8List databaseKey) {
    if (databaseKey.length != databaseKeyBytes) {
      throw ArgumentError.value(
        databaseKey.length,
        'databaseKey.length',
        'DatabaseKey must be exactly 32 bytes / 256 bits.',
      );
    }
  }

  static String _hexEncode(Uint8List bytes) {
    final buffer = StringBuffer();

    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }

    return buffer.toString();
  }
}
