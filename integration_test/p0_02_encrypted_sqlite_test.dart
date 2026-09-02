import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurani/p0_spikes/p0_02_encrypted_sqlite_spike.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const correctRawKeyHex =
      '00112233445566778899AABBCCDDEEFF'
      '00112233445566778899AABBCCDDEEFF';

  const wrongRawKeyHex =
      'FFEEDDCCBBAA99887766554433221100'
      'FFEEDDCCBBAA99887766554433221100';

  const sentinel = 'QURANI_P0_02_ENCRYPTION_SENTINEL_20260830';

  testWidgets('P0-02 proves Drift with SQLite3MultipleCiphers encryption', (
    tester,
  ) async {
    final temporaryDirectory = await getTemporaryDirectory();

    sqlite.sqlite3.tempDirectory = temporaryDirectory.path;

    final rawCipherProbe = sqlite.sqlite3.openInMemory();

    try {
      final cipherAvailability = rawCipherProbe.select('PRAGMA cipher;');

      expect(
        cipherAvailability,
        isNotEmpty,
        reason:
            'PRAGMA cipher must exist when SQLite3MultipleCiphers is bundled.',
      );

      rawCipherProbe.execute("PRAGMA cipher = 'chacha20';");

      final configuredCipher = rawCipherProbe.select('PRAGMA cipher;');

      expect(configuredCipher, isNotEmpty);

      final cipherName = configuredCipher.rows.first.first
          ?.toString()
          .toLowerCase();

      expect(cipherName, 'chacha20');

      debugPrint('P0_02_CIPHER_AVAILABLE=PASS');

      debugPrint('P0_02_CIPHER_SELECTED=$cipherName');
    } finally {
      rawCipherProbe.close();
    }

    final supportDirectory = await getApplicationSupportDirectory();

    final spikeDirectory = Directory(
      '${supportDirectory.path}'
      '${Platform.pathSeparator}'
      'qurani_p0_spikes',
    );

    await spikeDirectory.create(recursive: true);

    final databaseFile = File(
      '${spikeDirectory.path}'
      '${Platform.pathSeparator}'
      'p0_02_encrypted.sqlite',
    );

    await _deleteDatabaseFamily(databaseFile);

    P002SpikeDatabase? database;

    try {
      database = P002SpikeDatabase(
        file: databaseFile,
        rawKeyHex: correctRawKeyHex,
        tempDirectoryPath: temporaryDirectory.path,
      );

      final insertedId = await database.insertProbe(sentinel);

      expect(insertedId, greaterThan(0));

      final payloads = await database.readPayloads();

      expect(payloads, contains(sentinel));

      debugPrint('P0_02_WRITE_READ=PASS');
    } finally {
      await database?.close();
    }

    P002SpikeDatabase? correctReopen;

    try {
      correctReopen = P002SpikeDatabase(
        file: databaseFile,
        rawKeyHex: correctRawKeyHex,
        tempDirectoryPath: temporaryDirectory.path,
      );

      final reopenedPayloads = await correctReopen.readPayloads();

      expect(reopenedPayloads, contains(sentinel));

      debugPrint('P0_02_CORRECT_KEY_REOPEN=PASS');
    } finally {
      await correctReopen?.close();
    }

    Object? wrongKeyError;
    P002SpikeDatabase? wrongKeyDatabase;

    try {
      wrongKeyDatabase = P002SpikeDatabase(
        file: databaseFile,
        rawKeyHex: wrongRawKeyHex,
        tempDirectoryPath: temporaryDirectory.path,
      );

      await wrongKeyDatabase.readPayloads();
    } catch (error) {
      wrongKeyError = error;

      debugPrint(
        'P0_02_WRONG_KEY_ERROR='
        '${error.runtimeType}: $error',
      );
    } finally {
      if (wrongKeyDatabase != null) {
        try {
          await wrongKeyDatabase.close();
        } catch (_) {
          // The connection may already be unusable because
          // opening with the wrong key is expected to fail.
        }
      }
    }

    expect(
      wrongKeyError,
      isNotNull,
      reason: 'A real query with the wrong key must fail.',
    );

    debugPrint('P0_02_WRONG_KEY_QUERY_FAILURE=PASS');

    expect(await databaseFile.exists(), isTrue);

    final databaseBytes = await databaseFile.readAsBytes();

    final sentinelBytes = utf8.encode(sentinel);

    final containsPlainSentinel = _containsByteSequence(
      databaseBytes,
      sentinelBytes,
    );

    expect(
      containsPlainSentinel,
      isFalse,
      reason:
          'The plaintext sentinel must not appear in the encrypted database file.',
    );

    debugPrint('P0_02_RAW_SENTINEL_ABSENT=PASS');

    debugPrint('P0_02_DATABASE_PATH=${databaseFile.path}');

    debugPrint('P0_02_DATABASE_BYTES=${databaseBytes.length}');

    debugPrint('QURANI_P0_02_ENCRYPTED_SQLITE_PROOF_OK');
  });
}

Future<void> _deleteDatabaseFamily(File databaseFile) async {
  final candidatePaths = <String>[
    databaseFile.path,
    '${databaseFile.path}-wal',
    '${databaseFile.path}-shm',
    '${databaseFile.path}-journal',
  ];

  for (final candidatePath in candidatePaths) {
    final candidateFile = File(candidatePath);

    if (await candidateFile.exists()) {
      await candidateFile.delete();
    }
  }
}

bool _containsByteSequence(List<int> source, List<int> target) {
  if (target.isEmpty) {
    return true;
  }

  if (target.length > source.length) {
    return false;
  }

  final lastStart = source.length - target.length;

  for (var start = 0; start <= lastStart; start++) {
    var matches = true;

    for (var offset = 0; offset < target.length; offset++) {
      if (source[start + offset] != target[offset]) {
        matches = false;
        break;
      }
    }

    if (matches) {
      return true;
    }
  }

  return false;
}
