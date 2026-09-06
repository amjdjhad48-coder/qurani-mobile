import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({
    required this.busy,
    required this.failedAttemptCount,
    required this.lockedUntilUtc,
    required this.errorText,
    required this.onSubmit,
    required this.onForgotPin,
    super.key,
  });

  final bool busy;
  final int failedAttemptCount;
  final DateTime? lockedUntilUtc;
  final String? errorText;
  final Future<void> Function(String pin) onSubmit;
  final VoidCallback onForgotPin;

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final _pinController = TextEditingController();
  String? _localErrorText;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.busy) {
      return;
    }

    final pin = _pinController.text;
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() {
        _localErrorText = 'أدخل PIN من 6 أرقام.';
      });
      return;
    }

    setState(() {
      _localErrorText = null;
    });

    await widget.onSubmit(pin);

    if (mounted) {
      _pinController.clear();
    }
  }

  String _formatLockDeadline(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleError = _localErrorText ?? widget.errorText;

    return Scaffold(
      appBar: AppBar(title: const Text('قفل قرآني'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.lock_outline, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'أدخل PIN لفتح التطبيق',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لا تُفتح قاعدة البيانات ولا مفاتيح البيانات قبل التحقق الصحيح.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (widget.lockedUntilUtc != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'قفل مؤقت فعّال حتى ${_formatLockDeadline(widget.lockedUntilUtc!)}.',
                          key: const Key('temporary_lock_message'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  if (widget.failedAttemptCount > 0) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      'المحاولات غير الصحيحة: ${widget.failedAttemptCount}',
                      key: const Key('failed_attempt_count'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 18),
                  TextField(
                    key: const Key('pin_unlock_field'),
                    controller: _pinController,
                    enabled: !widget.busy,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(labelText: 'PIN'),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (visibleError != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      visibleError,
                      key: const Key('pin_unlock_error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('pin_unlock_button'),
                    onPressed: widget.busy ? null : _submit,
                    child: widget.busy
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('فتح التطبيق'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('forgot_pin_button'),
                    onPressed: widget.busy ? null : widget.onForgotPin,
                    child: const Text('نسيت PIN؟'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
