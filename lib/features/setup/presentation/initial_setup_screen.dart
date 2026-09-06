import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/core/security/pin_policy.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/domain/initial_setup_request.dart';

class InitialSetupScreen extends ConsumerStatefulWidget {
  const InitialSetupScreen({required this.recovering, super.key});

  final bool recovering;

  @override
  ConsumerState<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends ConsumerState<InitialSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teacherController = TextEditingController();
  final _halaqahController = TextEditingController();
  final _centerController = TextEditingController();
  final _organizationController = TextEditingController();
  final _pinController = TextEditingController();

  var _hasSupportOrganization = false;
  var _busy = false;
  String? _errorText;

  @override
  void dispose() {
    _teacherController.dispose();
    _halaqahController.dispose();
    _centerController.dispose();
    _organizationController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validatePin(String? value) {
    final pin = value ?? '';
    if (!PinPolicy.isValid(pin)) {
      return 'أدخل PIN من 6 أرقام. غير مسموح: 000000، 111111، 123456، 654321.';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final form = _formKey.currentState;
    if (form == null || !form.validate() || _busy) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    final request = InitialSetupRequest(
      teacherName: _teacherController.text,
      halaqahName: _halaqahController.text,
      centerName: _centerController.text,
      hasSupportOrganization: _hasSupportOrganization,
      supportOrganizationName: _hasSupportOrganization
          ? _organizationController.text
          : null,
      pin: _pinController.text,
    );

    try {
      final submitter = ref.read(initialSetupSubmitterProvider);
      await submitter(request);

      if (!mounted) {
        return;
      }

      ref.invalidate(initialSetupPhaseProvider);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorText =
            'تعذر إكمال الإعداد وحفظه بأمان. تحقق من البيانات وحاول مرة أخرى.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الإعداد الأول'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('تهيئة الحلقة', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'أدخل البيانات الأساسية للحلقة، ثم أنشئ رمز PIN محليًا لحماية التطبيق.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (widget.recovering) ...<Widget>[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'يوجد إعداد سابق غير مكتمل. أعد إدخال نفس بيانات الحلقة ورمز PIN لاستكماله بأمان.',
                            key: const Key('setup_recovery_notice'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const Key('teacher_name_field'),
                      controller: _teacherController,
                      enabled: !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم المعلم',
                      ),
                      validator: (value) =>
                          _requiredText(value, 'اسم المعلم مطلوب.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('halaqah_name_field'),
                      controller: _halaqahController,
                      enabled: !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم الحلقة',
                      ),
                      validator: (value) =>
                          _requiredText(value, 'اسم الحلقة مطلوب.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('center_name_field'),
                      controller: _centerController,
                      enabled: !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم المركز/المسجد',
                      ),
                      validator: (value) =>
                          _requiredText(value, 'اسم المركز/المسجد مطلوب.'),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile.adaptive(
                      key: const Key('support_toggle'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('هل توجد جهة داعمة؟'),
                      subtitle: Text(_hasSupportOrganization ? 'نعم' : 'لا'),
                      value: _hasSupportOrganization,
                      onChanged: _busy
                          ? null
                          : (value) {
                              setState(() {
                                _hasSupportOrganization = value;
                                _errorText = null;
                                if (!value) {
                                  _organizationController.clear();
                                }
                              });
                            },
                    ),
                    if (_hasSupportOrganization) ...<Widget>[
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const Key('support_organization_field'),
                        controller: _organizationController,
                        enabled: !_busy,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'اسم الجهة الداعمة',
                        ),
                        validator: (value) => _requiredText(
                          value,
                          'اسم الجهة الداعمة مطلوب عند اختيار نعم.',
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('pin_field'),
                      controller: _pinController,
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      maxLength: PinPolicy.requiredLength,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                          PinPolicy.requiredLength,
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'PIN من 6 أرقام',
                        helperText: 'يُطلب عند فتح التطبيق وبعد القفل المحلي.',
                      ),
                      validator: _validatePin,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_errorText != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        _errorText!,
                        key: const Key('setup_error_text'),
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      key: const Key('submit_setup_button'),
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.recovering
                                  ? 'استكمال الإعداد'
                                  : 'إنشاء PIN وحفظ الإعداد',
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
