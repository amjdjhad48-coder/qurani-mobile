import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/core/shared/core_providers.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/application/session_auto_lock_controller.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/presentation/change_pin_screen.dart';
import 'package:qurani/features/setup/presentation/forgot_pin_recovery_screen.dart';
import 'package:qurani/features/setup/presentation/pin_lock_screen.dart';
import 'package:qurani/app/qurani_main_shell.dart';

class RuntimeLockGate extends ConsumerStatefulWidget {
  const RuntimeLockGate({required this.onLocalResetComplete, super.key});

  final Future<void> Function() onLocalResetComplete;

  @override
  ConsumerState<RuntimeLockGate> createState() => _RuntimeLockGateState();
}

class _RuntimeLockGateState extends ConsumerState<RuntimeLockGate>
    with WidgetsBindingObserver {
  RuntimeLockSnapshot? _snapshot;
  SessionAutoLockController? _autoLockController;
  String? _errorText;
  String? _noticeText;
  var _busy = true;
  var _loadFailed = false;
  var _showChangePin = false;
  var _showForgotPinRecovery = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _autoLockController;
    _autoLockController = null;
    if (controller != null) {
      unawaited(controller.dispose());
    }
    super.dispose();
  }

  Future<RuntimeLockCoordinator> _coordinator() {
    return ref.read(runtimeLockCoordinatorProvider.future);
  }

  SessionAutoLockController _ensureAutoLockController(
    RuntimeLockCoordinator coordinator,
  ) {
    return _autoLockController ??= SessionAutoLockController(
      lockCoordinator: coordinator,
      clock: ref.read(clockProvider),
      onAutoLocked: _refreshAfterAutoLock,
    );
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _busy = true;
        _loadFailed = false;
        _errorText = null;
        _noticeText = null;
        _showChangePin = false;
        _showForgotPinRecovery = false;
      });
    }

    try {
      final coordinator = await _coordinator();
      final snapshot = await coordinator.inspect();
      final autoLockController = _ensureAutoLockController(coordinator);

      if (snapshot.unlocked) {
        autoLockController.onUnlocked();
      } else {
        autoLockController.onLocked();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _unlock(String pin) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
      _noticeText = null;
      _showChangePin = false;
      _showForgotPinRecovery = false;
    });

    try {
      final coordinator = await _coordinator();
      final result = await coordinator.unlock(pin);

      if (result.status == RuntimeUnlockStatus.unlocked) {
        _ensureAutoLockController(coordinator).onUnlocked();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = result.snapshot;
        _busy = false;

        switch (result.status) {
          case RuntimeUnlockStatus.unlocked:
            _errorText = null;
            break;
          case RuntimeUnlockStatus.invalidPin:
            _errorText = 'PIN غير صحيح.';
            break;
          case RuntimeUnlockStatus.temporarilyLocked:
            _errorText = result.snapshot.lockedUntilUtc == null
                ? 'PIN غير صحيح.'
                : 'تم تفعيل القفل المؤقت.';
            break;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر التحقق من PIN بأمان.';
      });
    }
  }

  Future<RuntimeChangePinResult> _changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final coordinator = await _coordinator();
    return coordinator.changePin(currentPin: currentPin, newPin: newPin);
  }

  void _openChangePin() {
    _recordUserActivity();

    setState(() {
      _showChangePin = true;
      _showForgotPinRecovery = false;
      _noticeText = null;
    });
  }

  Future<void> _finishChangePin() async {
    _recordUserActivity();

    if (!mounted) {
      return;
    }

    setState(() {
      _showChangePin = false;
      _showForgotPinRecovery = false;
      _noticeText = 'تم تغيير PIN بنجاح.';
    });
  }

  void _cancelChangePin() {
    _recordUserActivity();

    setState(() {
      _showChangePin = false;
      _showForgotPinRecovery = false;
    });
  }

  void _openForgotPinRecovery() {
    setState(() {
      _showForgotPinRecovery = true;
      _showChangePin = false;
      _errorText = null;
      _noticeText = null;
    });
  }

  void _cancelForgotPinRecovery() {
    setState(() {
      _showForgotPinRecovery = false;
    });
  }

  Future<void> _resetForForgotPin() async {
    final coordinator = await _coordinator();

    // Defensive close/wipe first. The normal Forgot-PIN entry is already locked,
    // but this keeps the destructive operation safe if the call path changes.
    _autoLockController?.onLocked();
    await coordinator.lock();

    final recoveryService = await ref.read(
      forgotPinRecoveryServiceProvider.future,
    );
    await recoveryService.resetAndStartOver();

    await widget.onLocalResetComplete();
  }

  Future<void> _lockNow() async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
      _noticeText = null;
      _showChangePin = false;
      _showForgotPinRecovery = false;
    });

    try {
      final coordinator = await _coordinator();
      _autoLockController?.onLocked();
      await coordinator.lock();
      final snapshot = await coordinator.inspect();

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _loadFailed = true;
      });
    }
  }

  Future<void> _refreshAfterAutoLock() async {
    try {
      final coordinator = await _coordinator();
      final snapshot = await coordinator.inspect();

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _busy = false;
        _errorText = null;
        _noticeText = null;
        _showChangePin = false;
        _showForgotPinRecovery = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _loadFailed = true;
        _showChangePin = false;
        _showForgotPinRecovery = false;
      });
    }
  }

  void _recordUserActivity() {
    _autoLockController?.recordUserActivity();
  }

  Future<void> _handleResume() async {
    final controller = _autoLockController;
    if (controller == null) {
      return;
    }

    final locked = await controller.onResumed();
    if (locked) {
      await _refreshAfterAutoLock();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_handleResume());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _autoLockController?.onBackgrounded();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'تعذر تهيئة القفل المحلي.',
                    key: Key('runtime_lock_error'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: _busy ? null : _load,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final snapshot = _snapshot;
    if (snapshot == null) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (snapshot.unlocked) {
      return Listener(
        key: const Key('runtime_activity_listener'),
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _recordUserActivity(),
        onPointerSignal: (_) => _recordUserActivity(),
        child: _showChangePin
            ? ChangePinScreen(
                onSubmit: _changePin,
                onChanged: _finishChangePin,
                onCancel: _cancelChangePin,
              )
            : KeyedSubtree(
                key: const Key('runtime_unlocked_surface'),
                child: QuraniMainShell(
                  actionsEnabled: !_busy,
                  noticeText: _noticeText,
                  onChangePin: _openChangePin,
                  onLockNow: () {
                    unawaited(_lockNow());
                  },
                ),
              ),
      );
    }

    if (_showForgotPinRecovery) {
      return ForgotPinRecoveryScreen(
        onResetConfirmed: _resetForForgotPin,
        onBack: _cancelForgotPinRecovery,
        onRestoreFromBackup: null,
      );
    }

    return PinLockScreen(
      busy: _busy,
      failedAttemptCount: snapshot.failedAttemptCount,
      lockedUntilUtc: snapshot.lockedUntilUtc,
      errorText: _errorText,
      onSubmit: _unlock,
      onForgotPin: _openForgotPinRecovery,
    );
  }
}
