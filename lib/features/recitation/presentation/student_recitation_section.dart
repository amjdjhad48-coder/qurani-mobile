import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';
import 'package:qurani/features/recitation/presentation/recitation_form_screen.dart';

class StudentRecitationSection extends StatefulWidget {
  const StudentRecitationSection({
    required this.service,
    required this.halaqahId,
    required this.dayId,
    required this.studentId,
    required this.studentName,
    this.onChanged,
    super.key,
  });

  final RecitationService service;
  final int halaqahId;
  final int dayId;
  final int studentId;
  final String studentName;
  final VoidCallback? onChanged;

  @override
  State<StudentRecitationSection> createState() =>
      _StudentRecitationSectionState();
}

class _StudentRecitationSectionState extends State<StudentRecitationSection> {
  List<RecitationRecord> _records = const <RecitationRecord>[];
  RecitationDerivedTotals? _totals;
  String? _errorText;
  var _loading = true;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void didUpdateWidget(covariant StudentRecitationSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dayId != widget.dayId ||
        oldWidget.studentId != widget.studentId ||
        oldWidget.service != widget.service) {
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
      final records = await widget.service.listForDayStudent(
        halaqahId: widget.halaqahId,
        dayId: widget.dayId,
        studentId: widget.studentId,
      );

      final totals = await widget.service.totalsForDayStudent(
        halaqahId: widget.halaqahId,
        dayId: widget.dayId,
        studentId: widget.studentId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _records = records;
        _totals = totals;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorText = 'تعذر تحميل بيانات التسميع.';
      });
    }
  }

  Future<void> _openForm([RecitationRecord? existing]) async {
    if (_busy) {
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => RecitationFormScreen(
          service: widget.service,
          halaqahId: widget.halaqahId,
          dayId: widget.dayId,
          studentId: widget.studentId,
          studentName: widget.studentName,
          existing: existing,
        ),
      ),
    );

    if (changed != true || !mounted) {
      return;
    }

    await _load();

    if (!mounted) {
      return;
    }

    widget.onChanged?.call();
  }

  Future<void> _delete(RecitationRecord record) async {
    if (_busy) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف التسميع'),
          content: const Text(
            'سيتم حذف عملية التسميع المحددة فقط. هل تريد المتابعة؟',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              key: Key('confirm_delete_recitation_${record.id}'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('حذف'),
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
      await widget.service.delete(
        halaqahId: widget.halaqahId,
        recitationId: record.id,
      );

      await _load();

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
      });

      widget.onChanged?.call();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف التسميع.')));
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'تعذر حذف التسميع.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totals;

    return Column(
      key: Key('student_recitation_section_${widget.studentId}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Divider(),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'التسميع',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              key: Key('add_recitation_${widget.studentId}'),
              onPressed: _busy
                  ? null
                  : () {
                      unawaited(_openForm());
                    },
              icon: const Icon(Icons.add),
              label: const Text('إضافة تسميع'),
            ),
          ],
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          )
        else ...<Widget>[
          if (totals != null)
            Container(
              key: Key('recitation_totals_${widget.studentId}'),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'التقدم المحسوب - الحفظ الجديد فقط: '
                    '${totals.newMemorizationQuarterFaces} ربع وجه',
                  ),
                  const SizedBox(height: 4),
                  Text('المراجعة: ${totals.revisionQuarterFaces} ربع وجه'),
                ],
              ),
            ),
          if (_records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text('لا توجد عمليات تسميع مسجلة لهذا الطالب اليوم.'),
            )
          else
            ..._records.map(_recordCard),
        ],
        if (_errorText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            _errorText!,
            key: Key('recitation_error_${widget.studentId}'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _recordCard(RecitationRecord record) {
    final plannedRange = record.plannedRange;

    return Container(
      key: Key('recitation_record_${record.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${_typeLabel(record.type)} - '
                  '${record.evaluation.arabicLabel}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                key: Key('edit_recitation_${record.id}'),
                tooltip: 'تعديل التسميع',
                onPressed: _busy
                    ? null
                    : () {
                        unawaited(_openForm(record));
                      },
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: Key('delete_recitation_${record.id}'),
                tooltip: 'حذف التسميع',
                onPressed: _busy
                    ? null
                    : () {
                        unawaited(_delete(record));
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Text(
            'الفعلي: من ${_positionText(record.actualRange.start)} '
            'إلى ${_positionText(record.actualRange.end)}',
          ),
          const SizedBox(height: 4),
          Text(
            'الإنجاز: ${record.facesQuarterAchieved} ربع وجه'
            ' - الأخطاء: ${record.errorCount}',
          ),
          if (plannedRange != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'المقرر: من ${_positionText(plannedRange.start)} '
              'إلى ${_positionText(plannedRange.end)}',
            ),
          ],
          if (record.note case final note?) ...<Widget>[
            if (note.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text('ملاحظة: $note'),
            ],
          ],
        ],
      ),
    );
  }

  String _typeLabel(RecitationType type) {
    return switch (type) {
      RecitationType.newMemorization => 'حفظ جديد',
      RecitationType.revision => 'مراجعة',
    };
  }

  String _positionText(QuranPosition position) {
    final surah = QuranReferenceData.surahByNumber(position.surahNumber);
    return '${surah.arabicName} ${position.ayahNumber}';
  }
}
