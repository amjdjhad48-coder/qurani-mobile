import 'dart:async';

import 'package:qurani/core/security/lock_policy.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';

abstract interface class SessionTimerHandle {
  void cancel();
}

typedef SessionTimerFactory =
    SessionTimerHandle Function(Duration duration, void Function() callback);

final class SessionAutoLockController {
  factory SessionAutoLockController({
    required RuntimeLockCoordinator lockCoordinator,
    required Clock clock,
    required Future<void> Function() onAutoLocked,
    SessionTimerFactory? timerFactory,
  }) {
    return SessionAutoLockController._(
      lockCoordinator,
      clock,
      onAutoLocked,
      timerFactory ?? _createDartTimer,
    );
  }

  SessionAutoLockController._(
    this._lockCoordinator,
    this._clock,
    this._onAutoLocked,
    this._timerFactory,
  );

  final RuntimeLockCoordinator _lockCoordinator;
  final Clock _clock;
  final Future<void> Function() _onAutoLocked;
  final SessionTimerFactory _timerFactory;

  SessionTimerHandle? _timer;
  DateTime? _backgroundedAtUtc;
  var _unlocked = false;
  var _lockInProgress = false;
  var _disposed = false;

  bool get isUnlocked => _unlocked;

  bool get isBackgrounded => _backgroundedAtUtc != null;

  void onUnlocked() {
    _ensureNotDisposed();

    _unlocked = true;
    _backgroundedAtUtc = null;
    _arm(LockPolicy.autoLockAfter);
  }

  void recordUserActivity() {
    if (_disposed || !_unlocked || isBackgrounded || _lockInProgress) {
      return;
    }

    _arm(LockPolicy.autoLockAfter);
  }

  void onBackgrounded() {
    if (_disposed || !_unlocked || _lockInProgress) {
      return;
    }

    if (_backgroundedAtUtc != null) {
      return;
    }

    _backgroundedAtUtc = _clock.nowUtc();
    _cancelTimer();
  }

  Future<bool> onResumed() async {
    if (_disposed || !_unlocked || _lockInProgress) {
      return false;
    }

    final backgroundedAtUtc = _backgroundedAtUtc;
    _backgroundedAtUtc = null;

    if (backgroundedAtUtc == null) {
      _arm(LockPolicy.autoLockAfter);
      return false;
    }

    final backgroundDuration = _clock.nowUtc().difference(backgroundedAtUtc);

    if (backgroundDuration >= LockPolicy.autoLockAfter) {
      await _lockDueToInactivity();
      return true;
    }

    // Returning to Qurani is user activity. The approved behavior explicitly
    // allows quick WhatsApp/imo returns inside the grace without a PIN.
    _arm(LockPolicy.autoLockAfter);
    return false;
  }

  void onLocked() {
    if (_disposed) {
      return;
    }

    _unlocked = false;
    _backgroundedAtUtc = null;
    _cancelTimer();
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _unlocked = false;
    _backgroundedAtUtc = null;
    _cancelTimer();
  }

  void _arm(Duration duration) {
    _cancelTimer();
    _timer = _timerFactory(duration, () {
      unawaited(_lockDueToInactivity());
    });
  }

  Future<void> _lockDueToInactivity() async {
    if (_disposed || !_unlocked || _lockInProgress) {
      return;
    }

    _lockInProgress = true;
    _unlocked = false;
    _backgroundedAtUtc = null;
    _cancelTimer();

    try {
      await _lockCoordinator.lock();
    } finally {
      _lockInProgress = false;
      await _onAutoLocked();
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('SessionAutoLockController is disposed.');
    }
  }

  static SessionTimerHandle _createDartTimer(
    Duration duration,
    void Function() callback,
  ) {
    return _DartSessionTimerHandle(Timer(duration, callback));
  }
}

final class _DartSessionTimerHandle implements SessionTimerHandle {
  _DartSessionTimerHandle(this._timer);

  final Timer _timer;

  @override
  void cancel() {
    _timer.cancel();
  }
}
