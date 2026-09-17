import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

enum SupportReportAttendanceStatus {
  present('present'),
  absent('absent'),
  excusedAbsent('excused_absent');

  const SupportReportAttendanceStatus(this.storageValue);

  final String storageValue;

  static SupportReportAttendanceStatus fromStorage(String value) {
    return switch (value) {
      'present' => SupportReportAttendanceStatus.present,
      'absent' => SupportReportAttendanceStatus.absent,
      'excused_absent' => SupportReportAttendanceStatus.excusedAbsent,
      _ => throw StateError(
        'Unsupported support report attendance status: $value',
      ),
    };
  }
}

final class SupportReportQuranRange {
  const SupportReportQuranRange({
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });

  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
}

final class WeeklySupportReportRecitationProjection {
  const WeeklySupportReportRecitationProjection({
    required this.achievedQuarterFaces,
    required this.range,
    this.note,
  });

  final int achievedQuarterFaces;
  final SupportReportQuranRange range;
  final String? note;
}

final class WeeklySupportReportDayEntryProjection {
  WeeklySupportReportDayEntryProjection({
    required this.sourceStudentId,
    required this.attendanceStatus,
    Iterable<WeeklySupportReportRecitationProjection> newMemorizationEntries =
        const <WeeklySupportReportRecitationProjection>[],
  }) : newMemorizationEntries =
           List<WeeklySupportReportRecitationProjection>.unmodifiable(
             newMemorizationEntries,
           );

  final int sourceStudentId;
  final SupportReportAttendanceStatus? attendanceStatus;

  /// Only new memorization belongs to support-report achievement.
  ///
  /// Revision recitations are intentionally excluded before this boundary.
  final List<WeeklySupportReportRecitationProjection> newMemorizationEntries;
}

final class WeeklySupportReportStudentProjection {
  const WeeklySupportReportStudentProjection({
    required this.sourceStudentId,
    required this.studentName,
    required this.displayOrder,
    this.supportStudentNumber,
    this.currentJuz,
    this.dailyPlanText,
    this.note,
    this.monthlyGoalQuarterFaces = SupportReportPolicy.monthlyGoalQuarterFaces,
  });

  final int sourceStudentId;
  final String? supportStudentNumber;
  final String studentName;
  final int? currentJuz;
  final String? dailyPlanText;
  final String? note;
  final int monthlyGoalQuarterFaces;
  final int displayOrder;
}

final class WeeklySupportReportDayProjection {
  WeeklySupportReportDayProjection({
    required DateTime localDate,
    required this.dayKind,
    Iterable<WeeklySupportReportDayEntryProjection> entries =
        const <WeeklySupportReportDayEntryProjection>[],
  }) : localDate = SupportReportPolicy.dateOnly(localDate),
       entries = List<WeeklySupportReportDayEntryProjection>.unmodifiable(
         entries,
       );

  final DateTime localDate;
  final SupportReportDayKind dayKind;
  final List<WeeklySupportReportDayEntryProjection> entries;
}

final class WeeklySupportReportProjection {
  factory WeeklySupportReportProjection({
    required WeeklySupportReportPeriod period,
    required SupportReportHeaderSnapshot header,
    required Iterable<WeeklySupportReportStudentProjection> students,
    required Iterable<WeeklySupportReportDayProjection> days,
    Iterable<ReportMissingItem> missingItems = const <ReportMissingItem>[],
  }) {
    final studentList = List<WeeklySupportReportStudentProjection>.unmodifiable(
      students,
    );

    final dayList = List<WeeklySupportReportDayProjection>.unmodifiable(days);

    final missingList = List<ReportMissingItem>.unmodifiable(missingItems);

    final studentIds = <int>{};

    for (final student in studentList) {
      if (!studentIds.add(student.sourceStudentId)) {
        throw ArgumentError(
          'Weekly support projection contains duplicate student id '
          '${student.sourceStudentId}.',
        );
      }
    }

    final expectedDates = period.officialDates;

    if (dayList.length != expectedDates.length) {
      throw ArgumentError(
        'Weekly support projection must contain exactly '
        '${expectedDates.length} official days.',
      );
    }

    for (var index = 0; index < expectedDates.length; index++) {
      final actualDate = SupportReportPolicy.dateOnly(dayList[index].localDate);

      if (actualDate != expectedDates[index]) {
        throw ArgumentError(
          'Weekly support projection day at index $index must be '
          '${expectedDates[index]}, but was $actualDate.',
        );
      }

      final dayStudentIds = <int>{};

      for (final entry in dayList[index].entries) {
        if (!studentIds.contains(entry.sourceStudentId)) {
          throw ArgumentError(
            'Day entry references unknown student id '
            '${entry.sourceStudentId}.',
          );
        }

        if (!dayStudentIds.add(entry.sourceStudentId)) {
          throw ArgumentError(
            'Day ${dayList[index].localDate} contains more than one '
            'aggregate entry for student ${entry.sourceStudentId}.',
          );
        }
      }
    }

    for (final missingItem in missingList) {
      if (!studentIds.contains(missingItem.studentId)) {
        throw ArgumentError(
          'Missing item references unknown student id '
          '${missingItem.studentId}.',
        );
      }

      final missingDate = missingItem.localDate;

      if (missingDate != null && !period.containsOfficialDate(missingDate)) {
        throw ArgumentError(
          'Missing item date $missingDate is outside the official week.',
        );
      }
    }

    return WeeklySupportReportProjection._(
      period: period,
      header: header,
      students: studentList,
      days: dayList,
      missingItems: missingList,
    );
  }

  const WeeklySupportReportProjection._({
    required this.period,
    required this.header,
    required this.students,
    required this.days,
    required this.missingItems,
  });

  final WeeklySupportReportPeriod period;
  final SupportReportHeaderSnapshot header;
  final List<WeeklySupportReportStudentProjection> students;
  final List<WeeklySupportReportDayProjection> days;
  final List<ReportMissingItem> missingItems;

  bool get hasWarnings => missingItems.isNotEmpty;

  WeeklySupportReportStudentProjection studentById(int sourceStudentId) {
    return students.firstWhere(
      (student) => student.sourceStudentId == sourceStudentId,
    );
  }

  WeeklySupportReportDayProjection dayForDate(DateTime localDate) {
    final normalized = SupportReportPolicy.dateOnly(localDate);

    return days.firstWhere((day) => day.localDate == normalized);
  }

  int achievedQuarterFacesForStudent(int sourceStudentId) {
    var total = 0;

    for (final day in days) {
      for (final entry in day.entries) {
        if (entry.sourceStudentId != sourceStudentId) {
          continue;
        }

        for (final recitation in entry.newMemorizationEntries) {
          total += recitation.achievedQuarterFaces;
        }
      }
    }

    return total;
  }

  List<ReportMissingItem> missingItemsForStudent(int sourceStudentId) {
    return List<ReportMissingItem>.unmodifiable(
      missingItems.where((item) => item.studentId == sourceStudentId),
    );
  }
}
