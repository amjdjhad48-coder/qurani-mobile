import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qurani/p0_spikes/p0_04_long_audio_spike.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'P0-04 forced crash preserves recoverable audio',
    (_) async {
      final spike = P004LongAudioSpike();

      expect(await spike.isAacLcSupported(), isTrue);
      debugPrint('P0_04_CRASH_AAC_LC_SUPPORTED=PASS');

      await spike.start();

      final sessionDir = spike.sessionDirectory;
      final rootDir = Directory(sessionDir).parent.path;
      final pointer = File('$rootDir/crash_session_pointer.txt');
      final ready = File('$rootDir/crash_proof_ready.txt');

      await pointer.writeAsString(sessionDir, flush: true);

      debugPrint('P0_04_CRASH_SESSION_DIR=$sessionDir');
      debugPrint('P0_04_CRASH_RECORDING_STARTED=PASS');

      // Keep the approved ~1 MiB checkpoint size and record long enough
      // to guarantee at least one sealed checkpoint at the target bitrate.
      await Future<void>.delayed(const Duration(seconds: 145));

      final sealedBeforeCrash = spike.parts
          .where((part) => part.sealed && part.bytes > 0)
          .length;

      expect(sealedBeforeCrash, greaterThanOrEqualTo(1));

      debugPrint('P0_04_CRASH_SEALED_PARTS=$sealedBeforeCrash');
      debugPrint('P0_04_CRASH_CHECKPOINT_BEFORE_KILL=PASS');

      await spike.prepareCrashProof();

      final manifest = File('${spike.sessionDirectory}/session.json');
      expect(await manifest.exists(), isTrue);

      final manifestText = await manifest.readAsString();
      expect(manifestText, contains('recording_before_forced_crash'));

      await ready.writeAsString(
        'P0_04_CRASH_PROOF_READY\n$sessionDir\n',
        flush: true,
      );

      debugPrint('P0_04_CRASH_MANIFEST_FLUSHED=PASS');
      debugPrint('P0_04_CRASH_ARMED=PASS');

      // The native bridge returns first, then kills the Android process.
      // The test command is therefore expected to terminate abnormally.
      await spike.killProcessForCrashTest();

      await Future<void>.delayed(const Duration(seconds: 15));

      fail('Android process was expected to be killed.');
    },
    timeout: const Timeout(Duration(minutes: 6)),
  );
}
