import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';

typedef SubmitChangePin =
    Future<RuntimeChangePinResult> Function({
      required String currentPin,
      required String newPin,
    });

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({
    required this.onSubmit,
    required this.onChanged,
    required this.onCancel,
    super.key,
  });

  final SubmitChangePin onSubmit;
  final Future<void> Function() onChanged;
  final VoidCallback onCancel;

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();

  String? _errorText;
  var _busy = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    super.dispose();
  }

  bool _isSixDigits(String value) {
    return RegExp(r'^\d{6}$').hasMatch(value);
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }

    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;

    if (!_isSixDigits(currentPin)) {
      setState(() {
        _errorText = 'أدخل PIN الحالي من 6 أرقام.';
      });
      return;
    }

    if (!_isSixDigits(newPin)) {
      setState(() {
        _errorText = 'أدخل PIN الجديد من 6 أرقام.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final result = await widget.onSubmit(
        currentPin: currentPin,
        newPin: newPin,
      );

      if (!mounted) {
        return;
      }

      switch (result.status) {
        case RuntimeChangePinStatus.changed:
          _currentPinController.clear();
          _newPinController.clear();
          setState(() {
            _busy = false;
          });
          await widget.onChanged();
          break;
        case RuntimeChangePinStatus.invalidCurrentPin:
          setState(() {
            _busy = false;
            _errorText = 'PIN الحالي غير صحيح.';
          });
          break;
      }
    } on ArgumentError {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'PIN الجديد غير مقبول.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر تغيير PIN بأمان.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('change_pin_screen'),
      appBar: AppBar(title: const Text('تغيير PIN'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'يتم تغيير طريقة فتح المفاتيح فقط. بيانات التطبيق وقاعدة البيانات لا تُعاد إنشاؤها.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('change_pin_current_field'),
                    controller: _currentPinController,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(labelText: 'PIN الحالي'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('change_pin_new_field'),
                    controller: _newPinController,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(labelText: 'PIN الجديد'),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_errorText != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      _errorText!,
                      key: const Key('change_pin_error'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('change_pin_submit_button'),
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('حفظ PIN الجديد'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('change_pin_cancel_button'),
                    onPressed: _busy ? null : widget.onCancel,
                    child: const Text('إلغاء'),
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
