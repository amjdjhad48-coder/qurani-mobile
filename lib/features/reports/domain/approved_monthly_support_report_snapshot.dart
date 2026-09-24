import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class ApprovedMonthlySupportReportSnapshot {
  ApprovedMonthlySupportReportSnapshot({
    required this.reportId,
    required this.halaqahId,
    required this.period,
    required this.header,
    required this.sourceFingerprint,
    required this.approvedAtUtc,
    required Iterable<ApprovedMonthlySupportReportStudentSnapshot> students,
    required Iterable<ApprovedMonthlySupportReportDaySnapshot> days,
  }) : students =
           List<ApprovedMonthlySupportReportStudentSnapshot>.unmodifiable(
             students,
           ),
       days = List<ApprovedMonthlySupportReportDaySnapshot>.unmodifiable(days);

  final int reportId;
  final int halaqahId;
  final MonthlySupportReportPeriod period;
  final SupportReportHeaderSnapshot header;
  final String sourceFingerprint;
  final DateTime approvedAtUtc;
  final List<ApprovedMonthlySupportReportStudentSnapshot> students;
  final List<ApprovedMonthlySupportReportDaySnapshot> days;
}

final class ApprovedMonthlySupportReportStudentSnapshot {
  const ApprovedMonthlySupportReportStudentSnapshot({
    required this.snapshotRowId,
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

  final int snapshotRowId;
  final int sourceStudentId;
  final String? supportStudentNumber;
  final String studentName;
  final int? currentJuz;
  final String? dailyPlanText;
  final int? monthlyGoalQuarterFaces;
  final int achievedQuarterFaces;
  final int absenceDays;
  final bool? goalCompleted;
  final String? note;
  final int displayOrder;
}

final class ApprovedMonthlySupportReportDaySnapshot {
  ApprovedMonthlySupportReportDaySnapshot({
    required this.snapshotRowId,
    required this.sourceWeeklyReportId,
    required this.localDate,
    required this.dayKind,
    required Iterable<ApprovedMonthlySupportReportDayEntrySnapshot> entries,
  }) : entries =
           List<ApprovedMonthlySupportReportDayEntrySnapshot>.unmodifiable(
             entries,
           );

  final int snapshotRowId;
  final int sourceWeeklyReportId;
  final DateTime localDate;
  final SupportReportDayKind dayKind;
  final List<ApprovedMonthlySupportReportDayEntrySnapshot> entries;
}

final class ApprovedMonthlySupportReportDayEntrySnapshot {
  const ApprovedMonthlySupportReportDayEntrySnapshot({
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

abstract interface class MonthlySupportReportSnapshotRepository {
  Future<ApprovedMonthlySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  });

  Future<void> replaceApproved({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  });
}

abstract interface class MonthlySupportReportAtomicApprovalRepository
    implements MonthlySupportReportSnapshotRepository {
  Future<void> replaceApprovedWithPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
    required SupportReportExportArtifactMetadata primaryArtifact,
  });
}
