import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/presentation/attendance_status_selector.dart';

class HalaqahDaySummaryScreen extends StatefulWidget {
  const HalaqahDaySummaryScreen({
    required this.runtimeContext,
    required this.dayId,
    super.key,
  });

  final DailyHalaqahRuntimeContext runtimeContext;
  final int dayId;

  @override
  State<HalaqahDaySummaryScreen> createState() =>
      _HalaqahDaySummaryScreenState();
}

class _HalaqahDaySummaryScreenState extends State<HalaqahDaySummaryScreen> {
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
      final summary = await widget.runtimeContext.readService.summary(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: widget.dayId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = summary;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorText = 'تعذر تحميل ملخص اليوم.';
      });
    }
  }

  Future<void> _setAttendance(int studentId, AttendanceStatus status) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      await widget.runtimeContext.service.setAttendance(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: widget.dayId,
        studentId: studentId,
        status: status,
      );

      final summary = await widget.runtimeContext.readService.summary(
        halaqahId: widget.runtimeContext.halaqahId,
        dayId: widget.dayId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summary = summary;
        _busy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر تعديل حالة الحضور.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('halaqah_day_summary_screen'),
      appBar: AppBar(title: const Text('ملخص اليوم'), centerTitle: true),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('day_summary_loading')),
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
                _errorText ?? 'تعذر تحميل ملخص اليوم.',
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

    final counts = summary.attendance;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        Text(
          summary.day.dayDate,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _dayStatusLabel(summary.day),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                Text('الإجمالي: ${counts.totalStudents}'),
                Text('حاضر: ${counts.presentCount}'),
                Text('غائب: ${counts.absentCount}'),
                Text('بعذر: ${counts.excusedAbsentCount}'),
                if (counts.unsetCount > 0)
                  Text('غير محدد: ${counts.unsetCount}'),
              ],
            ),
          ),
        ),
        if (_errorText != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        if (summary.day.isHoliday)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'هذا اليوم إجازة، ولا يُحسب أي طالب غائبًا.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...summary.students.map(
            (item) => Card(
              key: ValueKey<String>('day_summary_student_${item.student.id}'),
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
                      keyPrefix: 'summary_student_${item.student.id}',
                      onChanged: _busy
                          ? null
                          : (status) {
                              unawaited(
                                _setAttendance(item.student.id, status),
                              );
                            },
                    ),
                    if (item.isAttendanceUnset) ...<Widget>[
                      const SizedBox(height: 8),
                      const Text('لم تحدد حالة الحضور بعد.'),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _dayStatusLabel(HalaqahDayRecord day) {
    if (day.isHoliday) {
      return 'إجازة';
    }

    if (day.isClosed) {
      return 'يوم منتهٍ';
    }

    return 'يوم جارٍ';
  }
}
