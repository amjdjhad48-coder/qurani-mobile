import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/core/security/android_keystore_bridge.dart';
import 'package:qurani/core/security/key_management.dart';
import 'package:qurani/core/shared/clock.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final keystorePlatformBridgeProvider = Provider<KeystorePlatformBridge>(
  (ref) => AndroidKeystoreBridge(),
);

final keyManagementProvider = Provider<KeyManagement>(
  (ref) => QuraniKeyManagement(
    keystoreBridge: ref.watch(keystorePlatformBridgeProvider),
  ),
);

final quranSurahsProvider = Provider<List<QuranSurahReference>>(
  (ref) => QuranReferenceData.surahs,
);

final quranJuzsProvider = Provider<List<QuranJuzReference>>(
  (ref) => QuranReferenceData.juzs,
);
