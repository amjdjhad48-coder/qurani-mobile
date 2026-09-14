import 'package:flutter/material.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';
import 'package:qurani/features/students/domain/student.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({
    required this.service,
    required this.halaqahId,
    required this.supportStatus,
    this.student,
    super.key,
  });

  final StudentService service;
  final int halaqahId;
  final String supportStatus;
  final StudentRecord? student;

  bool get editing => student != null;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _studentNameController;
  late final TextEditingController _fatherNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _guardianPhoneController;
  late final TextEditingController _previousMemorizationController;
  late final TextEditingController _noteController;
  late final TextEditingController _supportNumberController;

  late GuardianPhoneCountry _guardianCountry;

  var _busy = false;
  String? _errorText;

  bool get _showSupportNumber => widget.supportStatus != 'disabled';

  bool get _supportNumberRequired => widget.supportStatus == 'enabled';

  @override
  void initState() {
    super.initState();

    final student = widget.student;

    _studentNameController = TextEditingController(
      text: student?.studentName ?? '',
    );
    _fatherNameController = TextEditingController(
      text: student?.fatherName ?? '',
    );
    _ageController = TextEditingController(
      text: student == null ? '' : student.ageYears.toString(),
    );
    _guardianPhoneController = TextEditingController(
      text: student?.guardianNationalNumber ?? '',
    );
    _previousMemorizationController = TextEditingController(
      text: student?.previousMemorizationText ?? '',
    );
    _noteController = TextEditingController(text: student?.note ?? '');
    _supportNumberController = TextEditingController(
      text: student?.supportStudentNumber ?? '',
    );

    _guardianCountry = student?.guardianCountryCode == '+966'
        ? GuardianPhoneCountry.saudiArabia
        : GuardianPhoneCountry.yemen;
  }

  @override
  void dispose() {
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _ageController.dispose();
    _guardianPhoneController.dispose();
    _previousMemorizationController.dispose();
    _noteController.dispose();
    _supportNumberController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _validateAge(String? value) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'العمر مطلوب.';
    }

    if (int.tryParse(text) == null) {
      return 'أدخل العمر كرقم صحيح.';
    }

    return null;
  }

  String? _validateSupportNumber(String? value) {
    if (!_supportNumberRequired) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'رقم الجهة الداعمة مطلوب للطالب النشط بعد تفعيل الدعم.';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final form = _formKey.currentState;
    if (form == null || !form.validate() || _busy) {
      return;
    }

    final age = int.tryParse(_ageController.text.trim());
    if (age == null) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final student = widget.student;

      final saved = student == null
          ? await widget.service.create(
              CreateStudentRequest(
                halaqahId: widget.halaqahId,
                studentName: _studentNameController.text,
                fatherName: _fatherNameController.text,
                ageYears: age,
                guardianCountry: _guardianCountry,
                guardianPhoneInput: _guardianPhoneController.text,
                previousMemorizationText: _previousMemorizationController.text,
                note: _noteController.text,
                supportStudentNumber: _showSupportNumber
                    ? _supportNumberController.text
                    : null,
              ),
            )
          : await widget.service.edit(
              EditStudentRequest(
                studentId: student.id,
                studentName: _studentNameController.text,
                fatherName: _fatherNameController.text,
                ageYears: age,
                guardianCountry: _guardianCountry,
                guardianPhoneInput: _guardianPhoneController.text,
                previousMemorizationText: _previousMemorizationController.text,
                note: _noteController.text,
                supportStudentNumber: _showSupportNumber
                    ? _supportNumberController.text
                    : null,
              ),
            );

      if (!mounted) {
        return;
      }

      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop<StudentRecord>(saved);
      } else {
        setState(() {
          _busy = false;
        });
      }
    } on FormatException {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'رقم ولي الأمر غير صحيح للدولة المختارة.';
      });
    } on ArgumentError {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر حفظ بيانات الطالب. راجع البيانات المدخلة.';
      });
    } on StateError {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر حفظ بيانات الطالب في حالته الحالية.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر حفظ بيانات الطالب. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('student_form_screen'),
      appBar: AppBar(
        title: Text(widget.editing ? 'تعديل الطالب' : 'إضافة طالب'),
        centerTitle: true,
      ),
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
                    TextFormField(
                      key: const Key('student_name_field'),
                      controller: _studentNameController,
                      enabled: !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم الطالب',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _requiredText(value, 'اسم الطالب مطلوب.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('father_name_field'),
                      controller: _fatherNameController,
                      enabled: !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'اسم الأب',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _requiredText(value, 'اسم الأب مطلوب.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('age_field'),
                      controller: _ageController,
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'العمر',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateAge,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<GuardianPhoneCountry>(
                      key: const Key('guardian_country_field'),
                      initialValue: _guardianCountry,
                      decoration: const InputDecoration(
                        labelText: 'دولة رقم ولي الأمر',
                        border: OutlineInputBorder(),
                      ),
                      items: const <DropdownMenuItem<GuardianPhoneCountry>>[
                        DropdownMenuItem<GuardianPhoneCountry>(
                          value: GuardianPhoneCountry.yemen,
                          child: Text('اليمن (+967)'),
                        ),
                        DropdownMenuItem<GuardianPhoneCountry>(
                          value: GuardianPhoneCountry.saudiArabia,
                          child: Text('السعودية (+966)'),
                        ),
                      ],
                      onChanged: _busy
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _guardianCountry = value;
                                _errorText = null;
                              });
                            },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('guardian_phone_field'),
                      controller: _guardianPhoneController,
                      enabled: !_busy,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'رقم ولي الأمر',
                        hintText: 'محلي أو دولي',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _requiredText(value, 'رقم ولي الأمر مطلوب.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('previous_memorization_field'),
                      controller: _previousMemorizationController,
                      enabled: !_busy,
                      textInputAction: TextInputAction.next,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'الحفظ السابق',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          _requiredText(value, 'الحفظ السابق مطلوب.'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('note_field'),
                      controller: _noteController,
                      enabled: !_busy,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظة - اختيارية',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_showSupportNumber) ...<Widget>[
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('support_student_number_field'),
                        controller: _supportNumberController,
                        enabled: !_busy,
                        textDirection: TextDirection.ltr,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'رقم الجهة الداعمة',
                          helperText: _supportNumberRequired
                              ? 'مطلوب لأن الدعم مفعّل.'
                              : 'يمكن إدخاله الآن قبل تفعيل الدعم.',
                          border: const OutlineInputBorder(),
                        ),
                        validator: _validateSupportNumber,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                    ],
                    if (_errorText != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        _errorText!,
                        key: const Key('student_form_error'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const Key('submit_student_button'),
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.editing ? 'حفظ التعديلات' : 'إضافة الطالب',
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
