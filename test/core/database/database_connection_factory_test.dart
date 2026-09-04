import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/database_connection_factory.dart';

void main() {
  group('DatabaseConnectionFactory', () {
    test('accepts exactly a 256-bit DatabaseKey', () {
      final key = Uint8List(DatabaseConnectionFactory.databaseKeyBytes);

      expect(
        () => DatabaseConnectionFactory.validateDatabaseKey(key),
        returnsNormally,
      );
    });

    test('rejects a DatabaseKey that is not 32 bytes', () {
      final key = Uint8List(DatabaseConnectionFactory.databaseKeyBytes - 1);

      expect(
        () => DatabaseConnectionFactory.validateDatabaseKey(key),
        throwsArgumentError,
      );
    });

    test('uses the approved ChaCha20 cipher identifier', () {
      expect(DatabaseConnectionFactory.cipherName, 'chacha20');
    });
  });
}
