import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/core/shared/core_providers.dart';

void main() {
  group('Riverpod core providers', () {
    test('provides the production SystemClock by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final clock = container.read(clockProvider);

      expect(clock, isA<SystemClock>());
      expect(clock.nowUtc().isUtc, isTrue);
    });

    test('exposes the static local Quran reference through Riverpod', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final surahs = container.read(quranSurahsProvider);
      final juzs = container.read(quranJuzsProvider);

      expect(surahs, hasLength(114));
      expect(surahs.first.number, 1);
      expect(surahs.last.number, 114);
      expect(juzs, hasLength(30));
      expect(juzs.first.number, 1);
      expect(juzs.last.number, 30);
    });

    test('builds KeyManagement from the overridable keystore bridge', () async {
      final fakeBridge = _FakeKeystoreBridge();

      final container = ProviderContainer(
        overrides: <Override>[
          keystorePlatformBridgeProvider.overrideWithValue(fakeBridge),
        ],
      );
      addTearDown(container.dispose);

      final keyManagement = container.read(keyManagementProvider);
      final info = await keyManagement.ensureMasterKey();

      expect(keyManagement, isA<QuraniKeyManagement>());
      expect(fakeBridge.ensureCalls, 1);
      expect(info.alias, 'QuraniMasterKey');
      expect(info.configuredKeySizeBits, 256);
      expect(info.encodedIsNull, isTrue);
    });

    test('provider override changes only the dependency being overridden', () {
      final fakeClock = _FixedClock();

      final container = ProviderContainer(
        overrides: <Override>[clockProvider.overrideWithValue(fakeClock)],
      );
      addTearDown(container.dispose);

      expect(identical(container.read(clockProvider), fakeClock), isTrue);
      expect(container.read(quranSurahsProvider), hasLength(114));
      expect(container.read(quranJuzsProvider), hasLength(30));
    });
  });
}

final class _FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 3, 8, 0);

  @override
  DateTime todayLocal() => DateTime(2026, 9, 3);
}

final class _FakeKeystoreBridge implements KeystorePlatformBridge {
  int ensureCalls = 0;

  @override
  Future<KeystoreMasterKeyInfo> ensureMasterKey() async {
    ensureCalls += 1;
    return const KeystoreMasterKeyInfo(
      alias: 'QuraniMasterKey',
      aliasExists: true,
      algorithm: 'AES',
      configuredKeySizeBits: 256,
      transformation: 'AES/GCM/NoPadding',
      encodedIsNull: true,
      userAuthenticationRequired: false,
    );
  }

  @override
  Future<Uint8List> unwrap({
    required KeystoreOuterEnvelope envelope,
    required Uint8List aad,
  }) {
    throw UnimplementedError('Not needed by the provider wiring test.');
  }

  @override
  Future<KeystoreOuterEnvelope> wrap({
    required Uint8List plaintext,
    required Uint8List aad,
  }) {
    throw UnimplementedError('Not needed by the provider wiring test.');
  }
}
