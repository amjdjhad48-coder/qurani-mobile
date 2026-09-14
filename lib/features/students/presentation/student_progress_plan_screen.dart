import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/domain/student.dart';

class StudentProgressPlanScreen extends StatefulWidget {
  const StudentProgressPlanScreen({
    required this.service,
    required this.studentId,
    required this.initialPlan,
    super.key,
  });

  final StudentService service;
  final int studentId;
  final StudentProgressPlanRecord? initialPlan;

  @override
  State<StudentProgressPlanScreen> createState() =>
      _StudentProgressPlanScreenState();
}

class _StudentProgressPlanScreenState extends State<StudentProgressPlanScreen> {
  late final TextEditingController _currentJuzController;
  late final TextEditingController _dailyPlanController;

  var _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    _currentJuzController = TextEditingController(
      text: widget.initialPlan?.currentJuz?.toString() ?? '',
    );

    _dailyPlanController = TextEditingController(
      text: widget.initialPlan?.dailyPlanText ?? '',
    );
  }

  @override
  void dispose() {
    _currentJuzController.dispose();
    _dailyPlanController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    final rawJuz = _currentJuzController.text.trim();

    int? currentJuz;

    if (rawJuz.isNotEmpty) {
      currentJuz = int.tryParse(rawJuz);

      if (currentJuz == null || currentJuz < 1 || currentJuz > 30) {
        setState(() {
          _errorText = 'الجزء الحالي يجب أن يكون رقمًا من 1 إلى 30.';
        });

        return;
      }
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      final saved = await widget.service.updateProgressPlan(
        UpdateStudentProgressPlanRequest(
          studentId: widget.studentId,
          currentJuz: currentJuz,
          dailyPlanText: _dailyPlanController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop<StudentProgressPlanRecord>(saved);
    } on ArgumentError {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorText = 'الجزء الحالي يجب أن يكون رقمًا من 1 إلى 30.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _saving = false;
        _errorText = 'تعذر حفظ تقدم الطالب وخطته.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('student_progress_plan_screen'),
      appBar: AppBar(
        title: const Text('تعديل التقدم والخطة'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              key: const Key('current_juz_field'),
              controller: _currentJuzController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'الجزء الحالي',
                hintText: 'اختياري - من 1 إلى 30',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('daily_plan_text_field'),
              controller: _dailyPlanController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'الخطة اليومية',
                hintText: 'اختيارية',
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorText != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                key: const Key('progress_plan_error'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('save_progress_plan_button'),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ الخطة'),
            ),
          ],
        ),
      ),
    );
  }
}
