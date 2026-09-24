import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class DriftMonthlySupportReportSnapshotRepository
    implements MonthlySupportReportAtomicApprovalRepository {
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

    final sourceStudentIdBySnapshotRowId = <int, int>{
      for (final row in studentRows) row.id: row.sourceStudentId,
    };

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

    final dayRows =
        await (_database.select(_database.supportMonthlyReportDays)
              ..where((table) => table.reportId.equals(report.id))
              ..orderBy([
                (table) => OrderingTerm.asc(table.dayDate),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    final days = <ApprovedMonthlySupportReportDaySnapshot>[];

    for (final dayRow in dayRows) {
      final entryRows =
          await (_database.select(_database.supportMonthlyReportDayEntries)
                ..where((table) => table.reportDayId.equals(dayRow.id))
                ..orderBy([
                  (table) => OrderingTerm.asc(table.reportStudentId),
                  (table) => OrderingTerm.asc(table.entryOrder),
                  (table) => OrderingTerm.asc(table.id),
                ]))
              .get();

      final entries = <ApprovedMonthlySupportReportDayEntrySnapshot>[];

      for (final entryRow in entryRows) {
        final sourceStudentId =
            sourceStudentIdBySnapshotRowId[entryRow.reportStudentId];

        if (sourceStudentId == null) {
          throw StateError('Monthly snapshot entry crosses report boundaries.');
        }

        final startSurah = entryRow.startSurahSnapshot;

        final range = startSurah == null
            ? null
            : SupportReportQuranRange(
                startSurah: startSurah,
                startAyah: entryRow.startAyahSnapshot!,
                endSurah: entryRow.endSurahSnapshot!,
                endAyah: entryRow.endAyahSnapshot!,
              );

        final attendanceValue = entryRow.attendanceStatusSnapshot;

        entries.add(
          ApprovedMonthlySupportReportDayEntrySnapshot(
            snapshotRowId: entryRow.id,
            sourceStudentId: sourceStudentId,
            attendanceStatus: attendanceValue == null
                ? null
                : SupportReportAttendanceStatus.fromStorage(attendanceValue),
            achievedQuarterFaces: entryRow.achievedQuarterFaces,
            range: range,
            note: entryRow.noteSnapshot,
            entryOrder: entryRow.entryOrder,
          ),
        );
      }

      days.add(
        ApprovedMonthlySupportReportDaySnapshot(
          snapshotRowId: dayRow.id,
          sourceWeeklyReportId: dayRow.sourceWeeklyReportIdSnapshot,
          localDate: _parseLocalDate(dayRow.dayDate),
          dayKind: SupportReportDayKind.fromStorage(dayRow.dayKind),
          entries: entries,
        ),
      );
    }

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
        reportContext: SupportReportContext.fromStorage(
          report.reportContextSnapshot,
        ),
        policyVersion: report.policyVersion,
        templateVersion: report.templateVersion,
      ),
      sourceFingerprint: sourceFingerprint,
      approvedAtUtc: approvedAtUtc,
      students: students,
      days: days,
    );
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
  }) {
    return _replaceApproved(
      halaqahId: halaqahId,
      projection: projection,
      sourceFingerprint: sourceFingerprint,
      approvedAtUtc: approvedAtUtc,
      primaryArtifact: null,
    );
  }

  @override
  Future<void> replaceApprovedWithPrimaryArtifact({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
    required SupportReportExportArtifactMetadata primaryArtifact,
  }) {
    if (primaryArtifact.format != SupportReportExportFormat.excel) {
      throw ArgumentError.value(
        primaryArtifact.format,
        'primaryArtifact',
        'Primary approval artifact must be Excel.',
      );
    }

    if (primaryArtifact.templateVersion != projection.header.templateVersion) {
      throw StateError(
        'Primary artifact template version does not match monthly projection.',
      );
    }

    return _replaceApproved(
      halaqahId: halaqahId,
      projection: projection,
      sourceFingerprint: sourceFingerprint,
      approvedAtUtc: approvedAtUtc,
      primaryArtifact: primaryArtifact,
    );
  }

  Future<void> _replaceApproved({
    required int halaqahId,
    required MonthlySupportReportProjection projection,
    required String sourceFingerprint,
    required DateTime approvedAtUtc,
    required SupportReportExportArtifactMetadata? primaryArtifact,
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

    final hasSupportContext =
        projection.header.reportContext == SupportReportContext.support;

    for (final student in projection.students) {
      if (hasSupportContext) {
        if (student.monthlyGoalQuarterFaces !=
            SupportReportPolicy.monthlyGoalQuarterFaces) {
          throw StateError(
            'Support monthly snapshot student uses an unsupported monthly goal.',
          );
        }

        final expectedCompleted = SupportReportPolicy.hasCompletedMonthlyGoal(
          student.achievedQuarterFaces,
        );

        if (student.goalCompleted != expectedCompleted) {
          throw StateError(
            'Support monthly snapshot completion state does not match '
            'achievement.',
          );
        }
      } else {
        if (student.monthlyGoalQuarterFaces != null ||
            student.goalCompleted != null ||
            student.supportStudentNumber != null) {
          throw StateError(
            'General monthly snapshot must not persist support-only '
            'student policy fields.',
          );
        }
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
              reportContextSnapshot: Value(
                projection.header.reportContext.storageValue,
              ),
              policyVersion: projection.header.policyVersion,
              templateVersion: projection.header.templateVersion,
              sourceFingerprint: Value(normalizedFingerprint),
              approvedAtUtc: Value(approvedAtUtc.toUtc()),
            ),
          );

      final reportStudentIdBySourceStudentId = <int, int>{};

      for (final student in projection.students) {
        final reportStudentId = await _database
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
                monthlyGoalQuarterFacesSnapshot: Value(
                  student.monthlyGoalQuarterFaces,
                ),
                achievedQuarterFaces: student.achievedQuarterFaces,
                absenceDays: student.absenceDays,
                goalCompleted: Value(student.goalCompleted),
                noteSnapshot: Value(student.note),
                displayOrderSnapshot: student.displayOrder,
              ),
            );

        reportStudentIdBySourceStudentId[student.sourceStudentId] =
            reportStudentId;
      }

      for (final day in projection.days) {
        final reportDayId = await _database
            .into(_database.supportMonthlyReportDays)
            .insert(
              SupportMonthlyReportDaysCompanion.insert(
                reportId: reportId,
                sourceWeeklyReportIdSnapshot: day.sourceWeeklyReportId,
                dayDate: _dateText(day.localDate),
                dayKind: day.dayKind.storageValue,
              ),
            );

        for (final entry in day.entries) {
          final reportStudentId =
              reportStudentIdBySourceStudentId[entry.sourceStudentId];

          if (reportStudentId == null) {
            throw StateError(
              'Monthly snapshot entry references an unknown report student.',
            );
          }

          final range = entry.range;

          await _database
              .into(_database.supportMonthlyReportDayEntries)
              .insert(
                SupportMonthlyReportDayEntriesCompanion.insert(
                  reportDayId: reportDayId,
                  reportStudentId: reportStudentId,
                  attendanceStatusSnapshot: Value(
                    entry.attendanceStatus?.storageValue,
                  ),
                  achievedQuarterFaces: Value(entry.achievedQuarterFaces),
                  startSurahSnapshot: Value(range?.startSurah),
                  startAyahSnapshot: Value(range?.startAyah),
                  endSurahSnapshot: Value(range?.endSurah),
                  endAyahSnapshot: Value(range?.endAyah),
                  noteSnapshot: Value(entry.note),
                  entryOrder: entry.entryOrder,
                ),
              );
        }
      }

      if (primaryArtifact != null) {
        await _database
            .into(_database.reportExportArtifacts)
            .insert(
              ReportExportArtifactsCompanion.insert(
                monthlyReportId: Value(reportId),
                format: primaryArtifact.format.storageValue,
                internalPath: primaryArtifact.internalPath,
                sha256: primaryArtifact.sha256,
                templateVersion: primaryArtifact.templateVersion,
                sizeBytes: primaryArtifact.sizeBytes,
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
