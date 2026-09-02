import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qurani/p0_spikes/p0_04_long_audio_spike.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'P0-04 relaunch recovers audio saved before forced crash',
    (_) async {
      final bridge = P004AudioBridge();
      final root = await bridge.getRootPath();

      final pointer = File('$root/crash_session_pointer.txt');
      final ready = File('$root/crash_proof_ready.txt');

      expect(await pointer.exists(), isTrue);
      expect(await ready.exists(), isTrue);

      final sessionDir = (await pointer.readAsString()).trim();
      expect(sessionDir, isNotEmpty);

      debugPrint('P0_04_RECOVERY_SESSION_DIR=$sessionDir');
      debugPrint('P0_04_CRASH_POINTER_SURVIVED=PASS');

      final manifest = File('$sessionDir/session.json');
      expect(await manifest.exists(), isTrue);

      final decoded = jsonDecode(await manifest.readAsString());
      expect(decoded, isA<Map<String, dynamic>>());

      final manifestMap = decoded as Map<String, dynamic>;
      final status = manifestMap['status'];

      expect(status, 'recording_before_forced_crash');
      debugPrint('P0_04_CRASH_MANIFEST_STATUS=$status');
      debugPrint('P0_04_INCOMPLETE_STATE_SURVIVED_CRASH=PASS');

      final partFiles = await Directory(sessionDir)
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.aac'))
          .cast<File>()
          .toList();

      expect(partFiles, isNotEmpty);

      final bytesBeforeRecovery = <int>[];
      for (final file in partFiles) {
        bytesBeforeRecovery.add(await file.length());
      }

      debugPrint('P0_04_RECOVERY_AAC_PART_COUNT=${partFiles.length}');
      debugPrint(
        'P0_04_RECOVERY_AAC_BYTES_BEFORE=${bytesBeforeRecovery.fold<int>(0, (a, b) => a + b)}',
      );
      debugPrint('P0_04_SAVED_PARTS_SURVIVED_CRASH=PASS');

      final recovered = await P004LongAudioSpike.recoverAndFinalize(
        sessionDir,
        bridge: bridge,
      );

      expect(File(recovered.path).existsSync(), isTrue);
      expect(recovered.bytes, greaterThan(0));
      expect(recovered.mime, 'audio/mp4a-latm');
      expect(recovered.sampleRate, 44100);
      expect(recovered.channelCount, 1);
      expect(recovered.durationUs, greaterThan(110000000));
      expect(recovered.partCount, greaterThanOrEqualTo(1));

      debugPrint('P0_04_RECOVERED_PATH=${recovered.path}');
      debugPrint('P0_04_RECOVERED_BYTES=${recovered.bytes}');
      debugPrint('P0_04_RECOVERED_MIME=${recovered.mime}');
      debugPrint('P0_04_RECOVERED_SAMPLE_RATE=${recovered.sampleRate}');
      debugPrint('P0_04_RECOVERED_CHANNELS=${recovered.channelCount}');
      debugPrint('P0_04_RECOVERED_DURATION_US=${recovered.durationUs}');
      debugPrint('P0_04_RECOVERED_PART_COUNT=${recovered.partCount}');
      debugPrint('P0_04_RECOVERED_M4A_VALID=PASS');
      debugPrint('QURANI_P0_04_CRASH_RECOVERY_PROOF_OK');
    },
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
