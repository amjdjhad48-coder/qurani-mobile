import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/presentation/daily_halaqah_screen.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_history_screen.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_summary_screen.dart';

class QuraniHomeScreen extends StatefulWidget {
  const QuraniHomeScreen({
    required this.runtimeContext,
    required this.onChangePin,
    required this.onLockNow,
    this.actionsEnabled = true,
    this.noticeText,
    super.key,
  });

  final DailyHalaqahRuntimeContext runtimeContext;
  final VoidCallback onChangePin;
  final VoidCallback onLockNow;
  final bool actionsEnabled;
  final String? noticeText;

  @override
  State<QuraniHomeScreen> createState() => _QuraniHomeScreenState();
}

class _QuraniHomeScreenState extends State<QuraniHomeScreen> {
  _HomeData? _data;
  String? _errorText;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void didUpdateWidget(covariant QuraniHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.runtimeContext.halaqahId != widget.runtimeContext.halaqahId) {
      Future<void>.microtask(_load);
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorText = null;
      });
    }

    try {
      final today = widget.runtimeContext.clock.todayLocal();

      final day = await widget.runtimeContext.service.findToday(
        halaqahId: widget.runtimeContext.halaqahId,
      );

      final activeStudents = await widget.runtimeContext.service
          .studentsActiveOn(
            halaqahId: widget.runtimeContext.halaqahId,
            localDate: today,
          );

      final summary = day == null
          ? null
          : await widget.runtimeContext.readService.summary(
              halaqahId: widget.runtimeContext.halaqahId,
              dayId: day.id,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _data = _HomeData(
          today: today,
          day: day,
          summary: summary,
          activeStudentCount: activeStudents.length,
        );
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorText = 'تعذر تحميل حالة يوم الحلقة.';
      });
    }
  }

  Future<void> _openPrimaryAction() async {
    final data = _data;

    if (data == null) {
      return;
    }

    final day = data.day;

    if (day != null && (day.isClosed || day.isHoliday)) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => HalaqahDaySummaryScreen(
            runtimeContext: widget.runtimeContext,
            dayId: day.id,
          ),
        ),
      );
    } else {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) =>
              DailyHalaqahScreen(runtimeContext: widget.runtimeContext),
        ),
      );
    }

    if (mounted) {
      await _load();
    }
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) =>
            HalaqahDayHistoryScreen(runtimeContext: widget.runtimeContext),
      ),
    );

    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('qurani_home_screen'),
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            key: const Key('change_pin_button'),
            onPressed: widget.actionsEnabled ? widget.onChangePin : null,
            tooltip: 'تغيير PIN',
            icon: const Icon(Icons.password_outlined),
          ),
          IconButton(
            key: const Key('lock_now_button'),
            onPressed: widget.actionsEnabled ? widget.onLockNow : null,
            tooltip: 'قفل التطبيق',
            icon: const Icon(Icons.lock_outline),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(key: Key('home_loading')),
      );
    }

    final data = _data;

    if (data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _errorText ?? 'تعذر تحميل الرئيسية.',
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

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          Container(
            key: const Key('home_halaqah_header'),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  widget.runtimeContext.halaqahName,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'المعلم: ${widget.runtimeContext.teacherName}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(_displayDate(data.today), textAlign: TextAlign.center),
              ],
            ),
          ),
          if (widget.noticeText != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              widget.noticeText!,
              key: const Key('runtime_notice'),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Card(
            key: const Key('home_day_card'),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'يوم الحلقة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_dayStatus(data.day), key: const Key('home_day_status')),
                  const SizedBox(height: 6),
                  Text('الطلاب النشطون اليوم: ${data.activeStudentCount}'),
                  if (_attentionText(data) case final attention?) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(attention, key: const Key('home_attention')),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const Key('home_primary_day_action'),
                    onPressed: _openPrimaryAction,
                    icon: Icon(_primaryIcon(data.day)),
                    label: Text(_primaryLabel(data.day)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('home_day_history_button'),
            onPressed: _openHistory,
            icon: const Icon(Icons.history),
            label: const Text('سجل الأيام'),
          ),
        ],
      ),
    );
  }

  String _dayStatus(HalaqahDayRecord? day) {
    if (day == null) {
      return 'لم يبدأ يوم الحلقة بعد.';
    }

    if (day.isHoliday) {
      return 'اليوم إجازة.';
    }

    if (day.isClosed) {
      return 'تم إنهاء يوم الحلقة.';
    }

    return 'يوم الحلقة جارٍ.';
  }

  String? _attentionText(_HomeData data) {
    final day = data.day;
    final summary = data.summary;

    if (day == null) {
      return 'ابدأ اليوم عند بدء الحلقة.';
    }

    if (day.isHoliday) {
      return 'لا يوجد حضور مطلوب في يوم الإجازة.';
    }

    if (day.isClosed) {
      return 'اليوم مكتمل ويمكن مراجعة الملخص.';
    }

    final unset = summary?.attendance.unsetCount ?? 0;

    if (unset > 0) {
      return 'يحتاج انتباهك: بقي $unset طالب دون حالة حضور.';
    }

    return 'الحضور مكتمل ويمكن إنهاء اليوم.';
  }

  String _primaryLabel(HalaqahDayRecord? day) {
    if (day == null) {
      return 'بدء يوم الحلقة';
    }

    if (day.isOpen) {
      return 'متابعة يوم الحلقة';
    }

    return 'عرض ملخص اليوم';
  }

  IconData _primaryIcon(HalaqahDayRecord? day) {
    if (day == null) {
      return Icons.play_arrow;
    }

    if (day.isOpen) {
      return Icons.fact_check_outlined;
    }

    return Icons.summarize_outlined;
  }

  String _displayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

final class _HomeData {
  const _HomeData({
    required this.today,
    required this.day,
    required this.summary,
    required this.activeStudentCount,
  });

  final DateTime today;
  final HalaqahDayRecord? day;
  final HalaqahDaySummary? summary;
  final int activeStudentCount;
}
