import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

final class ApprovedMonthlySupportReportSnapshot {
  ApprovedMonthlySupportReportSnapshot({
    required this.reportId,
    required this.halaqahId,
    required this.period,
    required this.header,
    required this.sourceFingerprint,
    required this.approvedAtUtc,
    required Iterable<ApprovedMonthlySupportReportStudentSnapshot> students,
  }) : students =
           List<ApprovedMonthlySupportReportStudentSnapshot>.unmodifiable(
             students,
           );

  final int reportId;
  final int halaqahId;
  final MonthlySupportReportPeriod period;
  final SupportReportHeaderSnapshot header;
  final String sourceFingerprint;
  final DateTime approvedAtUtc;
  final List<ApprovedMonthlySupportReportStudentSnapshot> students;
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
  final int monthlyGoalQuarterFaces;
  final int achievedQuarterFaces;
  final int absenceDays;
  final bool goalCompleted;
  final String? note;
  final int displayOrder;
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
