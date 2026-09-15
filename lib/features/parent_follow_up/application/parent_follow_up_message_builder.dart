import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

final class ParentFollowUpMessageBuilder {
  const ParentFollowUpMessageBuilder();

  String buildDaily(ParentFollowUpDailyPreviewInput input) {
    final studentName = _requiredText(
      input.studentName,
      fieldName: 'studentName',
    );
    final dayDate = _requiredText(input.dayDate, fieldName: 'dayDate');
    final teacherName = _requiredText(
      input.teacherName,
      fieldName: 'teacherName',
    );
    final halaqahName = _requiredText(
      input.halaqahName,
      fieldName: 'halaqahName',
    );
    final centerName = _optionalText(input.centerName);

    for (final recitation in input.recitations) {
      if (recitation.facesQuarterAchieved <= 0) {
        throw ArgumentError.value(
          recitation.facesQuarterAchieved,
          'facesQuarterAchieved',
          'Must be positive.',
        );
      }
    }

    final lines = <String>[
      'السلام عليكم ورحمة الله وبركاته',
      'متابعة الطالب: $studentName',
      'التاريخ: $dayDate',
      'الحضور: ${input.attendanceStatus.arabicLabel}',
      'التسميع:',
    ];

    if (input.recitations.isEmpty) {
      lines.add('- لا يوجد تسميع مسجل اليوم.');
    } else {
      for (final recitation in input.recitations) {
        lines.add(_recitationLine(recitation));
      }
    }

    final newMemorization = input.recitations
        .where((recitation) => recitation.isNewMemorization)
        .toList(growable: false);

    if (newMemorization.isEmpty) {
      lines.add('ما حفظه الطالب اليوم: لا يوجد حفظ جديد مسجل.');
    } else {
      final totalQuarters = newMemorization.fold<int>(
        0,
        (sum, item) => sum + item.facesQuarterAchieved,
      );

      final ranges = newMemorization
          .map((item) => _rangeText(item.actualRange))
          .join('؛ ');

      lines.add(
        'ما حفظه الطالب اليوم: $ranges '
        'بإجمالي ${_achievementText(totalQuarters)}.',
      );
    }

    final notes = input.recitations
        .map((item) => _optionalText(item.note))
        .whereType<String>()
        .toList(growable: false);

    if (notes.isEmpty) {
      lines.add('الملاحظات: لا توجد ملاحظات.');
    } else {
      lines.add('الملاحظات:');
      for (final note in notes) {
        lines.add('- $note');
      }
    }

    lines.add('المعلم: $teacherName');
    lines.add('الحلقة: $halaqahName');

    if (centerName != null) {
      lines.add('المركز: $centerName');
    }

    return lines.join('\n');
  }

  String buildAttendanceCorrection(
    ParentFollowUpAttendanceCorrectionInput input,
  ) {
    final studentName = _requiredText(
      input.studentName,
      fieldName: 'studentName',
    );
    final dayDate = _requiredText(input.dayDate, fieldName: 'dayDate');
    final teacherName = _requiredText(
      input.teacherName,
      fieldName: 'teacherName',
    );
    final halaqahName = _requiredText(
      input.halaqahName,
      fieldName: 'halaqahName',
    );
    final centerName = _optionalText(input.centerName);

    final lines = <String>[
      'السلام عليكم ورحمة الله وبركاته',
      'تصحيح متابعة الحضور',
      'الطالب: $studentName',
      'التاريخ: $dayDate',
      'الحالة السابقة: ${input.previousStatus.arabicLabel}',
      'الحالة الصحيحة: ${input.currentStatus.arabicLabel}',
      'نرجو اعتماد حالة الحضور الصحيحة الموضحة أعلاه.',
      'المعلم: $teacherName',
      'الحلقة: $halaqahName',
    ];

    if (centerName != null) {
      lines.add('المركز: $centerName');
    }

    return lines.join('\n');
  }

  String _recitationLine(ParentFollowUpRecitationPreview recitation) {
    final typeLabel = switch (recitation.type) {
      RecitationType.newMemorization => 'حفظ جديد',
      RecitationType.revision => 'مراجعة',
    };

    return '- $typeLabel: ${_rangeText(recitation.actualRange)}، '
        'الإنجاز ${_achievementText(recitation.facesQuarterAchieved)}، '
        'التقييم ${recitation.evaluation.arabicLabel}.';
  }

  String _rangeText(QuranRange range) {
    final startSurah = QuranReferenceData.surahByNumber(
      range.start.surahNumber,
    );
    final endSurah = QuranReferenceData.surahByNumber(range.end.surahNumber);

    if (range.start.surahNumber == range.end.surahNumber) {
      return 'سورة ${startSurah.arabicName} '
          'من الآية ${range.start.ayahNumber} '
          'إلى الآية ${range.end.ayahNumber}';
    }

    return 'من سورة ${startSurah.arabicName} '
        'الآية ${range.start.ayahNumber} '
        'إلى سورة ${endSurah.arabicName} '
        'الآية ${range.end.ayahNumber}';
  }

  String _achievementText(int quarters) {
    return switch (quarters) {
      1 => 'ربع وجه',
      2 => 'نصف وجه',
      3 => 'ثلاثة أرباع وجه',
      4 => 'وجه واحد',
      _ => _multiFaceText(quarters),
    };
  }

  String _multiFaceText(int quarters) {
    final wholeFaces = quarters ~/ 4;
    final remainder = quarters % 4;

    final wholeText = switch (wholeFaces) {
      0 => '',
      1 => 'وجه واحد',
      2 => 'وجهان',
      >= 3 && <= 10 => '$wholeFaces أوجه',
      _ => '$wholeFaces وجهًا',
    };

    final remainderText = switch (remainder) {
      0 => '',
      1 => 'ربع وجه',
      2 => 'نصف وجه',
      3 => 'ثلاثة أرباع وجه',
      _ => throw StateError('Unsupported quarter remainder: $remainder'),
    };

    if (wholeText.isEmpty) {
      return remainderText;
    }

    if (remainderText.isEmpty) {
      return wholeText;
    }

    return '$wholeText و$remainderText';
  }

  String _requiredText(String value, {required String fieldName}) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(value, fieldName, 'Must not be blank.');
    }

    return normalized;
  }

  String? _optionalText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
