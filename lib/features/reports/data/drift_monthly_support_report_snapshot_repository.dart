import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

final class DriftMonthlySupportReportSnapshotRepository
    implements MonthlySupportReportSnapshotRepository {
  const DriftMonthlySupportReportSnapshotRepository(this._database);

  final AppDatabase _database;

  @override
  Future<ApprovedMonthlySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    final report =
        await (_database.select(_database.supportMonthlyReports)..where(
              (table) =>
                  table.halaqahId.equals(halaqahId) &
                  table.monthStartDate.equals(_dateText(period.monthStart)) &
                  table.status.equals('approved'),
            ))
            .getSingleOrNull();

    if (report == null) {
      return null;
    }

    final sourceFingerprint = report.sourceFingerprint;
    final approvedAtUtc = report.approvedAtUtc;

    if (sourceFingerprint == null || approvedAtUtc == null) {
      throw StateError('Approved monthly report is missing approval metadata.');
    }

    final studentRows =
        await (_database.select(_database.supportMonthlyReportStudents)
              ..where((table) => table.reportId.equals(report.id))
              ..orderBy([
                (table) => OrderingTerm.asc(table.displayOrderSnapshot),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    final students = studentRows
        .map(
          (row) => ApprovedMonthlySupportReportStudentSnapshot(
            snapshotRowId: row.id,
            sourceStudentId: row.sourceStudentId,
            supportStudentNumber: row.supportStudentNumberSnapshot,
            studentName: row.studentNameSnapshot,
            currentJuz: row.currentJuzSnapshot,
            dailyPlanText: row.dailyPlanTextSnapshot,
            monthlyGoalQuarterFaces: row.monthlyGoalQuarterFacesSnapshot,
            achievedQuarterFaces: row.achievedQuarterFaces,
            absenceDays: row.absenceDays,
            goalCompleted: row.goalCompleted,
            note: row.noteSnapshot,
            displayOrder: row.displayOrderSnapshot,
          ),
        )
        .toList(growable: false);

    return ApprovedMonthlySupportReportSnapshot(
      reportId: report.id,
      halaqahId: report.halaqahId,
      period: MonthlySupportReportPeriod.forDate(
        _parseLocalDate(report.monthStartDate),
      ),
      header: SupportReportHeaderSnapshot(
        teacherName: report.teacherNameSnapshot,
        halaqahName: report.halaqahNameSnapshot,
        organizationName: report.organizationNameSnapshot,
        policyVersion: report.policyVersion,
        templateVersion: report.templateVersion,
      ),
      sourceFingerprint: sourceFingerprint,
      approvedAtUtc: approvedAtUtc,
      students: students,
    );
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  }) async {
    if (halaqahId <= 0) {
      throw ArgumentError.value(
        halaqahId,
        'halaqahId',
        'Halaqah id must be positive.',
      );
    }

    if (projection.halaqahId != halaqahId) {
      throw ArgumentError(
        'Monthly projection halaqah does not match approval halaqah.',
      );
    }

    final normalizedFingerprint = sourceFingerprint.trim();

    if (normalizedFingerprint.isEmpty) {
      throw ArgumentError.value(
        sourceFingerprint,
        'sourceFingerprint',
        'Source fingerprint must not be empty.',
      );
    }

    for (final student in projection.students) {
      if (student.monthlyGoalQuarterFaces !=
          SupportReportPolicy.monthlyGoalQuarterFaces) {
        throw StateError(
          'Monthly snapshot student uses an unsupported monthly goal.',
        );
      }

      final expectedCompleted = SupportReportPolicy.hasCompletedMonthlyGoal(
        student.achievedQuarterFaces,
      );

      if (student.goalCompleted != expectedCompleted) {
        throw StateError(
          'Monthly snapshot completion state does not match achievement.',
        );
      }

      if (student.achievedQuarterFaces < 0 || student.absenceDays < 0) {
        throw StateError(
          'Monthly snapshot aggregate values must not be negative.',
        );
      }
    }

    await _database.transaction(() async {
      final monthStartText = _dateText(projection.period.monthStart);

      final existing =
          await (_database.select(_database.supportMonthlyReports)..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.monthStartDate.equals(monthStartText),
              ))
              .getSingleOrNull();

      if (existing != null) {
        await (_database.delete(
          _database.supportMonthlyReports,
        )..where((table) => table.id.equals(existing.id))).go();
      }

      final reportId = await _database
          .into(_database.supportMonthlyReports)
          .insert(
            SupportMonthlyReportsCompanion.insert(
              halaqahId: halaqahId,
              monthStartDate: monthStartText,
              monthEndDate: _dateText(projection.period.monthEnd),
              status: 'approved',
              teacherNameSnapshot: projection.header.teacherName,
              halaqahNameSnapshot: projection.header.halaqahName,
              organizationNameSnapshot: projection.header.organizationName,
              policyVersion: projection.header.policyVersion,
              templateVersion: projection.header.templateVersion,
              sourceFingerprint: Value(normalizedFingerprint),
              approvedAtUtc: Value(approvedAtUtc.toUtc()),
            ),
          );

      for (final student in projection.students) {
        await _database
            .into(_database.supportMonthlyReportStudents)
            .insert(
              SupportMonthlyReportStudentsCompanion.insert(
                reportId: reportId,
                sourceStudentId: student.sourceStudentId,
                supportStudentNumberSnapshot: Value(
                  student.supportStudentNumber,
                ),
                studentNameSnapshot: student.studentName,
                currentJuzSnapshot: Value(student.currentJuz),
                dailyPlanTextSnapshot: Value(student.dailyPlanText),
                monthlyGoalQuarterFacesSnapshot:
                    student.monthlyGoalQuarterFaces,
                achievedQuarterFaces: student.achievedQuarterFaces,
                absenceDays: student.absenceDays,
                goalCompleted: student.goalCompleted,
                noteSnapshot: Value(student.note),
                displayOrderSnapshot: student.displayOrder,
              ),
            );
      }
    });
  }
}

String _dateText(DateTime value) {
  final normalized = SupportReportPolicy.dateOnly(value);

  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

DateTime _parseLocalDate(String value) {
  final parts = value.split('-');

  if (parts.length != 3) {
    throw StateError('Invalid local monthly report date: $value');
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);

  if (year == null || month == null || day == null) {
    throw StateError('Invalid local monthly report date: $value');
  }

  return DateTime(year, month, day);
}
