import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/application/recitation_validator.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

class RecitationFormScreen extends StatefulWidget {
  const RecitationFormScreen({
    required this.service,
    required this.halaqahId,
    required this.dayId,
    required this.studentId,
    required this.studentName,
    this.existing,
    super.key,
  });

  final RecitationService service;
  final int halaqahId;
  final int dayId;
  final int studentId;
  final String studentName;
  final RecitationRecord? existing;

  @override
  State<RecitationFormScreen> createState() => _RecitationFormScreenState();
}

class _RecitationFormScreenState extends State<RecitationFormScreen> {
  late RecitationType _type;
  late RecitationEvaluation _evaluation;

  late int _startSurah;
  late int _endSurah;
  late int _plannedStartSurah;
  late int _plannedEndSurah;

  late final TextEditingController _startAyahController;
  late final TextEditingController _endAyahController;
  late final TextEditingController _quarterController;
  late final TextEditingController _errorController;
  late final TextEditingController _noteController;

  late final TextEditingController _plannedStartAyahController;
  late final TextEditingController _plannedEndAyahController;

  late bool _hasPlannedRange;

  String? _errorText;
  var _busy = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    final actual = existing?.actualRange;
    final planned = existing?.plannedRange;

    _type = existing?.type ?? RecitationType.newMemorization;
    _evaluation = existing?.evaluation ?? RecitationEvaluation.excellent;

    _startSurah = actual?.start.surahNumber ?? 1;
    _endSurah = actual?.end.surahNumber ?? 1;

    _startAyahController = TextEditingController(
      text: (actual?.start.ayahNumber ?? 1).toString(),
    );

    _endAyahController = TextEditingController(
      text: (actual?.end.ayahNumber ?? 1).toString(),
    );

    _quarterController = TextEditingController(
      text: (existing?.facesQuarterAchieved ?? 1).toString(),
    );

    _errorController = TextEditingController(
      text: (existing?.errorCount ?? 0).toString(),
    );

    _noteController = TextEditingController(text: existing?.note ?? '');

    _hasPlannedRange = planned != null;
    _plannedStartSurah = planned?.start.surahNumber ?? 1;
    _plannedEndSurah = planned?.end.surahNumber ?? 1;

    _plannedStartAyahController = TextEditingController(
      text: (planned?.start.ayahNumber ?? 1).toString(),
    );

    _plannedEndAyahController = TextEditingController(
      text: (planned?.end.ayahNumber ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _startAyahController.dispose();
    _endAyahController.dispose();
    _quarterController.dispose();
    _errorController.dispose();
    _noteController.dispose();
    _plannedStartAyahController.dispose();
    _plannedEndAyahController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) {
      return;
    }

    final startAyah = int.tryParse(_startAyahController.text.trim());
    final endAyah = int.tryParse(_endAyahController.text.trim());
    final quarterFaces = int.tryParse(_quarterController.text.trim());
    final errorCount = int.tryParse(_errorController.text.trim());

    int? plannedStartAyah;
    int? plannedEndAyah;

    if (_hasPlannedRange) {
      plannedStartAyah = int.tryParse(_plannedStartAyahController.text.trim());
      plannedEndAyah = int.tryParse(_plannedEndAyahController.text.trim());
    }

    final basicNumbersValid =
        startAyah != null &&
        endAyah != null &&
        quarterFaces != null &&
        quarterFaces > 0 &&
        errorCount != null &&
        errorCount >= 0 &&
        (!_hasPlannedRange ||
            (plannedStartAyah != null && plannedEndAyah != null));

    if (!basicNumbersValid) {
      setState(() {
        _errorText = 'تحقق من أرقام الآيات ومقدار الإنجاز وعدد الأخطاء.';
      });
      return;
    }

    final plannedRange = _hasPlannedRange
        ? QuranRange(
            start: QuranPosition(
              surahNumber: _plannedStartSurah,
              ayahNumber: plannedStartAyah!,
            ),
            end: QuranPosition(
              surahNumber: _plannedEndSurah,
              ayahNumber: plannedEndAyah!,
            ),
          )
        : null;

    final data = RecitationWriteData(
      type: _type,
      actualRange: QuranRange(
        start: QuranPosition(surahNumber: _startSurah, ayahNumber: startAyah),
        end: QuranPosition(surahNumber: _endSurah, ayahNumber: endAyah),
      ),
      facesQuarterAchieved: quarterFaces,
      evaluation: _evaluation,
      errorCount: errorCount,
      note: _noteController.text,
      plannedRange: plannedRange,
    );

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      if (_editing) {
        await widget.service.update(
          halaqahId: widget.halaqahId,
          recitationId: widget.existing!.id,
          data: data,
        );
      } else {
        await widget.service.createForDay(
          halaqahId: widget.halaqahId,
          dayId: widget.dayId,
          studentId: widget.studentId,
          data: data,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on RecitationValidationException {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText =
            'بيانات التسميع غير صالحة. تحقق من النطاق القرآني والقيم المدخلة.';
      });
    } on RecitationOnHolidayException {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = 'لا يمكن تسجيل التسميع في يوم إجازة.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _errorText = _editing ? 'تعذر حفظ تعديل التسميع.' : 'تعذر حفظ التسميع.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('recitation_form_screen'),
      appBar: AppBar(
        title: Text(_editing ? 'تعديل التسميع' : 'تسجيل التسميع'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  widget.studentName,
                  key: const Key('recitation_student_name'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('نوع التسميع', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<RecitationType>(
              key: const Key('recitation_type_selector'),
              segments: const <ButtonSegment<RecitationType>>[
                ButtonSegment<RecitationType>(
                  value: RecitationType.newMemorization,
                  label: Text('حفظ جديد'),
                  icon: Icon(Icons.auto_stories_outlined),
                ),
                ButtonSegment<RecitationType>(
                  value: RecitationType.revision,
                  label: Text('مراجعة'),
                  icon: Icon(Icons.replay_outlined),
                ),
              ],
              selected: <RecitationType>{_type},
              onSelectionChanged: _busy
                  ? null
                  : (selection) {
                      setState(() {
                        _type = selection.single;
                      });
                    },
            ),
            const SizedBox(height: 20),
            Text(
              'النطاق الفعلي',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _positionFields(
              surahKey: const Key('recitation_start_surah_field'),
              ayahKey: const Key('recitation_start_ayah_field'),
              label: 'من',
              surahValue: _startSurah,
              ayahController: _startAyahController,
              onSurahChanged: (value) {
                setState(() {
                  _startSurah = value;
                });
              },
            ),
            const SizedBox(height: 10),
            _positionFields(
              surahKey: const Key('recitation_end_surah_field'),
              ayahKey: const Key('recitation_end_ayah_field'),
              label: 'إلى',
              surahValue: _endSurah,
              ayahController: _endAyahController,
              onSurahChanged: (value) {
                setState(() {
                  _endSurah = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'مقدار الإنجاز',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _quarterChip(1, '1/4'),
                _quarterChip(2, '1/2'),
                _quarterChip(3, '3/4'),
                _quarterChip(4, '1 وجه'),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('recitation_quarter_field'),
              controller: _quarterController,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'عدد أرباع الوجه',
                helperText: '1 = ربع، 2 = نصف، 3 = ثلاثة أرباع، 4 = وجه كامل',
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RecitationEvaluation>(
              key: const Key('recitation_evaluation_field'),
              initialValue: _evaluation,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'التقييم'),
              items: RecitationEvaluation.values
                  .map(
                    (evaluation) => DropdownMenuItem<RecitationEvaluation>(
                      value: evaluation,
                      child: Text(evaluation.arabicLabel),
                    ),
                  )
                  .toList(growable: false),
              onChanged: _busy
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _evaluation = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('recitation_error_count_field'),
              controller: _errorController,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(labelText: 'عدد الأخطاء'),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('recitation_note_field'),
              controller: _noteController,
              enabled: !_busy,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'ملاحظة اختيارية'),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              key: const Key('recitation_planned_range_toggle'),
              contentPadding: EdgeInsets.zero,
              title: const Text('إضافة مقرر مخطط'),
              subtitle: const Text('اختياري بالكامل'),
              value: _hasPlannedRange,
              onChanged: _busy
                  ? null
                  : (value) {
                      setState(() {
                        _hasPlannedRange = value;
                      });
                    },
            ),
            if (_hasPlannedRange) ...<Widget>[
              const SizedBox(height: 8),
              _positionFields(
                surahKey: const Key('recitation_planned_start_surah_field'),
                ayahKey: const Key('recitation_planned_start_ayah_field'),
                label: 'المقرر من',
                surahValue: _plannedStartSurah,
                ayahController: _plannedStartAyahController,
                onSurahChanged: (value) {
                  setState(() {
                    _plannedStartSurah = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              _positionFields(
                surahKey: const Key('recitation_planned_end_surah_field'),
                ayahKey: const Key('recitation_planned_end_ayah_field'),
                label: 'المقرر إلى',
                surahValue: _plannedEndSurah,
                ayahController: _plannedEndAyahController,
                onSurahChanged: (value) {
                  setState(() {
                    _plannedEndSurah = value;
                  });
                },
              ),
            ],
            if (_errorText != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                key: const Key('recitation_form_error'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('save_recitation_button'),
              onPressed: _busy ? null : _save,
              icon: _busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_editing ? 'حفظ التعديل' : 'حفظ التسميع'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionFields({
    required Key surahKey,
    required Key ayahKey,
    required String label,
    required int surahValue,
    required TextEditingController ayahController,
    required ValueChanged<int> onSurahChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<int>(
            key: surahKey,
            initialValue: surahValue,
            isExpanded: true,
            decoration: InputDecoration(labelText: '$label سورة'),
            items: QuranReferenceData.surahs
                .map(
                  (surah) => DropdownMenuItem<int>(
                    value: surah.number,
                    child: Text(
                      '${surah.number}. ${surah.arabicName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) {
                      onSurahChanged(value);
                    }
                  },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 108,
          child: TextField(
            key: ayahKey,
            controller: ayahController,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(labelText: 'الآية'),
          ),
        ),
      ],
    );
  }

  Widget _quarterChip(int quarters, String label) {
    return ChoiceChip(
      key: Key('recitation_quarter_$quarters'),
      label: Text(label),
      selected: int.tryParse(_quarterController.text.trim()) == quarters,
      onSelected: _busy
          ? null
          : (_) {
              setState(() {
                _quarterController.text = quarters.toString();
              });
            },
    );
  }
}
