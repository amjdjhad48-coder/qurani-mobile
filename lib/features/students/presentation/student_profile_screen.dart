import 'package:flutter/material.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_form_screen.dart';
import 'package:qurani/features/students/presentation/student_progress_plan_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({
    required this.service,
    required this.student,
    super.key,
  });

  final StudentService service;
  final StudentRecord student;

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late StudentRecord _student;

  StudentProgressPlanRecord? _progressPlan;

  List<StudentActivityPeriodRecord> _activityPeriods =
      const <StudentActivityPeriodRecord>[];

  var _loadingProgress = true;
  var _loadingActivityPeriods = true;
  var _openingEdit = false;
  var _openingProgressEditor = false;
  var _lifecycleBusy = false;

  String? _errorText;

  @override
  void initState() {
    super.initState();

    _student = widget.student;

    Future<void>.microtask(_loadProgress);
    Future<void>.microtask(_loadActivityPeriods);
  }

  Future<void> _loadProgress() async {
    try {
      final progress = await widget.service.getProgressPlan(_student.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _progressPlan = progress;
        _loadingProgress = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingProgress = false;
        _errorText = 'تعذر تحميل تقدم الطالب وخطته.';
      });
    }
  }

  Future<void> _loadActivityPeriods() async {
    try {
      final periods = await widget.service.activityPeriodsForStudent(
        _student.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _activityPeriods = List<StudentActivityPeriodRecord>.unmodifiable(
          periods,
        );
        _loadingActivityPeriods = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingActivityPeriods = false;
        _errorText = 'تعذر تحميل سجل نشاط الطالب.';
      });
    }
  }

  Future<void> _openEdit() async {
    if (_openingEdit || _lifecycleBusy) {
      return;
    }

    setState(() {
      _openingEdit = true;
      _errorText = null;
    });

    try {
      final supportStatus = await widget.service.supportStatusForHalaqah(
        _student.halaqahId,
      );

      if (!mounted) {
        return;
      }

      final saved = await Navigator.of(context).push<StudentRecord>(
        MaterialPageRoute<StudentRecord>(
          builder: (context) => StudentFormScreen(
            service: widget.service,
            halaqahId: _student.halaqahId,
            supportStatus: supportStatus,
            student: _student,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _openingEdit = false;

        if (saved != null) {
          _student = saved;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _openingEdit = false;
        _errorText = 'تعذر فتح تعديل بيانات الطالب.';
      });
    }
  }

  Future<bool> _confirmArchive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: const Key('archive_student_dialog'),
          title: const Text('أرشفة الطالب'),
          content: const Text(
            'سيتم أرشفة الطالب وإغلاق فترة نشاطه الحالية مع الاحتفاظ بسجل نشاطه.',
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('cancel_archive_student_button'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              key: const Key('confirm_archive_student_button'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('تأكيد الأرشفة'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<bool> _confirmReactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          key: const Key('reactivate_student_dialog'),
          title: const Text('إعادة تفعيل الطالب'),
          content: const Text(
            'سيتم إعادة تفعيل الطالب واستئناف نشاطه مع الاحتفاظ بسجله السابق.',
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('cancel_reactivate_student_button'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              key: const Key('confirm_reactivate_student_button'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('تأكيد إعادة التفعيل'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _archiveStudent() async {
    if (_lifecycleBusy || !_student.isActive) {
      return;
    }

    final confirmed = await _confirmArchive();

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _lifecycleBusy = true;
      _errorText = null;
    });

    try {
      final saved = await widget.service.archive(_student.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _student = saved;
        _lifecycleBusy = false;
        _loadingActivityPeriods = true;
      });

      await _loadActivityPeriods();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _lifecycleBusy = false;
        _errorText = 'تعذر أرشفة الطالب.';
      });
    }
  }

  Future<void> _reactivateStudent() async {
    if (_lifecycleBusy || _student.isActive) {
      return;
    }

    final confirmed = await _confirmReactivate();

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _lifecycleBusy = true;
      _errorText = null;
    });

    try {
      final saved = await widget.service.reactivate(_student.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _student = saved;
        _lifecycleBusy = false;
        _loadingActivityPeriods = true;
      });

      await _loadActivityPeriods();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _lifecycleBusy = false;
        _errorText =
            'تعذر إعادة تفعيل الطالب. تحقق من بياناته ثم حاول مرة أخرى.';
      });
    }
  }

  Future<void> _openProgressPlanEditor() async {
    if (_openingProgressEditor || _loadingProgress || _lifecycleBusy) {
      return;
    }

    setState(() {
      _openingProgressEditor = true;
      _errorText = null;
    });

    try {
      final saved = await Navigator.of(context).push<StudentProgressPlanRecord>(
        MaterialPageRoute<StudentProgressPlanRecord>(
          builder: (context) => StudentProgressPlanScreen(
            service: widget.service,
            studentId: _student.id,
            initialPlan: _progressPlan,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _openingProgressEditor = false;

        if (saved != null) {
          _progressPlan = saved;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _openingProgressEditor = false;
        _errorText = 'تعذر فتح تعديل تقدم الطالب وخطته.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportNumber = _student.supportStudentNumber;
    final note = _student.note;

    return Scaffold(
      key: const Key('student_profile_screen'),
      appBar: AppBar(
        title: const Text('ملف الطالب'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            key: const Key('edit_student_button'),
            onPressed: (_openingEdit || _lifecycleBusy) ? null : _openEdit,
            tooltip: 'تعديل بيانات الطالب',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              key: const Key('student_profile_identity'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      _student.studentName,
                      key: const Key('student_profile_name'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 14),
                    _ProfileRow(label: 'اسم الأب', value: _student.fatherName),
                    _ProfileRow(
                      label: 'العمر',
                      value: _student.ageYears.toString(),
                    ),
                    _ProfileRow(
                      label: 'رقم ولي الأمر',
                      value:
                          '${_student.guardianCountryCode} ${_student.guardianNationalNumber}',
                    ),
                    _ProfileRow(
                      label: 'الحفظ السابق',
                      value: _student.previousMemorizationText,
                    ),
                    if (supportNumber != null && supportNumber.isNotEmpty)
                      _ProfileRow(
                        label: 'رقم الجهة الداعمة',
                        value: supportNumber,
                      ),
                    if (note != null && note.isNotEmpty)
                      _ProfileRow(label: 'ملاحظة', value: note),
                    _ProfileRow(
                      label: 'الحالة',
                      value: _student.isActive ? 'نشط' : 'مؤرشف',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              key: const Key('student_profile_lifecycle_actions'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _student.isActive
                    ? FilledButton.tonalIcon(
                        key: const Key('archive_student_button'),
                        onPressed: _lifecycleBusy ? null : _archiveStudent,
                        icon: const Icon(Icons.archive_outlined),
                        label: Text(
                          _lifecycleBusy ? 'جارٍ التنفيذ...' : 'أرشفة الطالب',
                        ),
                      )
                    : FilledButton.icon(
                        key: const Key('reactivate_student_button'),
                        onPressed: _lifecycleBusy ? null : _reactivateStudent,
                        icon: const Icon(Icons.restore_outlined),
                        label: Text(
                          _lifecycleBusy
                              ? 'جارٍ التنفيذ...'
                              : 'إعادة تفعيل الطالب',
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('edit_progress_plan_button'),
                onPressed:
                    (_loadingProgress ||
                        _openingProgressEditor ||
                        _lifecycleBusy)
                    ? null
                    : _openProgressPlanEditor,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('تعديل التقدم والخطة'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              key: const Key('student_profile_progress'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'التقدم والخطة',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_loadingProgress)
                      const Center(
                        child: CircularProgressIndicator(
                          key: Key('student_profile_progress_loading'),
                        ),
                      )
                    else if (_progressPlan == null)
                      const Text(
                        'لم تُحدد خطة الطالب بعد.',
                        key: Key('student_profile_progress_empty'),
                      )
                    else ...<Widget>[
                      _ProfileRow(
                        label: 'الجزء الحالي',
                        value:
                            _progressPlan!.currentJuz?.toString() ?? 'غير محدد',
                      ),
                      _ProfileRow(
                        label: 'الخطة اليومية',
                        value: _progressPlan!.dailyPlanText ?? 'غير محددة',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              key: const Key('student_activity_history'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'سجل النشاط',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (_loadingActivityPeriods)
                      const Center(
                        child: CircularProgressIndicator(
                          key: Key('student_activity_history_loading'),
                        ),
                      )
                    else if (_activityPeriods.isEmpty)
                      const Text(
                        'لا يوجد سجل نشاط.',
                        key: Key('student_activity_history_empty'),
                      )
                    else
                      ..._activityPeriods.reversed.map(
                        (period) => Padding(
                          key: ValueKey<String>(
                            'student_activity_period_${period.id}',
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'من ${period.activeFromDate} إلى '
                            '${period.activeToDate ?? 'حتى الآن'}',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_errorText != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                key: const Key('student_profile_error'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 125,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
