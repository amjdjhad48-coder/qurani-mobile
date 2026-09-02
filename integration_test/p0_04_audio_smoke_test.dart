import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qurani/p0_spikes/p0_04_long_audio_spike.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'P0-04 records AAC checkpoints, pause/resume, and valid M4A',
    (_) async {
      final spike = P004LongAudioSpike();

      try {
        final supported = await spike.isAacLcSupported();
        expect(supported, isTrue);
        debugPrint('P0_04_AAC_LC_STREAM_SUPPORTED=PASS');

        await spike.start();
        debugPrint('P0_04_RECORDING_STARTED=PASS');
        debugPrint('P0_04_SESSION_DIR=${spike.sessionDirectory}');

        // Long enough at the target 64 kbps to cross the ~1 MiB checkpoint.
        await Future<void>.delayed(const Duration(seconds: 140));

        expect(spike.parts.where((part) => part.sealed).isNotEmpty, isTrue);
        debugPrint('P0_04_INCREMENTAL_CHECKPOINT=PASS');

        final partsBeforePause = spike.parts.length;

        await spike.pause();
        expect(spike.isPaused, isTrue);
        expect(spike.parts.where((part) => part.sealed).isNotEmpty, isTrue);
        debugPrint('P0_04_PAUSE_SEALS_PART=PASS');

        await Future<void>.delayed(const Duration(seconds: 3));

        await spike.resume();
        expect(spike.isPaused, isFalse);

        await Future<void>.delayed(const Duration(seconds: 25));

        expect(spike.parts.length, greaterThan(partsBeforePause));
        debugPrint('P0_04_RESUME_NEW_PART=PASS');

        final finalAudio = await spike.stopAndFinalize();

        expect(File(finalAudio.path).existsSync(), isTrue);
        expect(finalAudio.bytes, greaterThan(0));
        expect(finalAudio.mime, 'audio/mp4a-latm');
        expect(finalAudio.sampleRate, 44100);
        expect(finalAudio.channelCount, 1);
        expect(finalAudio.partCount, greaterThanOrEqualTo(2));

        debugPrint('P0_04_FINAL_PATH=${finalAudio.path}');
        debugPrint('P0_04_FINAL_BYTES=${finalAudio.bytes}');
        debugPrint('P0_04_FINAL_MIME=${finalAudio.mime}');
        debugPrint('P0_04_FINAL_SAMPLE_RATE=${finalAudio.sampleRate}');
        debugPrint('P0_04_FINAL_CHANNELS=${finalAudio.channelCount}');
        debugPrint('P0_04_FINAL_DURATION_US=${finalAudio.durationUs}');
        debugPrint('P0_04_FINAL_PART_COUNT=${finalAudio.partCount}');
        debugPrint('P0_04_FINAL_M4A_VALID=PASS');
        debugPrint('QURANI_P0_04_AUDIO_SMOKE_PROOF_OK');
      } finally {
        await spike.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
