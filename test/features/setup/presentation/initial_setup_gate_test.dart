import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/features/setup/application/forgot_pin_recovery_service.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/presentation/initial_setup_gate.dart';

void main() {
  Future<void> pumpGate(
    WidgetTester tester,
    Future<SetupStateV1?> Function() loadPhase, {
    _GateLocalResetCoordinator? resetCoordinator,
  }) async {
    final runtimeCoordinator = _GateRuntimeLockCoordinator();
    final effectiveResetCoordinator =
        resetCoordinator ?? _GateLocalResetCoordinator();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          initialSetupPhaseProvider.overrideWith((ref) => loadPhase()),
          runtimeLockCoordinatorProvider.overrideWith(
            (ref) async => runtimeCoordinator,
          ),
          forgotPinRecoveryServiceProvider.overrideWith(
            (ref) async => ForgotPinRecoveryService(effectiveResetCoordinator),
          ),
        ],
        child: const MaterialApp(home: InitialSetupGate()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('missing setup state routes to initial setup form', (
    WidgetTester tester,
  ) async {
    await pumpGate(tester, () async => null);

    expect(find.text('الإعداد الأول'), findsOneWidget);
    expect(find.byKey(const Key('teacher_name_field')), findsOneWidget);
    expect(find.byKey(const Key('setup_recovery_notice')), findsNothing);
  });

  testWidgets('preparing setup state routes to crash-safe recovery form', (
    WidgetTester tester,
  ) async {
    await pumpGate(tester, () async => SetupStateV1.preparing);

    expect(find.text('الإعداد الأول'), findsOneWidget);
    expect(find.byKey(const Key('setup_recovery_notice')), findsOneWidget);
    expect(find.text('استكمال الإعداد'), findsOneWidget);
  });

  testWidgets('ready setup state routes to runtime PIN lock instead of setup', (
    WidgetTester tester,
  ) async {
    await pumpGate(tester, () async => SetupStateV1.ready);

    expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);
    expect(find.byKey(const Key('teacher_name_field')), findsNothing);
  });

  testWidgets('setup-state read failure shows retry surface', (
    WidgetTester tester,
  ) async {
    await pumpGate(tester, () async {
      throw StateError('simulated local security read failure');
    });

    expect(find.byKey(const Key('setup_state_error')), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets(
    'forgot PIN reset returns to fresh initial setup without opening data',
    (WidgetTester tester) async {
      SetupStateV1? phase = SetupStateV1.ready;
      final resetCoordinator = _GateLocalResetCoordinator(
        onReset: () async {
          phase = null;
        },
      );

      await pumpGate(
        tester,
        () async => phase,
        resetCoordinator: resetCoordinator,
      );

      expect(find.byKey(const Key('pin_unlock_field')), findsOneWidget);

      await tester.tap(find.byKey(const Key('forgot_pin_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset_and_start_over_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_local_reset_button')));
      await tester.pumpAndSettle();

      expect(resetCoordinator.calls, 1);
      expect(find.byKey(const Key('teacher_name_field')), findsOneWidget);
      expect(find.byKey(const Key('pin_unlock_field')), findsNothing);
    },
  );
}

final class _GateLocalResetCoordinator implements LocalResetCoordinator {
  _GateLocalResetCoordinator({this.onReset});

  final Future<void> Function()? onReset;
  int calls = 0;

  @override
  Future<void> resetLocalData() async {
    calls += 1;
    await onReset?.call();
  }
}

final class _GateRuntimeLockCoordinator implements RuntimeLockCoordinator {
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
    return const RuntimeLockSnapshot(
      unlocked: false,
      failedAttemptCount: 0,
      lockedUntilUtc: null,
    );
  }

  @override
  Future<void> lock() async {}

  @override
  Future<RuntimeUnlockResult> unlock(String pin) async {
    return const RuntimeUnlockResult(
      status: RuntimeUnlockStatus.invalidPin,
      snapshot: RuntimeLockSnapshot(
        unlocked: false,
        failedAttemptCount: 1,
        lockedUntilUtc: null,
      ),
    );
  }
}
