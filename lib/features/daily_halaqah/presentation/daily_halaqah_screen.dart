import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/presentation/attendance_status_selector.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_history_screen.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_summary_screen.dart';
import 'package:qurani/features/recitation/presentation/student_recitation_section.dart';

class DailyHalaqahScreen extends StatefulWidget {
  const DailyHalaqahScreen({required this.runtimeContext, super.key});

  final DailyHalaqahRuntimeContext runtimeContext;

  @override
  State<DailyHalaqahScreen> createState() => _DailyHalaqahScreenState();
}

class _DailyHalaqahScreenState extends State<DailyHalaqahScreen> {
  final Map<int, GlobalKey> _studentKeys = <int, GlobalKey>{};

  HalaqahDaySummary? _summary;
  String? _errorText;
  var _loading = true;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorText = null;
      });
    }

    try {
      final session = await widget.runtimeContext.service.startToday(
        halaqahId: widget.runtimeContext.halaqahId,
      );

      final summary = await widget.runtimeContext.readService.summary(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: session.day.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = summary;
        _loading = false;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _busy = false;
        _errorText = 'تعذر فتح يوم الحلقة.';
      });
    }
  }

  Future<void> _reloadSummary() async {
    final summary = _summary;
    if (summary == null) {
      return;
    }

    final reloaded = await widget.runtimeContext.readService.summary(
      halaqahId: widget.runtimeContext.halaqahId,
      dayId: summary.day.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _summary = reloaded;
    });
  }

  Future<void> _setAttendance(int studentId, AttendanceStatus status) async {
    final summary = _summary;

    if (_busy || summary == null) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      await widget.runtimeContext.service.setAttendance(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: summary.day.id,
        studentId: studentId,
        status: status,
      );

      await _reloadSummary();

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
        _errorText = 'تعذر حفظ حالة الحضور.';
      });
    }
  }

  Future<void> _markAllPresent() async {
    final summary = _summary;

    if (_busy || summary == null || !summary.day.isOpen) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      await widget.runtimeContext.service.markAllPresent(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: summary.day.id,
      );

      await _reloadSummary();

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
        _errorText = 'تعذر تحديد الجميع حاضرًا.';
      });
    }
  }

  Future<void> _markHolidayRange() async {
    if (_busy) {
      return;
    }

    final today = widget.runtimeContext.clock.todayLocal();

    final range = await showDateRangePicker(
      context: context,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 365)),
      currentDate: today,
      initialDateRange: DateTimeRange(start: today, end: today),
      helpText: 'تحديد إجازة',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      saveText: 'حفظ',
    );

    if (range == null || !mounted) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      await widget.runtimeContext.holidayService.markRange(
        halaqahId: widget.runtimeContext.halaqahId,
        startLocalDate: range.start,
        endLocalDate: range.end,
      );

      await _load();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تسجيل الإجازة.')));
    } on HolidayConflictException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText =
            'تعذر تسجيل الإجازة لأن ${error.conflictingDayDates.length} '
            'يوم يحتوي نشاطًا فعليًا أو أنه منتهٍ.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر تسجيل الإجازة.';
      });
    }
  }

  Future<void> _endDay() async {
    final summary = _summary;

    if (_busy || summary == null || !summary.day.isOpen) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إنهاء يوم الحلقة'),
          content: const Text(
            'سيتم إنهاء اليوم بعد التأكد من اكتمال حالات الحضور.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              key: const Key('confirm_end_day_button'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('إنهاء اليوم'),
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
      final closed = await widget.runtimeContext.closeDayCore(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: summary.day.id,
      );

      final reloaded = await widget.runtimeContext.readService.summary(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: closed.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = reloaded;
        _busy = false;
      });

      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => HalaqahDaySummaryScreen(
            runtimeContext: widget.runtimeContext,
            dayId: closed.id,
          ),
        ),
      );

      if (mounted) {
        await _reloadSummary();
      }
    } on IncompleteAttendanceException catch (error) {
      final reloaded = await widget.runtimeContext.readService.summary(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: summary.day.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = reloaded;
        _busy = false;
        _errorText =
            'بقي ${error.missingCount} طالب دون حالة حضور. '
            'أكمل الحضور أولًا.';
      });

      if (error.missingStudentIds.isNotEmpty) {
        _scrollToStudent(error.missingStudentIds.first);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر إنهاء يوم الحلقة.';
      });
    }
  }

  void _scrollToStudent(int studentId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentContext = _studentKeys[studentId]?.currentContext;

      if (studentContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        studentContext,
        duration: const Duration(milliseconds: 300),
        alignment: 0.15,
      );
    });
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            HalaqahDayHistoryScreen(runtimeContext: widget.runtimeContext),
      ),
    );

    if (mounted) {
      await _reloadSummary();
    }
  }

  Future<void> _openSummary() async {
    final summary = _summary;

    if (summary == null) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => HalaqahDaySummaryScreen(
          runtimeContext: widget.runtimeContext,
          dayId: summary.day.id,
        ),
      ),
    );

    if (mounted) {
      await _reloadSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Scaffold(
      key: const Key('daily_halaqah_screen'),
      appBar: AppBar(
        title: const Text('يوم الحلقة'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            key: const Key('open_day_history_button'),
            tooltip: 'سجل الأيام',
            onPressed: _busy
                ? null
                : () {
                    unawaited(_openHistory());
                  },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: summary?.day.isOpen == true
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  key: const Key('end_halaqah_day_button'),
                  onPressed: _busy
                      ? null
                      : () {
                          unawaited(_endDay());
                        },
                  icon: const Icon(Icons.task_alt),
                  label: const Text('إنهاء يوم الحلقة'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('daily_halaqah_loading')),
      );
    }

    final summary = _summary;

    if (summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _errorText ?? 'تعذر فتح يوم الحلقة.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (summary.day.isHoliday) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  Icon(Icons.event_busy_outlined, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'اليوم إجازة',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'لا تُسجل حالات غياب ولا يُحسب أي طالب غائبًا.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () {
                    unawaited(_openHistory());
                  },
            icon: const Icon(Icons.history),
            label: const Text('سجل الأيام'),
          ),
        ],
      );
    }

    final counts = summary.attendance;

    return ListView(
      key: const Key('daily_halaqah_student_list'),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  summary.day.dayDate,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'الحضور: ${counts.totalStudents - counts.unsetCount}'
                  '/${counts.totalStudents}',
                  textAlign: TextAlign.center,
                ),
                if (counts.unsetCount > 0) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    'متبقي ${counts.unsetCount} دون تحديد.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_errorText != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            key: const Key('daily_halaqah_error'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 8),
        if (summary.day.isOpen)
          FilledButton.tonalIcon(
            key: const Key('mark_all_present_button'),
            onPressed: _busy
                ? null
                : () {
                    unawaited(_markAllPresent());
                  },
            icon: const Icon(Icons.done_all),
            label: const Text('تحديد الجميع حاضر'),
          ),
        if (summary.day.isOpen) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('mark_holiday_range_button'),
            onPressed: _busy
                ? null
                : () {
                    unawaited(_markHolidayRange());
                  },
            icon: const Icon(Icons.event_busy_outlined),
            label: const Text('تسجيل إجازة ليوم أو فترة'),
          ),
        ],
        if (summary.day.isClosed) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('open_current_day_summary_button'),
            onPressed: _busy
                ? null
                : () {
                    unawaited(_openSummary());
                  },
            icon: const Icon(Icons.summarize_outlined),
            label: const Text('عرض ملخص اليوم'),
          ),
        ],
        const SizedBox(height: 12),
        ...summary.students.map((item) {
          final studentId = item.student.id;
          final studentKey = _studentKeys.putIfAbsent(studentId, GlobalKey.new);

          return Card(
            key: studentKey,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    item.student.studentName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  AttendanceStatusSelector(
                    value: item.attendanceStatus,
                    keyPrefix: 'daily_student_$studentId',
                    onChanged: _busy
                        ? null
                        : (status) {
                            unawaited(_setAttendance(studentId, status));
                          },
                  ),
                  if (item.isAttendanceUnset) ...<Widget>[
                    const SizedBox(height: 8),
                    const Text('لم يحدد الحضور بعد.'),
                  ],
                  if (widget.runtimeContext.recitationService
                      case final recitationService?) ...<Widget>[
                    const SizedBox(height: 12),
                    StudentRecitationSection(
                      service: recitationService,
                      halaqahId: widget.runtimeContext.halaqahId,
                      dayId: summary.day.id,
                      studentId: studentId,
                      studentName: item.student.studentName,
                      onChanged: () {
                        _scrollToStudent(studentId);
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
