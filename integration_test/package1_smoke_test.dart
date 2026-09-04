import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurani/bootstrap/qurani_bootstrap.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/database/database_connection_factory.dart';
import 'package:qurani/core/database/database_migrations.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/shared/core_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Package 1 production core smoke on Android', (tester) async {
    await tester.pumpWidget(const QuraniRoot());
    await tester.pumpAndSettle();

    expect(find.text('قرآني'), findsOneWidget);
    debugPrint('QURANI_P1_09_BOOTSTRAP_UI=PASS');

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(quranSurahsProvider), hasLength(114));
    expect(container.read(quranJuzsProvider), hasLength(30));
    expect(container.read(clockProvider).nowUtc().isUtc, isTrue);
    debugPrint('QURANI_P1_09_RIVERPOD_CORE=PASS');

    final keyManagement = container.read(keyManagementProvider);
    final masterInfo = await keyManagement.ensureMasterKey();

    expect(masterInfo.alias, 'QuraniMasterKey');
    expect(masterInfo.aliasExists, isTrue);
    expect(masterInfo.algorithm, 'AES');
    expect(masterInfo.configuredKeySizeBits, 256);
    expect(masterInfo.transformation, 'AES/GCM/NoPadding');
    expect(masterInfo.encodedIsNull, isTrue);
    expect(masterInfo.userAuthenticationRequired, isFalse);
    debugPrint('QURANI_P1_09_ANDROID_KEYSTORE=PASS');

    final databaseKey = keyManagement.generateRandomKey();
    final envelope = await keyManagement.wrapKey(
      purpose: KeyPurpose.databaseKey,
      rawKey: databaseKey,
      pin: '482731',
    );
    final recoveredKey = await keyManagement.unwrapKey(
      envelope: envelope,
      pin: '482731',
    );

    expect(recoveredKey, orderedEquals(databaseKey));
    debugPrint('QURANI_P1_09_KEY_WRAP_ROUNDTRIP=PASS');

    final supportDirectory = await getApplicationSupportDirectory();
    final temporaryDirectory = await getTemporaryDirectory();
    final databaseFile = File(
      '${supportDirectory.path}${Platform.pathSeparator}'
      'package1_android_smoke.sqlite',
    );

    for (final entity in supportDirectory.listSync()) {
      if (entity is File &&
          entity.path.contains('package1_android_smoke.sqlite')) {
        await entity.delete();
      }
    }

    final database = AppDatabase(
      DatabaseConnectionFactory.openEncrypted(
        databaseFile: databaseFile,
        databaseKey: recoveredKey,
        tempDirectoryPath: temporaryDirectory.path,
      ),
    );

    try {
      final userVersion = await database
          .customSelect('PRAGMA user_version;')
          .get();
      expect(userVersion, hasLength(1));
      expect(userVersion.single.data.values.single, 1);

      final foreignKeys = await database
          .customSelect('PRAGMA foreign_keys;')
          .get();
      expect(foreignKeys, hasLength(1));
      expect(foreignKeys.single.data.values.single, 1);

      await expectLater(verifyDatabaseAfterSchemaChange(database), completes);
    } finally {
      await database.close();
    }

    expect(await databaseFile.exists(), isTrue);
    expect(await databaseFile.length(), greaterThan(16));

    final firstBytes = await databaseFile.openRead(0, 16).expand((chunk) {
      return chunk;
    }).toList();

    expect(firstBytes, hasLength(16));
    expect(
      latin1.decode(firstBytes, allowInvalid: true),
      isNot('SQLite format 3\u0000'),
      reason:
          'The production database file must not expose a plain SQLite header.',
    );

    debugPrint('QURANI_P1_09_ENCRYPTED_DATABASE=PASS');

    for (final entity in supportDirectory.listSync()) {
      if (entity is File &&
          entity.path.contains('package1_android_smoke.sqlite')) {
        await entity.delete();
      }
    }

    debugPrint('QURANI_P1_09_ANDROID_SMOKE=PASS');
  });
}
