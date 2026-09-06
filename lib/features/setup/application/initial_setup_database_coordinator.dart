import 'dart:typed_data';

import 'package:qurani/features/setup/domain/initial_setup_request.dart';

abstract interface class InitialSetupDatabaseCoordinator {
  Future<bool> finalDatabaseExists();

  Future<bool> candidateDatabaseExists();

  Future<void> discardCandidate();

  Future<void> buildAndVerifyCandidate({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
    required DateTime createdAtUtc,
  });

  Future<void> verifyCandidate({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
  });

  Future<void> verifyFinal({
    required InitialSetupRequest request,
    required Uint8List databaseKey,
  });

  Future<void> publishCandidate();
}
