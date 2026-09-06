import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/setup/application/forgot_pin_recovery_service.dart';

void main() {
  test(
    'reset delegates exactly once to the destructive local reset coordinator',
    () async {
      final coordinator = _FakeLocalResetCoordinator();
      final service = ForgotPinRecoveryService(coordinator);

      await service.resetAndStartOver();

      expect(coordinator.calls, 1);
    },
  );

  test(
    'reset failure is propagated and never converted into a bypass success',
    () async {
      final coordinator = _FakeLocalResetCoordinator(throwOnReset: true);
      final service = ForgotPinRecoveryService(coordinator);

      await expectLater(service.resetAndStartOver(), throwsStateError);

      expect(coordinator.calls, 1);
    },
  );
}

final class _FakeLocalResetCoordinator implements LocalResetCoordinator {
  _FakeLocalResetCoordinator({this.throwOnReset = false});

  final bool throwOnReset;
  int calls = 0;

  @override
  Future<void> resetLocalData() async {
    calls += 1;

    if (throwOnReset) {
      throw StateError('simulated destructive reset failure');
    }
  }
}
