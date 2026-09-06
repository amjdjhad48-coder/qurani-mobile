import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/core/shared/core_providers.dart';
import 'package:qurani/features/setup/application/forgot_pin_recovery_service.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/presentation/runtime_lock_gate.dart';

void main() {
  Future<void> pumpGate(
    WidgetTester tester,
    _FakeRuntimeLockCoordinator coordinator, {
    _MutableClock? clock,
    _FakeLocalResetCoordinator? resetCoordinator,
    Future<void> Function()? onLocalResetComplete,
  }) async {
    final effectiveResetCoordinator =
        resetCoordinator ?? _FakeLocalResetCoordinator();
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          runtimeLockCoordinatorProvider.overrideWith(
            (ref) async => coordinator,
          ),
          forgotPinRecoveryServiceProvider.overrideWith(
            (ref) async => ForgotPinRecoveryService(effectiveResetCoordinator),
          ),
          if (clock != null) clockProvider.overrideWithValue(clock),
        ],
        child: MaterialApp(
          home: RuntimeLockGate(
            onLocalResetComplete: onLocalResetComplete ?? () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unlockGate(
    WidgetTester tester,
    _FakeRuntimeLockCoordinator coordinator,
  ) async {
    coordinator.nextUnlockResult = const RuntimeUnlockResult(
      status: RuntimeUnlockStatus.unlocked,
      snapshot: RuntimeLockSnapshot(
        unlocked: true,
        failedAttemptCount: 0,
        lockedUntilUtc: null,
      ),
    );

    await tester.enterText(find.byKey(const Key('pin_unlock_field')), '482731');
    await tester.tap(find.byKey(const Key('pin_unlock_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('runtime_unlocked_surface')), findsOneWidget);
  }

  testWidgets('process session starts on the PIN lock screen', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();

    await pumpGate(tester, coordinator);

    expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);
    expect(find.byKey(const Key('runtime_unlocked_surface')), findsNothing);
  });

  testWidgets('invalid PIN shows the concise lock error', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();
    coordinator.nextUnlockResult = const RuntimeUnlockResult(
      status: RuntimeUnlockStatus.invalidPin,
      snapshot: RuntimeLockSnapshot(
        unlocked: false,
        failedAttemptCount: 1,
        lockedUntilUtc: null,
      ),
    );

    await pumpGate(tester, coordinator);

    await tester.enterText(find.byKey(const Key('pin_unlock_field')), '482731');
    await tester.tap(find.byKey(const Key('pin_unlock_button')));
    await tester.pumpAndSettle();

    expect(find.text('PIN غير صحيح.'), findsOneWidget);
    expect(find.text('المحاولات غير الصحيحة: 1'), findsOneWidget);
  });

  testWidgets('temporary lock result is represented on the PIN screen', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();
    coordinator.nextUnlockResult = RuntimeUnlockResult(
      status: RuntimeUnlockStatus.temporarilyLocked,
      snapshot: RuntimeLockSnapshot(
        unlocked: false,
        failedAttemptCount: 5,
        lockedUntilUtc: DateTime.now().toUtc().add(const Duration(minutes: 1)),
      ),
    );

    await pumpGate(tester, coordinator);

    await tester.enterText(find.byKey(const Key('pin_unlock_field')), '482731');
    await tester.tap(find.byKey(const Key('pin_unlock_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('temporary_lock_message')), findsOneWidget);
    expect(find.text('تم تفعيل القفل المؤقت.'), findsOneWidget);
  });

  testWidgets(
    'successful unlock shows session surface and explicit lock returns to PIN',
    (WidgetTester tester) async {
      final coordinator = _FakeRuntimeLockCoordinator();

      await pumpGate(tester, coordinator);
      await unlockGate(tester, coordinator);

      await tester.tap(find.byKey(const Key('lock_now_button')));
      await tester.pumpAndSettle();

      expect(coordinator.lockCalls, 1);
      expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);
    },
  );

  testWidgets(
    'unlocked session exposes Change PIN and success returns to session',
    (WidgetTester tester) async {
      final coordinator = _FakeRuntimeLockCoordinator();
      coordinator.nextChangePinResult = const RuntimeChangePinResult(
        RuntimeChangePinStatus.changed,
      );

      await pumpGate(tester, coordinator);
      await unlockGate(tester, coordinator);

      await tester.tap(find.byKey(const Key('change_pin_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('change_pin_screen')), findsOneWidget);
      expect(find.byKey(const Key('change_pin_confirm_field')), findsNothing);

      await tester.enterText(
        find.byKey(const Key('change_pin_current_field')),
        '482731',
      );
      await tester.enterText(
        find.byKey(const Key('change_pin_new_field')),
        '731482',
      );
      await tester.tap(find.byKey(const Key('change_pin_submit_button')));
      await tester.pumpAndSettle();

      expect(coordinator.changePinCalls, 1);
      expect(coordinator.lastCurrentPin, '482731');
      expect(coordinator.lastNewPin, '731482');
      expect(find.byKey(const Key('runtime_unlocked_surface')), findsOneWidget);
      expect(find.text('تم تغيير PIN بنجاح.'), findsOneWidget);
    },
  );

  testWidgets('auto-lock while Change PIN is open dismisses sensitive form', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();

    await pumpGate(tester, coordinator);
    await unlockGate(tester, coordinator);

    await tester.tap(find.byKey(const Key('change_pin_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('change_pin_screen')), findsOneWidget);

    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();

    expect(coordinator.lockCalls, 1);
    expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);
    expect(find.byKey(const Key('change_pin_screen')), findsNothing);
  });

  testWidgets('foreground inactivity for five minutes auto-locks the session', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();

    await pumpGate(tester, coordinator);
    await unlockGate(tester, coordinator);

    await tester.pump(const Duration(minutes: 4, seconds: 59));
    expect(find.byKey(const Key('runtime_unlocked_surface')), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(coordinator.lockCalls, 1);
    expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);
  });

  testWidgets('pointer activity resets the foreground inactivity window', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();

    await pumpGate(tester, coordinator);
    await unlockGate(tester, coordinator);

    await tester.pump(const Duration(minutes: 4, seconds: 59));

    final center = tester.getCenter(
      find.byKey(const Key('runtime_unlocked_surface')),
    );
    final gesture = await tester.startGesture(center);
    await gesture.up();
    await tester.pump();

    await tester.pump(const Duration(minutes: 4, seconds: 59));
    expect(coordinator.lockCalls, 0);
    expect(find.byKey(const Key('runtime_unlocked_surface')), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(coordinator.lockCalls, 1);
    expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);
  });

  testWidgets('quick external-app return inside five minutes stays unlocked', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();
    final clock = _MutableClock(DateTime.utc(2026, 9, 4, 20));

    await pumpGate(tester, coordinator, clock: clock);
    await unlockGate(tester, coordinator);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    clock.now = clock.now.add(const Duration(minutes: 4, seconds: 59));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(coordinator.lockCalls, 0);
    expect(find.byKey(const Key('runtime_unlocked_surface')), findsOneWidget);
  });

  testWidgets('return after five background minutes locks before continuing', (
    WidgetTester tester,
  ) async {
    final coordinator = _FakeRuntimeLockCoordinator();
    final clock = _MutableClock(DateTime.utc(2026, 9, 4, 20));

    await pumpGate(tester, coordinator, clock: clock);
    await unlockGate(tester, coordinator);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    clock.now = clock.now.add(const Duration(minutes: 5));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(coordinator.lockCalls, 1);
    expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);
  });

  testWidgets(
    'forgot PIN opens no-bypass shell and confirmed reset completes once',
    (WidgetTester tester) async {
      final coordinator = _FakeRuntimeLockCoordinator();
      final resetCoordinator = _FakeLocalResetCoordinator();
      var resetCompleteCalls = 0;

      await pumpGate(
        tester,
        coordinator,
        resetCoordinator: resetCoordinator,
        onLocalResetComplete: () async {
          resetCompleteCalls += 1;
        },
      );

      await tester.tap(find.byKey(const Key('forgot_pin_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('forgot_pin_recovery_screen')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('forgot_pin_no_bypass_message')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('reset_and_start_over_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_local_reset_button')));
      await tester.pumpAndSettle();

      expect(resetCoordinator.calls, 1);
      expect(resetCompleteCalls, 1);
      expect(coordinator.lockCalls, 1);
    },
  );
}

final class _FakeLocalResetCoordinator implements LocalResetCoordinator {
  int calls = 0;

  @override
  Future<void> resetLocalData() async {
    calls += 1;
  }
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
  RuntimeLockSnapshot current = const RuntimeLockSnapshot(
    unlocked: false,
    failedAttemptCount: 0,
    lockedUntilUtc: null,
  );

  RuntimeUnlockResult? nextUnlockResult;
  RuntimeChangePinResult nextChangePinResult = const RuntimeChangePinResult(
    RuntimeChangePinStatus.invalidCurrentPin,
  );
  int lockCalls = 0;
  int changePinCalls = 0;
  String? lastCurrentPin;
  String? lastNewPin;

  @override
  Future<RuntimeChangePinResult> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    changePinCalls += 1;
    lastCurrentPin = currentPin;
    lastNewPin = newPin;
    return nextChangePinResult;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<RuntimeLockSnapshot> inspect() async {
    return current;
  }

  @override
  Future<void> lock() async {
    lockCalls += 1;
    current = const RuntimeLockSnapshot(
      unlocked: false,
      failedAttemptCount: 0,
      lockedUntilUtc: null,
    );
  }

  @override
  Future<RuntimeUnlockResult> unlock(String pin) async {
    final result = nextUnlockResult;
    if (result == null) {
      return RuntimeUnlockResult(
        status: RuntimeUnlockStatus.invalidPin,
        snapshot: current,
      );
    }

    current = result.snapshot;
    return result;
  }
}
