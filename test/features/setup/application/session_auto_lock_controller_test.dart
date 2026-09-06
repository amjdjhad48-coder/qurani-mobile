import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/lock_policy.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/session_auto_lock_controller.dart';

void main() {
  group('SessionAutoLockController', () {
    test('unlock arms exactly the approved five-minute inactivity timer', () {
      final harness = _Harness();

      harness.controller.onUnlocked();

      expect(harness.timerFactory.activeTimers, hasLength(1));
      expect(
        harness.timerFactory.activeTimers.single.duration,
        LockPolicy.autoLockAfter,
      );
      expect(
        harness.timerFactory.activeTimers.single.duration,
        const Duration(minutes: 5),
      );
    });

    test('foreground user activity restarts the full five-minute window', () {
      final harness = _Harness();

      harness.controller.onUnlocked();
      final first = harness.timerFactory.activeTimers.single;

      harness.controller.recordUserActivity();

      expect(first.cancelled, isTrue);
      expect(harness.timerFactory.activeTimers, hasLength(1));
      expect(
        harness.timerFactory.activeTimers.single.duration,
        const Duration(minutes: 5),
      );
    });

    test('foreground timeout locks through RuntimeLockCoordinator', () async {
      final harness = _Harness();

      harness.controller.onUnlocked();

      await harness.timerFactory.fireActive();

      expect(harness.lockCoordinator.lockCalls, 1);
      expect(harness.autoLockedCalls, 1);
      expect(harness.controller.isUnlocked, isFalse);
    });

    test(
      'backgrounding cancels foreground timer and begins lifecycle grace',
      () {
        final harness = _Harness();

        harness.controller.onUnlocked();
        final active = harness.timerFactory.activeTimers.single;

        harness.controller.onBackgrounded();

        expect(active.cancelled, isTrue);
        expect(harness.controller.isBackgrounded, isTrue);
        expect(harness.timerFactory.activeTimers, isEmpty);
        expect(harness.lockCoordinator.lockCalls, 0);
      },
    );

    test(
      'quick WhatsApp or imo return inside five minutes does not ask PIN',
      () async {
        final harness = _Harness();

        harness.controller.onUnlocked();
        harness.controller.onBackgrounded();
        harness.clock.now = harness.clock.now.add(
          const Duration(minutes: 4, seconds: 59),
        );

        final locked = await harness.controller.onResumed();

        expect(locked, isFalse);
        expect(harness.lockCoordinator.lockCalls, 0);
        expect(harness.controller.isUnlocked, isTrue);
        expect(harness.controller.isBackgrounded, isFalse);
        expect(harness.timerFactory.activeTimers, hasLength(1));
        expect(
          harness.timerFactory.activeTimers.single.duration,
          const Duration(minutes: 5),
        );
      },
    );

    test('return at exactly five minutes locks before continuing', () async {
      final harness = _Harness();

      harness.controller.onUnlocked();
      harness.controller.onBackgrounded();
      harness.clock.now = harness.clock.now.add(const Duration(minutes: 5));

      final locked = await harness.controller.onResumed();

      expect(locked, isTrue);
      expect(harness.lockCoordinator.lockCalls, 1);
      expect(harness.autoLockedCalls, 1);
      expect(harness.controller.isUnlocked, isFalse);
    });

    test(
      'return after more than five minutes locks before continuing',
      () async {
        final harness = _Harness();

        harness.controller.onUnlocked();
        harness.controller.onBackgrounded();
        harness.clock.now = harness.clock.now.add(const Duration(minutes: 8));

        final locked = await harness.controller.onResumed();

        expect(locked, isTrue);
        expect(harness.lockCoordinator.lockCalls, 1);
        expect(harness.autoLockedCalls, 1);
      },
    );

    test(
      'duplicate background lifecycle states do not restart the grace window',
      () async {
        final harness = _Harness();

        harness.controller.onUnlocked();
        harness.controller.onBackgrounded();

        harness.clock.now = harness.clock.now.add(const Duration(minutes: 4));
        harness.controller.onBackgrounded();

        harness.clock.now = harness.clock.now.add(const Duration(minutes: 1));

        final locked = await harness.controller.onResumed();

        expect(locked, isTrue);
        expect(harness.lockCoordinator.lockCalls, 1);
      },
    );

    test('locked sessions ignore activity and lifecycle events', () async {
      final harness = _Harness();

      harness.controller.recordUserActivity();
      harness.controller.onBackgrounded();
      final locked = await harness.controller.onResumed();

      expect(locked, isFalse);
      expect(harness.timerFactory.activeTimers, isEmpty);
      expect(harness.lockCoordinator.lockCalls, 0);
    });
  });
}

final class _Harness {
  _Harness()
    : clock = _MutableClock(DateTime.utc(2026, 9, 4, 20)),
      lockCoordinator = _FakeRuntimeLockCoordinator(),
      timerFactory = _FakeSessionTimerFactory() {
    controller = SessionAutoLockController(
      lockCoordinator: lockCoordinator,
      clock: clock,
      onAutoLocked: () async {
        autoLockedCalls += 1;
      },
      timerFactory: timerFactory.create,
    );
  }

  final _MutableClock clock;
  final _FakeRuntimeLockCoordinator lockCoordinator;
  final _FakeSessionTimerFactory timerFactory;
  late final SessionAutoLockController controller;
  int autoLockedCalls = 0;
}

final class _MutableClock implements Clock {
  _MutableClock(this.now);

  DateTime now;

  @override
  DateTime nowUtc() => now.toUtc();

  @override
  DateTime todayLocal() {
    final local = now.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}

final class _FakeRuntimeLockCoordinator implements RuntimeLockCoordinator {
  int lockCalls = 0;

  @override
  Future<RuntimeChangePinResult> changePin({
    required String currentPin,
    required String newPin,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<RuntimeLockSnapshot> inspect() async {
    return RuntimeLockSnapshot(
      unlocked: lockCalls == 0,
      failedAttemptCount: 0,
      lockedUntilUtc: null,
    );
  }

  @override
  Future<void> lock() async {
    lockCalls += 1;
  }

  @override
  Future<RuntimeUnlockResult> unlock(String pin) async {
    throw UnimplementedError();
  }
}

final class _FakeSessionTimerFactory {
  final List<_FakeSessionTimer> timers = <_FakeSessionTimer>[];

  List<_FakeSessionTimer> get activeTimers =>
      timers.where((timer) => !timer.cancelled && !timer.fired).toList();

  SessionTimerHandle create(Duration duration, void Function() callback) {
    final timer = _FakeSessionTimer(duration: duration, callback: callback);
    timers.add(timer);
    return timer;
  }

  Future<void> fireActive() async {
    final active = activeTimers;
    expect(active, hasLength(1));
    active.single.fire();
    await Future<void>.delayed(Duration.zero);
  }
}

final class _FakeSessionTimer implements SessionTimerHandle {
  _FakeSessionTimer({required this.duration, required this.callback});

  final Duration duration;
  final void Function() callback;

  var cancelled = false;
  var fired = false;

  @override
  void cancel() {
    cancelled = true;
  }

  void fire() {
    if (cancelled || fired) {
      return;
    }

    fired = true;
    callback();
  }
}
