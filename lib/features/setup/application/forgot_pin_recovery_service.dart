abstract interface class LocalResetCoordinator {
  Future<void> resetLocalData();
}

final class ForgotPinRecoveryService {
  const ForgotPinRecoveryService(this._resetCoordinator);

  final LocalResetCoordinator _resetCoordinator;

  Future<void> resetAndStartOver() {
    return _resetCoordinator.resetLocalData();
  }
}
