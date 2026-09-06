final class LockPolicy {
  LockPolicy._();

  static const Duration autoLockAfter = Duration(minutes: 5);
  static const bool requiresPinOnProcessStart = true;

  static Duration? lockDurationAfterFailedAttempts(int failedAttempts) {
    if (failedAttempts < 0) {
      throw RangeError.value(
        failedAttempts,
        'failedAttempts',
        'Must be zero or greater.',
      );
    }

    if (failedAttempts == 5) {
      return const Duration(minutes: 1);
    }

    if (failedAttempts == 10) {
      return const Duration(minutes: 5);
    }

    if (failedAttempts >= 15 && failedAttempts % 5 == 0) {
      return const Duration(minutes: 15);
    }

    return null;
  }
}
