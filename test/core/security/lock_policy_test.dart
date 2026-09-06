import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/security/lock_policy.dart';

void main() {
  group('LockPolicy', () {
    test('does not lock after failures 1 through 4', () {
      for (var failures = 1; failures <= 4; failures++) {
        expect(LockPolicy.lockDurationAfterFailedAttempts(failures), isNull);
      }
    });

    test('locks for one minute at the fifth failed attempt', () {
      expect(
        LockPolicy.lockDurationAfterFailedAttempts(5),
        const Duration(minutes: 1),
      );
    });

    test('does not create a new lock at failures 6 through 9', () {
      for (var failures = 6; failures <= 9; failures++) {
        expect(LockPolicy.lockDurationAfterFailedAttempts(failures), isNull);
      }
    });

    test('locks for five minutes at the tenth failed attempt', () {
      expect(
        LockPolicy.lockDurationAfterFailedAttempts(10),
        const Duration(minutes: 5),
      );
    });

    test('does not create a new lock at failures 11 through 14', () {
      for (var failures = 11; failures <= 14; failures++) {
        expect(LockPolicy.lockDurationAfterFailedAttempts(failures), isNull);
      }
    });

    test('locks for fifteen minutes at 15 and every further five failures', () {
      for (final failures in <int>[15, 20, 25, 30]) {
        expect(
          LockPolicy.lockDurationAfterFailedAttempts(failures),
          const Duration(minutes: 15),
        );
      }

      expect(LockPolicy.lockDurationAfterFailedAttempts(16), isNull);
      expect(LockPolicy.lockDurationAfterFailedAttempts(19), isNull);
      expect(LockPolicy.lockDurationAfterFailedAttempts(21), isNull);
    });

    test('defines five-minute inactivity auto-lock', () {
      expect(LockPolicy.autoLockAfter, const Duration(minutes: 5));
    });

    test('requires PIN after process restart', () {
      expect(LockPolicy.requiresPinOnProcessStart, isTrue);
    });

    test('accepts zero failures and rejects negative counts', () {
      expect(LockPolicy.lockDurationAfterFailedAttempts(0), isNull);
      expect(
        () => LockPolicy.lockDurationAfterFailedAttempts(-1),
        throwsRangeError,
      );
    });
  });
}
