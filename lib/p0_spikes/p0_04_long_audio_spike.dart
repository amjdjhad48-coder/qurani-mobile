import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:record/record.dart';

class P004AdtsTools {
  const P004AdtsTools._();

  static int frameLengthAt(List<int> bytes, int offset) {
    if (offset < 0 || offset + 7 > bytes.length) {
      return -1;
    }

    if (bytes[offset] != 0xff || (bytes[offset + 1] & 0xf6) != 0xf0) {
      return -1;
    }

    final protectionAbsent = bytes[offset + 1] & 0x01;
    final headerLength = protectionAbsent == 1 ? 7 : 9;

    if (offset + headerLength > bytes.length) {
      return -1;
    }

    final frameLength =
        ((bytes[offset + 3] & 0x03) << 11) |
        (bytes[offset + 4] << 3) |
        ((bytes[offset + 5] & 0xe0) >> 5);

    if (frameLength < headerLength) {
      return -1;
    }

    return frameLength;
  }

  static int validPrefixLength(List<int> bytes) {
    var offset = 0;

    while (offset + 7 <= bytes.length) {
      final length = frameLengthAt(bytes, offset);
      if (length <= 0 || offset + length > bytes.length) {
        break;
      }
      offset += length;
    }

    return offset;
  }

  static int countFrames(List<int> bytes) {
    var offset = 0;
    var count = 0;

    while (offset + 7 <= bytes.length) {
      final length = frameLengthAt(bytes, offset);
      if (length <= 0 || offset + length > bytes.length) {
        break;
      }
      offset += length;
      count += 1;
    }

    return count;
  }
}

class P004AudioBridge {
  static const MethodChannel _channel = MethodChannel('qurani/p0_04_audio');

  Future<String> getRootPath() async {
    final value = await _channel.invokeMethod<String>('getRootPath');
    if (value == null || value.isEmpty) {
      throw StateError('P0-04 native root path is unavailable.');
    }
    return value;
  }

  Future<void> startForegroundService() async {
    await _channel.invokeMethod<void>('startForegroundService');
  }

  Future<void> stopForegroundService() async {
    await _channel.invokeMethod<void>('stopForegroundService');
  }

  Future<int> freeBytes(String path) async {
    final value = await _channel.invokeMethod<int>(
      'freeBytes',
      <String, Object?>{'path': path},
    );
    if (value == null) {
      throw StateError('P0-04 free-space result is unavailable.');
    }
    return value;
  }

  Future<Map<String, Object?>> remuxAdtsToM4a({
    required List<String> parts,
    required String output,
  }) async {
    final value = await _channel.invokeMapMethod<String, Object?>(
      'remuxAdtsToM4a',
      <String, Object?>{'parts': parts, 'output': output},
    );

    if (value == null) {
      throw StateError('P0-04 remux result is unavailable.');
    }

    return value;
  }

  Future<Map<String, Object?>> validateM4a(String path) async {
    final value = await _channel.invokeMapMethod<String, Object?>(
      'validateM4a',
      <String, Object?>{'path': path},
    );

    if (value == null) {
      throw StateError('P0-04 M4A validation result is unavailable.');
    }

    return value;
  }

  Future<void> killProcessForCrashTest() async {
    await _channel.invokeMethod<void>('killProcessForCrashTest');
  }
}

class P004AudioPart {
  P004AudioPart({
    required this.sequence,
    required this.path,
    this.bytes = 0,
    this.frames = 0,
    this.sealed = false,
  });

  final int sequence;
  final String path;
  int bytes;
  int frames;
  bool sealed;

  Map<String, Object?> toJson() => <String, Object?>{
    'sequence': sequence,
    'path': path,
    'bytes': bytes,
    'frames': frames,
    'sealed': sealed,
  };
}

class P004FinalAudio {
  const P004FinalAudio({
    required this.path,
    required this.bytes,
    required this.mime,
    required this.sampleRate,
    required this.channelCount,
    required this.durationUs,
    required this.partCount,
  });

  final String path;
  final int bytes;
  final String mime;
  final int sampleRate;
  final int channelCount;
  final int durationUs;
  final int partCount;
}

class P004LongAudioSpike {
  P004LongAudioSpike({
    AudioRecorder? recorder,
    P004AudioBridge? bridge,
    this.checkpointBytes = 1024 * 1024,
  }) : _recorder = recorder ?? AudioRecorder(),
       _bridge = bridge ?? P004AudioBridge();

  static const RecordConfig requestedConfig = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 64000,
    sampleRate: 44100,
    numChannels: 1,
    audioInterruption: AudioInterruptionMode.pause,
  );

  final AudioRecorder _recorder;
  final P004AudioBridge _bridge;
  final int checkpointBytes;

  final List<P004AudioPart> _parts = <P004AudioPart>[];
  final List<int> _pending = <int>[];

  StreamSubscription<List<int>>? _subscription;
  StreamSubscription<RecordState>? _stateSubscription;
  RandomAccessFile? _currentFile;
  P004AudioPart? _currentPart;
  Future<void> _writeChain = Future<void>.value();
  Future<void> _stateChain = Future<void>.value();
  Completer<void>? _streamDone;

  String? _sessionDirectory;
  String? _manifestPath;
  bool _started = false;
  bool _paused = false;
  Object? _streamError;
  Object? _stateError;
  RecordConfig _effectiveConfig = requestedConfig;

  String get sessionDirectory {
    final value = _sessionDirectory;
    if (value == null) {
      throw StateError('P0-04 session has not started.');
    }
    return value;
  }

  String get manifestPath {
    final value = _manifestPath;
    if (value == null) {
      throw StateError('P0-04 manifest is not available.');
    }
    return value;
  }

  List<P004AudioPart> get parts => List<P004AudioPart>.unmodifiable(_parts);
  RecordConfig get effectiveConfig => _effectiveConfig;
  bool get isPaused => _paused;

  Future<bool> isAacLcSupported() {
    return _recorder.isEncoderSupported(AudioEncoder.aacLc);
  }

  Future<void> start() async {
    if (_started) {
      throw StateError('P0-04 session is already active.');
    }

    if (!await isAacLcSupported()) {
      throw StateError('AAC-LC stream encoder is not supported.');
    }

    if (!await _recorder.hasPermission()) {
      throw StateError('Microphone permission was not granted.');
    }

    final root = await _bridge.getRootPath();
    final rootDir = Directory(root);
    await rootDir.create(recursive: true);

    final free = await _bridge.freeBytes(root);
    if (free < 100 * 1024 * 1024) {
      throw StateError('Less than 100 MiB is available for P0-04.');
    }

    final id = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '');

    final dir = Directory('$root/session_$id');
    await dir.create(recursive: true);

    _sessionDirectory = dir.path;
    _manifestPath = '${dir.path}/session.json';

    await _writeManifest('prepared');

    await _recorder.setOnConfigChanged((RecordConfig config) {
      _effectiveConfig = config;
    });

    await _bridge.startForegroundService();

    try {
      final stream = await _recorder.startStream(requestedConfig);

      await _openPart();

      _streamDone = Completer<void>();
      _subscription = stream.listen(
        (List<int> bytes) {
          _writeChain = _writeChain.then((_) => _acceptBytes(bytes));
        },
        onError: (Object error, StackTrace stackTrace) {
          _streamError = error;
          if (_streamDone?.isCompleted == false) {
            _streamDone?.complete();
          }
        },
        onDone: () {
          if (_streamDone?.isCompleted == false) {
            _streamDone?.complete();
          }
        },
        cancelOnError: false,
      );

      _started = true;
      _paused = false;
      _stateError = null;
      _stateChain = Future<void>.value();
      _stateSubscription = _recorder.onStateChanged().listen((state) {
        unawaited(_enqueueRecorderState(state));
      });
      await _writeManifest('recording');
    } catch (_) {
      await _bridge.stopForegroundService();
      rethrow;
    }
  }

  Future<void> pause() async {
    _ensureStarted();
    await _syncRecorderState();

    if (_paused) {
      throw StateError('P0-04 session is already paused.');
    }

    await _recorder.pause();
    await _syncRecorderState();

    if (!_paused) {
      throw StateError('AudioRecorder did not enter the paused state.');
    }
  }

  Future<void> resume() async {
    _ensureStarted();
    await _syncRecorderState();

    if (!_paused) {
      throw StateError('P0-04 session is not paused.');
    }

    final hasFile = _currentFile != null;
    final hasPart = _currentPart != null;
    if (hasFile != hasPart) {
      throw StateError('P0-04 AAC part state is inconsistent before resume.');
    }

    if (!hasFile) {
      await _openPart();
    }

    try {
      await _recorder.resume();
      await _syncRecorderState();

      if (_paused) {
        throw StateError('AudioRecorder did not leave the paused state.');
      }
    } catch (_) {
      if (_paused) {
        _discardIncompletePendingFrame();
        await _sealCurrentPart();
      }
      rethrow;
    }
  }

  Future<P004FinalAudio> stopAndFinalize() async {
    _ensureStarted();
    await _syncRecorderState();

    await _recorder.stop();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await _stateChain;
    _throwStateErrorIfAny();

    await _stateSubscription?.cancel();
    _stateSubscription = null;

    final done = _streamDone;
    if (done != null && !done.isCompleted) {
      await done.future.timeout(const Duration(seconds: 5));
    }

    await _writeChain;

    if (_streamError != null) {
      throw StateError('Audio stream failed: $_streamError');
    }

    _discardIncompletePendingFrame();
    await _sealCurrentPart();

    await _bridge.stopForegroundService();

    final sealed = _parts
        .where((part) => part.sealed && part.bytes > 0)
        .map((part) => part.path)
        .toList(growable: false);

    if (sealed.isEmpty) {
      throw StateError('No sealed AAC parts are available.');
    }

    await _writeManifest('finalizing');

    final output = '$sessionDirectory/final.m4a';
    final result = await _bridge.remuxAdtsToM4a(parts: sealed, output: output);

    final finalAudio = _decodeFinal(result, sealed.length);

    await _writeManifest('completed', finalPath: finalAudio.path);

    _started = false;
    _paused = false;

    return finalAudio;
  }

  Future<void> prepareCrashProof() async {
    _ensureStarted();
    await _writeChain;
    await _currentFile?.flush();
    await _writeManifest('recording_before_forced_crash');
  }

  Future<void> killProcessForCrashTest() async {
    await prepareCrashProof();
    await _bridge.killProcessForCrashTest();
  }

  Future<void> dispose() async {
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {}

    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await _stateChain;
    } catch (_) {}

    try {
      await _stateSubscription?.cancel();
      _stateSubscription = null;
    } catch (_) {}

    try {
      await _subscription?.cancel();
    } catch (_) {}

    try {
      await _currentFile?.close();
    } catch (_) {}

    try {
      await _bridge.stopForegroundService();
    } catch (_) {}

    await _recorder.dispose();
  }

  static Future<P004FinalAudio> recoverAndFinalize(
    String sessionDirectory, {
    P004AudioBridge? bridge,
  }) async {
    final native = bridge ?? P004AudioBridge();
    final dir = Directory(sessionDirectory);

    if (!await dir.exists()) {
      throw StateError('Recovery directory does not exist.');
    }

    final files = await dir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.aac'))
        .cast<File>()
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));

    final valid = <String>[];

    for (final file in files) {
      final bytes = await file.readAsBytes();
      final validLength = P004AdtsTools.validPrefixLength(bytes);

      if (validLength <= 0) {
        continue;
      }

      if (validLength < bytes.length) {
        final raf = await file.open(mode: FileMode.append);
        try {
          await raf.truncate(validLength);
          await raf.flush();
        } finally {
          await raf.close();
        }
      }

      valid.add(file.path);
    }

    if (valid.isEmpty) {
      throw StateError('No recoverable AAC parts were found.');
    }

    final output = '$sessionDirectory/recovered_final.m4a';
    final result = await native.remuxAdtsToM4a(parts: valid, output: output);

    return _decodeFinal(result, valid.length);
  }

  static P004FinalAudio _decodeFinal(Map<String, Object?> map, int partCount) {
    final path = map['path'];
    final bytes = map['bytes'];
    final mime = map['mime'];
    final sampleRate = map['sampleRate'];
    final channelCount = map['channelCount'];
    final durationUs = map['durationUs'];

    if (path is! String ||
        bytes is! int ||
        mime is! String ||
        sampleRate is! int ||
        channelCount is! int ||
        durationUs is! int) {
      throw StateError('Invalid native M4A validation payload: $map');
    }

    return P004FinalAudio(
      path: path,
      bytes: bytes,
      mime: mime,
      sampleRate: sampleRate,
      channelCount: channelCount,
      durationUs: durationUs,
      partCount: partCount,
    );
  }

  Future<void> _acceptBytes(List<int> bytes) async {
    if (bytes.isEmpty) {
      return;
    }

    _pending.addAll(bytes);

    final complete = <int>[];
    var consumed = 0;
    var frameCount = 0;

    while (consumed + 7 <= _pending.length) {
      final length = P004AdtsTools.frameLengthAt(_pending, consumed);

      if (length <= 0) {
        throw StateError('Invalid ADTS framing at pending offset $consumed.');
      }

      if (consumed + length > _pending.length) {
        break;
      }

      complete.addAll(_pending.getRange(consumed, consumed + length));
      consumed += length;
      frameCount += 1;
    }

    if (consumed > 0) {
      _pending.removeRange(0, consumed);
    }

    if (complete.isEmpty) {
      return;
    }

    final file = _currentFile;
    final part = _currentPart;

    if (file == null || part == null) {
      throw StateError('AAC data arrived without an open part.');
    }

    await file.writeFrom(complete);
    await file.flush();

    part.bytes += complete.length;
    part.frames += frameCount;

    if (part.bytes >= checkpointBytes) {
      await _sealCurrentPart();
      if (!_paused && _started) {
        await _openPart();
      }
    }
  }

  Future<void> _enqueueRecorderState(RecordState state) {
    _stateChain = _stateChain
        .then((_) => _handleRecorderState(state))
        .catchError((Object error, StackTrace stackTrace) {
          _stateError ??= error;
        });
    return _stateChain;
  }

  Future<void> _handleRecorderState(RecordState state) async {
    if (!_started) {
      return;
    }

    switch (state) {
      case RecordState.pause:
        if (_paused) {
          return;
        }

        // Mark paused before draining writes so an in-flight checkpoint cannot
        // open a new part while the system interruption is active.
        _paused = true;

        await Future<void>.delayed(const Duration(milliseconds: 150));
        await _writeChain;

        _discardIncompletePendingFrame();
        await _sealCurrentPart();
        await _writeManifest('paused');
        return;

      case RecordState.record:
        if (!_paused) {
          return;
        }

        final hasFile = _currentFile != null;
        final hasPart = _currentPart != null;
        if (hasFile != hasPart) {
          throw StateError(
            'P0-04 AAC part state is inconsistent during recorder resume.',
          );
        }

        if (!hasFile) {
          await _openPart();
        }

        _paused = false;
        await _writeManifest('recording');
        return;

      case RecordState.stop:
        return;
    }
  }

  Future<void> _syncRecorderState() async {
    // Give record's platform state event a short window to reach the Dart
    // stream, then serialize all state/file transitions through _stateChain.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await _stateChain;
    _throwStateErrorIfAny();

    final actualPaused = await _recorder.isPaused();
    final actualRecording = await _recorder.isRecording();

    if (actualPaused && !_paused) {
      await _enqueueRecorderState(RecordState.pause);
    } else if (!actualPaused && actualRecording && _paused) {
      await _enqueueRecorderState(RecordState.record);
    }

    await _stateChain;
    _throwStateErrorIfAny();
  }

  void _throwStateErrorIfAny() {
    final error = _stateError;
    if (error == null) {
      return;
    }

    _stateError = null;
    throw StateError('Audio recorder state synchronization failed: $error');
  }

  Future<void> _openPart() async {
    if (_currentFile != null || _currentPart != null) {
      throw StateError('A P0-04 part is already open.');
    }

    final sequence = _parts.length + 1;
    final path =
        '$sessionDirectory/part_${sequence.toString().padLeft(4, '0')}.aac';

    final file = File(path);
    final raf = await file.open(mode: FileMode.write);

    final part = P004AudioPart(sequence: sequence, path: path);

    _parts.add(part);
    _currentFile = raf;
    _currentPart = part;

    await _writeManifest(_paused ? 'paused_prepared' : 'recording');
  }

  Future<void> _sealCurrentPart() async {
    final file = _currentFile;
    final part = _currentPart;

    if (file == null || part == null) {
      return;
    }

    await file.flush();
    await file.close();

    _currentFile = null;
    _currentPart = null;

    final length = await File(part.path).length();
    part.bytes = length;

    if (length == 0) {
      await File(part.path).delete();
      _parts.remove(part);
      return;
    }

    final bytes = await File(part.path).readAsBytes();
    final validPrefix = P004AdtsTools.validPrefixLength(bytes);

    if (validPrefix != bytes.length) {
      throw StateError('Sealed AAC part is not frame-complete: ${part.path}');
    }

    part.frames = P004AdtsTools.countFrames(bytes);
    part.sealed = true;

    await _writeManifest(_paused ? 'paused' : 'recording');
  }

  void _discardIncompletePendingFrame() {
    _pending.clear();
  }

  Future<void> _writeManifest(String status, {String? finalPath}) async {
    final path = _manifestPath;
    if (path == null) {
      return;
    }

    final payload = <String, Object?>{
      'version': 1,
      'status': status,
      'requested': <String, Object?>{
        'encoder': 'aacLc',
        'bitRate': 64000,
        'sampleRate': 44100,
        'numChannels': 1,
        'checkpointBytes': checkpointBytes,
      },
      'effective': <String, Object?>{
        'encoder': _effectiveConfig.encoder.name,
        'bitRate': _effectiveConfig.bitRate,
        'sampleRate': _effectiveConfig.sampleRate,
        'numChannels': _effectiveConfig.numChannels,
      },
      'parts': _parts.map((part) => part.toJson()).toList(),
      'finalPath': finalPath,
      'updatedAtUtc': DateTime.now().toUtc().toIso8601String(),
    };

    final temp = File('$path.tmp');
    await temp.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );

    final target = File(path);
    if (await target.exists()) {
      await target.delete();
    }
    await temp.rename(path);
  }

  void _ensureStarted() {
    if (!_started) {
      throw StateError('P0-04 session is not active.');
    }
  }
}
