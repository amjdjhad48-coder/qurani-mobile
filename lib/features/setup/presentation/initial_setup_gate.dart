import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/presentation/initial_setup_screen.dart';
import 'package:qurani/features/setup/presentation/runtime_lock_gate.dart';

class InitialSetupGate extends ConsumerWidget {
  const InitialSetupGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(initialSetupPhaseProvider);

    return phase.when(
      loading: () => const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stackTrace) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'تعذر قراءة حالة الإعداد المحلي.',
                    key: Key('setup_state_error'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {
                      ref.invalidate(initialSetupPhaseProvider);
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      data: (setupState) {
        if (setupState == SetupStateV1.ready) {
          return RuntimeLockGate(
            onLocalResetComplete: () async {
              ref.invalidate(runtimeLockCoordinatorProvider);
              ref.invalidate(runtimeDatabaseOpenerProvider);
              ref.invalidate(initialSetupServiceProvider);
              ref.invalidate(initialSetupDatabaseCoordinatorProvider);
              ref.invalidate(forgotPinRecoveryServiceProvider);
              ref.invalidate(localResetCoordinatorProvider);
              ref.invalidate(initialSetupPhaseProvider);
            },
          );
        }

        return InitialSetupScreen(
          recovering: setupState == SetupStateV1.preparing,
        );
      },
    );
  }
}
