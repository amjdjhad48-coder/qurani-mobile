import 'package:qurani/features/reports/domain/support_report_types.dart';

final class SupportReportHalaqahSource {
  const SupportReportHalaqahSource({
    required this.id,
    required this.teacherName,
    required this.halaqahName,
    required this.centerName,
  });

  final int id;
  final String teacherName;
  final String halaqahName;
  final String centerName;
}

final class SupportReportSupportPeriodSource {
  const SupportReportSupportPeriodSource({
    required this.id,
    required this.organizationName,
    required this.startedAtUtc,
    required this.endedAtUtc,
  });

  final int id;
  final String organizationName;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
}

final class SupportReportStudentActivityPeriodSource {
  const SupportReportStudentActivityPeriodSource({
    required this.id,
    required this.activeFromDate,
    required this.activeToDate,
  });

  final int id;
  final String activeFromDate;
  final String? activeToDate;
}

final class SupportReportStudentSource {
  SupportReportStudentSource({
    required this.id,
    required this.studentName,
    required this.supportStudentNumber,
    required this.note,
    required this.displayOrder,
    required this.currentJuz,
    required this.dailyPlanText,
    required Iterable<SupportReportStudentActivityPeriodSource> activityPeriods,
  }) : activityPeriods =
           List<SupportReportStudentActivityPeriodSource>.unmodifiable(
             activityPeriods,
           );

  final int id;
  final String studentName;
  final String? supportStudentNumber;
  final String? note;
  final int displayOrder;
  final int? currentJuz;
  final String? dailyPlanText;

  final List<SupportReportStudentActivityPeriodSource> activityPeriods;
}

final class SupportReportDaySource {
  const SupportReportDaySource({
    required this.id,
    required this.dayDate,
    required this.status,
  });

  final int id;
  final String dayDate;
  final String status;
}

final class SupportReportAttendanceSource {
  const SupportReportAttendanceSource({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.status,
  });

  final int id;
  final int dayId;
  final int studentId;
  final String status;
}

final class SupportReportNewMemorizationSource {
  const SupportReportNewMemorizationSource({
    required this.id,
    required this.dayId,
    required this.studentId,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
    required this.facesQuarterAchieved,
    required this.note,
  });

  final int id;
  final int dayId;
  final int studentId;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;
  final int facesQuarterAchieved;
  final String? note;
}

final class WeeklySupportReportSource {
  WeeklySupportReportSource({
    required this.period,
    required this.halaqah,
    required Iterable<SupportReportSupportPeriodSource> supportPeriods,
    required Iterable<SupportReportStudentSource> students,
    required Iterable<SupportReportDaySource> days,
    required Iterable<SupportReportAttendanceSource> attendance,
    required Iterable<SupportReportNewMemorizationSource> newMemorization,
  }) : supportPeriods = List<SupportReportSupportPeriodSource>.unmodifiable(
         supportPeriods,
       ),
       students = List<SupportReportStudentSource>.unmodifiable(students),
       days = List<SupportReportDaySource>.unmodifiable(days),
       attendance = List<SupportReportAttendanceSource>.unmodifiable(
         attendance,
       ),
       newMemorization = List<SupportReportNewMemorizationSource>.unmodifiable(
         newMemorization,
       );

  final WeeklySupportReportPeriod period;
  final SupportReportHalaqahSource halaqah;

  /// Raw historical support periods.
  ///
  /// UTC-to-local support-day interpretation intentionally belongs to
  /// report policy/application logic, not this data reader.
  final List<SupportReportSupportPeriodSource> supportPeriods;

  final List<SupportReportStudentSource> students;
  final List<SupportReportDaySource> days;
  final List<SupportReportAttendanceSource> attendance;

  /// Contains only source rows whose type is new_memorization.
  final List<SupportReportNewMemorizationSource> newMemorization;
}

abstract interface class SupportReportSourceRepository {
  Future<WeeklySupportReportSource> readWeeklySource({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  });
}
