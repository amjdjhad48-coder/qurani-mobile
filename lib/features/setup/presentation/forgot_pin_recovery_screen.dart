import 'package:flutter/material.dart';

class ForgotPinRecoveryScreen extends StatefulWidget {
  const ForgotPinRecoveryScreen({
    required this.onResetConfirmed,
    required this.onBack,
    this.onRestoreFromBackup,
    super.key,
  });

  final Future<void> Function() onResetConfirmed;
  final VoidCallback onBack;

  // Package 10 supplies this callback when the real Backup/Restore flow exists.
  // Null in Package 2 deliberately keeps Restore unavailable rather than
  // inventing a bypass.
  final VoidCallback? onRestoreFromBackup;

  @override
  State<ForgotPinRecoveryScreen> createState() =>
      _ForgotPinRecoveryScreenState();
}

class _ForgotPinRecoveryScreenState extends State<ForgotPinRecoveryScreen> {
  String? _errorText;
  var _busy = false;

  Future<void> _confirmReset() async {
    if (_busy) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('مسح البيانات المحلية؟'),
          content: const Text(
            'سيتم حذف بيانات قرآني المحلية الحالية على هذا الجهاز والبدء من جديد. '
            'لا يمكن استرجاع البيانات المحذوفة إلا من نسخة احتياطية صالحة.',
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('cancel_local_reset_button'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              key: const Key('confirm_local_reset_button'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('مسح والبدء من جديد'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      await widget.onResetConfirmed();

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText =
            'تعذر إكمال المسح بأمان. لم يتم تجاوز PIN؛ يمكنك إعادة المحاولة.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('forgot_pin_recovery_screen'),
      appBar: AppBar(
        leading: IconButton(
          key: const Key('forgot_pin_back_button'),
          onPressed: _busy ? null : widget.onBack,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'رجوع',
        ),
        title: const Text('نسيت PIN'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(Icons.security_outlined, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد طريقة لتجاوز PIN أو استرجاعه من هذا الجهاز.',
                    key: const Key('forgot_pin_no_bypass_message'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'يمكنك الاستعادة من نسخة احتياطية صالحة، أو مسح البيانات المحلية والبدء من جديد.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.tonalIcon(
                    key: const Key('restore_from_backup_button'),
                    onPressed: _busy ? null : widget.onRestoreFromBackup,
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('استعادة من نسخة احتياطية'),
                  ),
                  if (widget.onRestoreFromBackup == null) ...<Widget>[
                    const SizedBox(height: 8),
                    const Text(
                      'سيتم تفعيل الاستعادة هنا عند اكتمال ميزة النسخ الاحتياطي والاستعادة.',
                      key: Key('restore_not_available_notice'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('reset_and_start_over_button'),
                    onPressed: _busy ? null : _confirmReset,
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('مسح البيانات والبدء من جديد'),
                  ),
                  if (_errorText != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      key: const Key('forgot_pin_reset_error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
