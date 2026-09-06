import 'dart:io';

import 'package:qurani/core/security/local_security_store.dart';
import 'package:qurani/features/setup/application/forgot_pin_recovery_service.dart';

final class AppSupportLocalResetCoordinator implements LocalResetCoordinator {
  AppSupportLocalResetCoordinator(
    this._applicationSupportDirectory,
    this._localSecurityStore,
  );

  final Directory _applicationSupportDirectory;
  final LocalSecurityStore _localSecurityStore;

  @override
  Future<void> resetLocalData() async {
    final supportPath = _applicationSupportDirectory.path;

    if (await _applicationSupportDirectory.exists()) {
      await _applicationSupportDirectory.delete(recursive: true);
    }

    // Recreate the private root before publishing "no setup state". This keeps
    // reset retry-safe even when providers still hold the same Directory path.
    await Directory(supportPath).create(recursive: true);

    // Clear security state LAST. Once this succeeds, bootstrap may safely route
    // to fresh setup because the current private application data is gone.
    await _localSecurityStore.clear();
  }
}
