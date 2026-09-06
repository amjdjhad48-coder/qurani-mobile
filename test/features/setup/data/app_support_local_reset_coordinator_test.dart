import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/local_security_store.dart';
import 'package:qurani/features/setup/data/app_support_local_reset_coordinator.dart';

void main() {
  test(
    'reset removes private support data, recreates root, then clears security state last',
    () async {
      final temp = await Directory.systemTemp.createTemp('qurani_p2_10_reset_');
      addTearDown(() async {
        if (await temp.exists()) {
          await temp.delete(recursive: true);
        }
      });

      final support = Directory('${temp.path}${Platform.pathSeparator}support');
      await support.create(recursive: true);

      final nested = Directory('${support.path}${Platform.pathSeparator}audio');
      await nested.create(recursive: true);

      await File(
        '${support.path}${Platform.pathSeparator}qurani.db',
      ).writeAsString('encrypted-db-sentinel');
      await File(
        '${support.path}${Platform.pathSeparator}qurani.db-wal',
      ).writeAsString('wal-sentinel');
      await File(
        '${nested.path}${Platform.pathSeparator}part.m4a',
      ).writeAsString('audio-sentinel');

      final externalBackup = File(
        '${temp.path}${Platform.pathSeparator}teacher-backup.qrb',
      );
      await externalBackup.writeAsString('external-backup-sentinel');

      var clearObservedEmptySupportRoot = false;
      final store = _RecordingSecurityStore(
        onClear: () async {
          clearObservedEmptySupportRoot =
              await support.exists() && await support.list().isEmpty;
        },
      );

      final coordinator = AppSupportLocalResetCoordinator(support, store);

      await coordinator.resetLocalData();

      expect(await support.exists(), isTrue);
      expect(await support.list().isEmpty, isTrue);
      expect(clearObservedEmptySupportRoot, isTrue);
      expect(store.clearCalls, 1);
      expect(await store.read(), isNull);
      expect(await externalBackup.exists(), isTrue);
      expect(await externalBackup.readAsString(), 'external-backup-sentinel');
    },
  );

  test(
    'security clear failure leaves reset retryable and a second reset completes',
    () async {
      final temp = await Directory.systemTemp.createTemp(
        'qurani_p2_10_reset_retry_',
      );
      addTearDown(() async {
        if (await temp.exists()) {
          await temp.delete(recursive: true);
        }
      });

      final support = Directory('${temp.path}${Platform.pathSeparator}support');
      await support.create(recursive: true);
      await File(
        '${support.path}${Platform.pathSeparator}qurani.db',
      ).writeAsString('encrypted-db-sentinel');

      final store = _RecordingSecurityStore(failuresRemaining: 1);

      final coordinator = AppSupportLocalResetCoordinator(support, store);

      await expectLater(coordinator.resetLocalData(), throwsStateError);

      expect(await support.exists(), isTrue);
      expect(await support.list().isEmpty, isTrue);
      expect(await store.read(), isNotNull);
      expect(store.clearCalls, 1);

      await coordinator.resetLocalData();

      expect(await support.exists(), isTrue);
      expect(await support.list().isEmpty, isTrue);
      expect(await store.read(), isNull);
      expect(store.clearCalls, 2);
    },
  );
}

final class _RecordingSecurityStore implements LocalSecurityStore {
  _RecordingSecurityStore({this.onClear, this.failuresRemaining = 0})
    : _payload = Uint8List.fromList(<int>[1, 2, 3]);

  final Future<void> Function()? onClear;
  int failuresRemaining;
  int clearCalls = 0;
  Uint8List? _payload;

  @override
  Future<void> clear() async {
    clearCalls += 1;
    await onClear?.call();

    if (failuresRemaining > 0) {
      failuresRemaining -= 1;
      throw StateError('simulated LocalSecurityStore clear failure');
    }

    _payload = null;
  }

  @override
  Future<Uint8List?> read() async {
    final payload = _payload;
    return payload == null ? null : Uint8List.fromList(payload);
  }

  @override
  Future<void> write(Uint8List payload) async {
    _payload = Uint8List.fromList(payload);
  }
}
