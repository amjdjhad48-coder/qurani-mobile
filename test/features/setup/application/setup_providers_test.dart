import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/android_local_security_store.dart';
import 'package:qurani/features/setup/application/forgot_pin_recovery_service.dart';
import 'package:qurani/features/setup/application/initial_setup_service.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/data/app_support_local_reset_coordinator.dart';
import 'package:qurani/features/setup/data/drift_initial_setup_database_coordinator.dart';
import 'package:qurani/features/setup/data/drift_runtime_database_opener.dart';

void main() {
  test(
    'production setup database uses application support directory and approved qurani.db name',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'qurani_p2_06_support_path_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final container = ProviderContainer(
        overrides: <Override>[
          applicationSupportDirectoryProvider.overrideWith((ref) async => root),
        ],
      );
      addTearDown(container.dispose);

      final coordinator = await container.read(
        initialSetupDatabaseCoordinatorProvider.future,
      );

      expect(coordinator, isA<DriftInitialSetupDatabaseCoordinator>());

      final driftCoordinator =
          coordinator as DriftInitialSetupDatabaseCoordinator;
      final expectedFinal = File(
        '${root.path}${Platform.pathSeparator}qurani.db',
      );

      expect(driftCoordinator.finalDatabaseFile.path, expectedFinal.path);
      expect(
        driftCoordinator.candidateDatabaseFile.path,
        '${expectedFinal.path}.setup_candidate',
      );
      expect(
        driftCoordinator.candidateDatabaseFile.parent.path,
        driftCoordinator.finalDatabaseFile.parent.path,
      );
    },
  );

  test(
    'production setup wiring uses approved native store and PIN verifier',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(localSecurityStoreProvider),
        isA<AndroidLocalSecurityStore>(),
      );
      expect(
        container.read(initialSetupPinVerifierProvider),
        isA<ProductionInitialSetupPinVerifier>(),
      );
    },
  );

  test(
    'runtime lock wiring reuses qurani.db and the production PIN verifier',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'qurani_p2_07_runtime_path_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final container = ProviderContainer(
        overrides: <Override>[
          applicationSupportDirectoryProvider.overrideWith((ref) async => root),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(runtimePinVerifierProvider),
        isA<ProductionRuntimePinVerifier>(),
      );

      final opener = await container.read(runtimeDatabaseOpenerProvider.future);

      expect(opener, isA<DriftRuntimeDatabaseOpener>());

      final driftOpener = opener as DriftRuntimeDatabaseOpener;
      expect(
        driftOpener.finalDatabaseFile.path,
        '${root.path}${Platform.pathSeparator}qurani.db',
      );
      expect(driftOpener.tempDirectoryPath, root.path);
    },
  );

  test(
    'forgot PIN reset providers wire app-support reset foundation',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'qurani_p2_10_reset_provider_',
      );
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      final container = ProviderContainer(
        overrides: <Override>[
          applicationSupportDirectoryProvider.overrideWith((ref) async => root),
        ],
      );
      addTearDown(container.dispose);

      final coordinator = await container.read(
        localResetCoordinatorProvider.future,
      );
      final service = await container.read(
        forgotPinRecoveryServiceProvider.future,
      );

      expect(coordinator, isA<AppSupportLocalResetCoordinator>());
      expect(service, isA<ForgotPinRecoveryService>());
    },
  );
}
