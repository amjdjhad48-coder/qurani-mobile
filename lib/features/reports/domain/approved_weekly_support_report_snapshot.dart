import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class ApprovedWeeklySupportReportSnapshot {
  ApprovedWeeklySupportReportSnapshot({
    required this.reportId,
    required this.halaqahId,
    required this.period,
    required this.header,
    required this.sourceFingerprint,
    required this.approvedAtUtc,
    required Iterable<ApprovedWeeklySupportReportStudentSnapshot> students,
    required Iterable<ApprovedWeeklySupportReportDaySnapshot> days,
  }) : students = List<ApprovedWeeklySupportReportStudentSnapshot>.unmodifiable(
         students,
       ),
       days = List<ApprovedWeeklySupportReportDaySnapshot>.unmodifiable(days);

  final int reportId;
  final int halaqahId;
  final WeeklySupportReportPeriod period;
  final SupportReportHeaderSnapshot header;
  final String sourceFingerprint;
  final DateTime approvedAtUtc;
  final List<ApprovedWeeklySupportReportStudentSnapshot> students;
  final List<ApprovedWeeklySupportReportDaySnapshot> days;
}

final class ApprovedWeeklySupportReportStudentSnapshot {
  const ApprovedWeeklySupportReportStudentSnapshot({
    required this.snapshotRowId,
    required this.sourceStudentId,
    required this.studentName,
    required this.monthlyGoalQuarterFaces,
    required this.displayOrder,
    this.supportStudentNumber,
    this.currentJuz,
    this.dailyPlanText,
    this.note,
  });

  final int snapshotRowId;
  final int sourceStudentId;
  final String? supportStudentNumber;
  final String studentName;
  final int? currentJuz;
  final String? dailyPlanText;
  final int monthlyGoalQuarterFaces;
  final String? note;
  final int displayOrder;
}

final class ApprovedWeeklySupportReportDaySnapshot {
  ApprovedWeeklySupportReportDaySnapshot({
    required this.snapshotRowId,
    required this.localDate,
    required this.dayKind,
    required Iterable<ApprovedWeeklySupportReportDayEntrySnapshot> entries,
  }) : entries = List<ApprovedWeeklySupportReportDayEntrySnapshot>.unmodifiable(
         entries,
       );

  final int snapshotRowId;
  final DateTime localDate;
  final SupportReportDayKind dayKind;
  final List<ApprovedWeeklySupportReportDayEntrySnapshot> entries;
}

final class ApprovedWeeklySupportReportDayEntrySnapshot {
  const ApprovedWeeklySupportReportDayEntrySnapshot({
    required this.snapshotRowId,
    required this.sourceStudentId,
    required this.attendanceStatus,
    required this.achievedQuarterFaces,
    required this.range,
    required this.note,
    required this.entryOrder,
  });

  final int snapshotRowId;
  final int sourceStudentId;
  final SupportReportAttendanceStatus? attendanceStatus;
  final int achievedQuarterFaces;
  final SupportReportQuranRange? range;
  final String? note;
  final int entryOrder;
}

abstract interface class WeeklySupportReportSnapshotRepository {
  Future<ApprovedWeeklySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  });

  Future<void> replaceApproved({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  });
}
