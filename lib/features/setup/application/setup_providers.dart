import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurani/core/security/android_local_security_store.dart';
import 'package:qurani/core/security/local_security_state.dart';
import 'package:qurani/core/security/local_security_state_store.dart';
import 'package:qurani/core/security/local_security_store.dart';
import 'package:qurani/core/shared/core_providers.dart';
import 'package:qurani/features/setup/application/forgot_pin_recovery_service.dart';
import 'package:qurani/features/setup/application/initial_setup_database_coordinator.dart';
import 'package:qurani/features/setup/application/initial_setup_service.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/data/app_support_local_reset_coordinator.dart';
import 'package:qurani/features/setup/data/drift_initial_setup_database_coordinator.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';
import 'package:qurani/features/setup/domain/initial_setup_request.dart';

typedef InitialSetupSubmitter =
    Future<void> Function(InitialSetupRequest request);

final localSecurityStoreProvider = Provider<LocalSecurityStore>(
  (ref) => AndroidLocalSecurityStore(),
);

final localSecurityStateStoreProvider = Provider<LocalSecurityStateStore>(
  (ref) =>
      LocalSecurityStateStore(store: ref.watch(localSecurityStoreProvider)),
);

final initialSetupPinVerifierProvider = Provider<InitialSetupPinVerifier>(
  (ref) => ProductionInitialSetupPinVerifier(),
);

final applicationSupportDirectoryProvider = FutureProvider<Directory>((
  ref,
) async {
  final directory = await getApplicationSupportDirectory();
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
  return directory;
});

final initialSetupDatabaseCoordinatorProvider =
    FutureProvider<InitialSetupDatabaseCoordinator>((ref) async {
      final directory = await ref.watch(
        applicationSupportDirectoryProvider.future,
      );
      final finalDatabaseFile = File(
        '${directory.path}${Platform.pathSeparator}qurani.db',
      );

      return DriftInitialSetupDatabaseCoordinator(
        finalDatabaseFile: finalDatabaseFile,
        tempDirectoryPath: directory.path,
      );
    });

final initialSetupServiceProvider = FutureProvider<InitialSetupService>((
  ref,
) async {
  final coordinator = await ref.watch(
    initialSetupDatabaseCoordinatorProvider.future,
  );

  return InitialSetupService(
    securityStateStore: ref.watch(localSecurityStateStoreProvider),
    keyManagement: ref.watch(keyManagementProvider),
    pinVerifier: ref.watch(initialSetupPinVerifierProvider),
    databaseCoordinator: coordinator,
    clock: ref.watch(clockProvider),
  );
});

final initialSetupPhaseProvider = FutureProvider<SetupStateV1?>((ref) async {
  final state = await ref.watch(localSecurityStateStoreProvider).read();
  return state?.setupState;
});

final initialSetupSubmitterProvider = Provider<InitialSetupSubmitter>((ref) {
  return (request) async {
    final service = await ref.read(initialSetupServiceProvider.future);
    await service.execute(request);
  };
});

final runtimePinVerifierProvider = Provider<RuntimePinVerifier>(
  (ref) => ProductionRuntimePinVerifier(),
);

final runtimeDatabaseOpenerProvider = FutureProvider<RuntimeDatabaseOpener>((
  ref,
) async {
  final directory = await ref.watch(applicationSupportDirectoryProvider.future);
  final finalDatabaseFile = File(
    '${directory.path}${Platform.pathSeparator}qurani.db',
  );

  return DriftRuntimeDatabaseOpener(
    finalDatabaseFile: finalDatabaseFile,
    tempDirectoryPath: directory.path,
  );
});

final localResetCoordinatorProvider = FutureProvider<LocalResetCoordinator>((
  ref,
) async {
  final directory = await ref.watch(applicationSupportDirectoryProvider.future);

  return AppSupportLocalResetCoordinator(
    directory,
    ref.watch(localSecurityStoreProvider),
  );
});

final forgotPinRecoveryServiceProvider =
    FutureProvider<ForgotPinRecoveryService>((ref) async {
      final resetCoordinator = await ref.watch(
        localResetCoordinatorProvider.future,
      );

      return ForgotPinRecoveryService(resetCoordinator);
    });

final runtimeLockCoordinatorProvider = FutureProvider<RuntimeLockCoordinator>((
  ref,
) async {
  final databaseOpener = await ref.watch(runtimeDatabaseOpenerProvider.future);

  final coordinator = RuntimeLockService(
    securityStateStore: ref.watch(localSecurityStateStoreProvider),
    keyManagement: ref.watch(keyManagementProvider),
    pinVerifier: ref.watch(runtimePinVerifierProvider),
    databaseOpener: databaseOpener,
    clock: ref.watch(clockProvider),
  );

  ref.onDispose(() {
    unawaited(coordinator.dispose());
  });

  return coordinator;
});
