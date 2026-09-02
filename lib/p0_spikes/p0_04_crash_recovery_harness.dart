import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qurani/p0_spikes/p0_04_long_audio_spike.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _CrashRecoveryHarnessApp());
}

class _CrashRecoveryHarnessApp extends StatefulWidget {
  const _CrashRecoveryHarnessApp();

  @override
  State<_CrashRecoveryHarnessApp> createState() =>
      _CrashRecoveryHarnessAppState();
}

class _CrashRecoveryHarnessAppState extends State<_CrashRecoveryHarnessApp> {
  String _status = 'P0-04 crash/recovery harness starting...';

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_run);
  }

  Future<void> _run() async {
    try {
      final bridge = P004AudioBridge();
      final root = await bridge.getRootPath();
      final mode = File('$root/crash_harness_mode.txt');

      if (!await mode.exists()) {
        await _phase1();
      } else {
        final value = (await mode.readAsString()).trim();
        if (value == 'recover') {
          await _phase2(root, bridge);
        } else if (value == 'done') {
          _setStatus('Crash/recovery proof already completed.');
        } else {
          throw StateError('Unexpected harness mode: $value');
        }
      }
    } catch (error, stackTrace) {
      debugPrint('P0_04_STANDALONE_HARNESS_ERROR=$error');
      debugPrint('$stackTrace');

      try {
        final bridge = P004AudioBridge();
        final root = await bridge.getRootPath();
        await File('$root/crash_harness_failed.txt').writeAsString(
          'P0_04_STANDALONE_HARNESS_FAILED\n$error\n$stackTrace\n',
          flush: true,
        );
      } catch (_) {}

      _setStatus('FAILED: $error');
    }
  }

  Future<void> _phase1() async {
    _setStatus('Phase 1: recording before forced crash...');

    final spike = P004LongAudioSpike();

    if (!await spike.isAacLcSupported()) {
      throw StateError('AAC-LC streaming is not supported.');
    }

    debugPrint('P0_04_STANDALONE_AAC_LC_SUPPORTED=PASS');

    await spike.start();

    final sessionDir = spike.sessionDirectory;
    final root = Directory(sessionDir).parent.path;

    final pointer = File('$root/crash_harness_pointer.txt');
    final mode = File('$root/crash_harness_mode.txt');
    final ready = File('$root/crash_harness_ready.txt');

    await pointer.writeAsString(sessionDir, flush: true);

    debugPrint('P0_04_STANDALONE_CRASH_SESSION_DIR=$sessionDir');
    debugPrint('P0_04_STANDALONE_RECORDING_STARTED=PASS');

    // At 64 kbps, ~145 seconds safely crosses the approved ~1 MiB
    // incremental checkpoint threshold.
    await Future<void>.delayed(const Duration(seconds: 145));

    final sealedBeforeCrash = spike.parts
        .where((part) => part.sealed && part.bytes > 0)
        .length;

    if (sealedBeforeCrash < 1) {
      throw StateError('No sealed checkpoint existed before crash.');
    }

    debugPrint('P0_04_STANDALONE_SEALED_PARTS=$sealedBeforeCrash');
    debugPrint('P0_04_STANDALONE_CHECKPOINT_BEFORE_CRASH=PASS');

    await spike.prepareCrashProof();

    final manifest = File('$sessionDir/session.json');
    if (!await manifest.exists()) {
      throw StateError('Crash manifest was not written.');
    }

    final manifestText = await manifest.readAsString();
    if (!manifestText.contains('recording_before_forced_crash')) {
      throw StateError('Crash manifest did not preserve incomplete state.');
    }

    await mode.writeAsString('recover', flush: true);
    await ready.writeAsString(
      'P0_04_STANDALONE_CRASH_READY\n'
      'session=$sessionDir\n'
      'sealedParts=$sealedBeforeCrash\n',
      flush: true,
    );

    debugPrint('P0_04_STANDALONE_MANIFEST_FLUSHED=PASS');
    debugPrint('P0_04_STANDALONE_CRASH_READY=PASS');
    debugPrint('P0_04_STANDALONE_EXTERNAL_CRASH_ARMED=PASS');

    _setStatus('Phase 1 ready. Waiting for external Android crash...');

    // Intentionally keep recording alive. The PowerShell gate observes the
    // flushed ready marker and then uses Android ActivityManager to crash the
    // process externally. This avoids any graceful recorder/file cleanup.
    while (true) {
      await Future<void>.delayed(const Duration(minutes: 1));
    }
  }

  Future<void> _phase2(String root, P004AudioBridge bridge) async {
    _setStatus('Phase 2: recovering after process crash...');

    final pointer = File('$root/crash_harness_pointer.txt');
    final done = File('$root/crash_harness_done.txt');
    final mode = File('$root/crash_harness_mode.txt');

    if (!await pointer.exists()) {
      throw StateError('Crash session pointer did not survive.');
    }

    final sessionDir = (await pointer.readAsString()).trim();
    if (sessionDir.isEmpty) {
      throw StateError('Crash session pointer is empty.');
    }

    debugPrint('P0_04_STANDALONE_RECOVERY_SESSION_DIR=$sessionDir');
    debugPrint('P0_04_STANDALONE_POINTER_SURVIVED=PASS');

    final manifest = File('$sessionDir/session.json');
    if (!await manifest.exists()) {
      throw StateError('Crash manifest did not survive process death.');
    }

    final manifestText = await manifest.readAsString();
    if (!manifestText.contains('recording_before_forced_crash')) {
      throw StateError('Incomplete recording state did not survive.');
    }

    debugPrint('P0_04_STANDALONE_INCOMPLETE_STATE_SURVIVED=PASS');

    final partFiles = await Directory(sessionDir)
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.aac'))
        .cast<File>()
        .toList();

    if (partFiles.isEmpty) {
      throw StateError('No AAC part survived process death.');
    }

    var savedBytes = 0;
    for (final file in partFiles) {
      savedBytes += await file.length();
    }

    if (savedBytes <= 0) {
      throw StateError('Surviving AAC parts are empty.');
    }

    debugPrint('P0_04_STANDALONE_AAC_PARTS=${partFiles.length}');
    debugPrint('P0_04_STANDALONE_AAC_BYTES=$savedBytes');
    debugPrint('P0_04_STANDALONE_SAVED_PARTS_SURVIVED=PASS');

    final recovered = await P004LongAudioSpike.recoverAndFinalize(
      sessionDir,
      bridge: bridge,
    );

    if (!File(recovered.path).existsSync()) {
      throw StateError('Recovered M4A file does not exist.');
    }

    if (recovered.bytes <= 0) {
      throw StateError('Recovered M4A is empty.');
    }

    if (recovered.mime != 'audio/mp4a-latm') {
      throw StateError('Unexpected recovered MIME: ${recovered.mime}');
    }

    if (recovered.sampleRate != 44100 || recovered.channelCount != 1) {
      throw StateError(
        'Unexpected recovered format: '
        '${recovered.sampleRate} Hz / ${recovered.channelCount} channels',
      );
    }

    if (recovered.durationUs <= 110000000) {
      throw StateError(
        'Recovered duration is too short: ${recovered.durationUs}',
      );
    }

    if (recovered.partCount < 1) {
      throw StateError('Recovered result has no source parts.');
    }

    final proof = StringBuffer()
      ..writeln('QURANI_P0_04_CRASH_RECOVERY_STANDALONE_PROOF_OK')
      ..writeln('P0_04_STANDALONE_POINTER_SURVIVED=PASS')
      ..writeln('P0_04_STANDALONE_INCOMPLETE_STATE_SURVIVED=PASS')
      ..writeln('P0_04_STANDALONE_SAVED_PARTS_SURVIVED=PASS')
      ..writeln('P0_04_STANDALONE_RECOVERED_M4A_VALID=PASS')
      ..writeln('P0_04_RECOVERED_PATH=${recovered.path}')
      ..writeln('P0_04_RECOVERED_BYTES=${recovered.bytes}')
      ..writeln('P0_04_RECOVERED_MIME=${recovered.mime}')
      ..writeln('P0_04_RECOVERED_SAMPLE_RATE=${recovered.sampleRate}')
      ..writeln('P0_04_RECOVERED_CHANNELS=${recovered.channelCount}')
      ..writeln('P0_04_RECOVERED_DURATION_US=${recovered.durationUs}')
      ..writeln('P0_04_RECOVERED_PART_COUNT=${recovered.partCount}');

    await done.writeAsString(proof.toString(), flush: true);
    await mode.writeAsString('done', flush: true);

    debugPrint(proof.toString());
    _setStatus('Crash/recovery proof completed successfully.');
  }

  void _setStatus(String value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _status = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_status, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}
