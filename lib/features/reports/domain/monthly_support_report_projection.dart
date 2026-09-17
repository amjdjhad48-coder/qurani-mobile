import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class MonthlySupportReportWeeklyInputIdentity {
  const MonthlySupportReportWeeklyInputIdentity({
    required this.reportId,
    required this.period,
    required this.sourceFingerprint,
    required this.approvedAtUtc,
  });

  final int reportId;
  final WeeklySupportReportPeriod period;
  final String sourceFingerprint;
  final DateTime approvedAtUtc;
}

final class MonthlySupportReportDayEntryProjection {
  const MonthlySupportReportDayEntryProjection({
    required this.sourceStudentId,
    required this.attendanceStatus,
    required this.achievedQuarterFaces,
    required this.range,
    required this.note,
    required this.entryOrder,
  });

  final int sourceStudentId;
  final SupportReportAttendanceStatus? attendanceStatus;
  final int achievedQuarterFaces;
  final SupportReportQuranRange? range;
  final String? note;
  final int entryOrder;
}

final class MonthlySupportReportDayProjection {
  MonthlySupportReportDayProjection({
    required this.sourceWeeklyReportId,
    required this.localDate,
    required this.dayKind,
    required Iterable<MonthlySupportReportDayEntryProjection> entries,
  }) : entries = List<MonthlySupportReportDayEntryProjection>.unmodifiable(
         entries,
       );

  final int sourceWeeklyReportId;
  final DateTime localDate;
  final SupportReportDayKind dayKind;
  final List<MonthlySupportReportDayEntryProjection> entries;
}

final class MonthlySupportReportStudentProjection {
  const MonthlySupportReportStudentProjection({
    required this.sourceStudentId,
    required this.studentName,
    required this.monthlyGoalQuarterFaces,
    required this.achievedQuarterFaces,
    required this.absenceDays,
    required this.goalCompleted,
    required this.displayOrder,
    this.supportStudentNumber,
    this.currentJuz,
    this.dailyPlanText,
    this.note,
  });

  final int sourceStudentId;
  final String? supportStudentNumber;
  final String studentName;
  final int? currentJuz;
  final String? dailyPlanText;
  final int monthlyGoalQuarterFaces;
  final int achievedQuarterFaces;
  final int absenceDays;
  final bool goalCompleted;
  final String? note;
  final int displayOrder;
}

final class MonthlySupportReportProjection {
  MonthlySupportReportProjection({
    required this.halaqahId,
    required this.period,
    required this.header,
    required Iterable<MonthlySupportReportStudentProjection> students,
    required Iterable<MonthlySupportReportDayProjection> days,
    required Iterable<MonthlySupportReportWeeklyInputIdentity> weeklyInputs,
    required Iterable<ReportMissingItem> missingItems,
  }) : students = List<MonthlySupportReportStudentProjection>.unmodifiable(
         students,
       ),
       days = List<MonthlySupportReportDayProjection>.unmodifiable(days),
       weeklyInputs =
           List<MonthlySupportReportWeeklyInputIdentity>.unmodifiable(
             weeklyInputs,
           ),
       missingItems = List<ReportMissingItem>.unmodifiable(missingItems) {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    final studentIds = <int>{};

    for (final student in this.students) {
      if (!studentIds.add(student.sourceStudentId)) {
        throw ArgumentError(
          'Monthly report projection contains duplicate student ids.',
        );
      }
    }

    var previousDate = period.monthStart.subtract(const Duration(days: 1));

    for (final day in this.days) {
      if (!period.containsDate(day.localDate)) {
        throw ArgumentError(
          'Monthly report day lies outside the Gregorian month.',
        );
      }

      if (!day.localDate.isAfter(previousDate)) {
        throw ArgumentError(
          'Monthly report days must be unique and strictly ordered.',
        );
      }

      previousDate = day.localDate;

      for (final entry in day.entries) {
        if (!studentIds.contains(entry.sourceStudentId)) {
          throw ArgumentError(
            'Monthly report day entry references an unknown student.',
          );
        }
      }
    }

    for (final item in this.missingItems) {
      if (!studentIds.contains(item.studentId)) {
        throw ArgumentError(
          'Monthly report missing item references an unknown student.',
        );
      }

      final date = item.localDate;

      if (date != null && !period.containsDate(date)) {
        throw ArgumentError(
          'Monthly report missing item lies outside the Gregorian month.',
        );
      }
    }
  }

  final int halaqahId;
  final MonthlySupportReportPeriod period;
  final SupportReportHeaderSnapshot header;
  final List<MonthlySupportReportStudentProjection> students;
  final List<MonthlySupportReportDayProjection> days;
  final List<MonthlySupportReportWeeklyInputIdentity> weeklyInputs;
  final List<ReportMissingItem> missingItems;

  bool get hasWarnings => missingItems.isNotEmpty;

  MonthlySupportReportStudentProjection studentById(int sourceStudentId) {
    return students.firstWhere(
      (student) => student.sourceStudentId == sourceStudentId,
      orElse: () => throw StateError(
        'Student $sourceStudentId is not part of this monthly report.',
      ),
    );
  }

  List<ReportMissingItem> missingItemsForStudent(int sourceStudentId) {
    return List<ReportMissingItem>.unmodifiable(
      missingItems.where((item) => item.studentId == sourceStudentId),
    );
  }
}

abstract interface class ApprovedWeeklySupportReportsForMonthRepository {
  Future<List<ApprovedWeeklySupportReportSnapshot>>
  findApprovedIntersectingMonth({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  });
}
