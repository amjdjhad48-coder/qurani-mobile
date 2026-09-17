import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class DriftWeeklySupportReportSnapshotRepository
    implements WeeklySupportReportSnapshotRepository {
  const DriftWeeklySupportReportSnapshotRepository(this._database);

  final AppDatabase _database;

  @override
  Future<ApprovedWeeklySupportReportSnapshot?> findApproved({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    final report =
        await (_database.select(_database.supportWeeklyReports)..where(
              (table) =>
                  table.halaqahId.equals(halaqahId) &
                  table.weekStartDate.equals(_dateText(period.weekStart)) &
                  table.status.equals('approved'),
            ))
            .getSingleOrNull();

    if (report == null) {
      return null;
    }

    final sourceFingerprint = report.sourceFingerprint;
    final approvedAtUtc = report.approvedAtUtc;

    if (sourceFingerprint == null || approvedAtUtc == null) {
      throw StateError('Approved weekly report is missing approval metadata.');
    }

    final studentRows =
        await (_database.select(_database.supportWeeklyReportStudents)
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
          (row) => ApprovedWeeklySupportReportStudentSnapshot(
            snapshotRowId: row.id,
            sourceStudentId: row.sourceStudentId,
            supportStudentNumber: row.supportStudentNumberSnapshot,
            studentName: row.studentNameSnapshot,
            currentJuz: row.currentJuzSnapshot,
            dailyPlanText: row.dailyPlanTextSnapshot,
            monthlyGoalQuarterFaces: row.monthlyGoalQuarterFacesSnapshot,
            note: row.studentNoteSnapshot,
            displayOrder: row.displayOrderSnapshot,
          ),
        )
        .toList(growable: false);

    final dayRows =
        await (_database.select(_database.supportWeeklyReportDays)
              ..where((table) => table.reportId.equals(report.id))
              ..orderBy([
                (table) => OrderingTerm.asc(table.dayDate),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    final days = <ApprovedWeeklySupportReportDaySnapshot>[];

    for (final dayRow in dayRows) {
      final entryRows =
          await (_database.select(_database.supportWeeklyReportDayEntries)
                ..where((table) => table.reportDayId.equals(dayRow.id))
                ..orderBy([
                  (table) => OrderingTerm.asc(table.reportStudentId),
                  (table) => OrderingTerm.asc(table.entryOrder),
                  (table) => OrderingTerm.asc(table.id),
                ]))
              .get();

      final entries = <ApprovedWeeklySupportReportDayEntrySnapshot>[];

      for (final entryRow in entryRows) {
        final sourceStudentId =
            sourceStudentIdBySnapshotRowId[entryRow.reportStudentId];

        if (sourceStudentId == null) {
          throw StateError('Weekly snapshot entry crosses report boundaries.');
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
          ApprovedWeeklySupportReportDayEntrySnapshot(
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
        ApprovedWeeklySupportReportDaySnapshot(
          snapshotRowId: dayRow.id,
          localDate: _parseLocalDate(dayRow.dayDate),
          dayKind: SupportReportDayKind.fromStorage(dayRow.dayKind),
          entries: entries,
        ),
      );
    }

    return ApprovedWeeklySupportReportSnapshot(
      reportId: report.id,
      halaqahId: report.halaqahId,
      period: WeeklySupportReportPeriod.forDate(
        _parseLocalDate(report.weekStartDate),
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
      days: days,
    );
  }

  @override
  Future<void> replaceApproved({
    required int halaqahId,
    required WeeklySupportReportProjection projection,
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

    final normalizedFingerprint = sourceFingerprint.trim();

    if (normalizedFingerprint.isEmpty) {
      throw ArgumentError.value(
        sourceFingerprint,
        'sourceFingerprint',
        'Source fingerprint must not be empty.',
      );
    }

    await _database.transaction(() async {
      final weekStartText = _dateText(projection.period.weekStart);

      final existing =
          await (_database.select(_database.supportWeeklyReports)..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.weekStartDate.equals(weekStartText),
              ))
              .getSingleOrNull();

      if (existing != null) {
        await (_database.delete(
          _database.supportWeeklyReports,
        )..where((table) => table.id.equals(existing.id))).go();
      }

      final reportId = await _database
          .into(_database.supportWeeklyReports)
          .insert(
            SupportWeeklyReportsCompanion.insert(
              halaqahId: halaqahId,
              weekStartDate: weekStartText,
              weekEndDate: _dateText(projection.period.weekEnd),
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

      final reportStudentIdBySourceStudentId = <int, int>{};

      for (final student in projection.students) {
        final reportStudentId = await _database
            .into(_database.supportWeeklyReportStudents)
            .insert(
              SupportWeeklyReportStudentsCompanion.insert(
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
                studentNoteSnapshot: Value(student.note),
                displayOrderSnapshot: student.displayOrder,
              ),
            );

        reportStudentIdBySourceStudentId[student.sourceStudentId] =
            reportStudentId;
      }

      for (final day in projection.days) {
        final reportDayId = await _database
            .into(_database.supportWeeklyReportDays)
            .insert(
              SupportWeeklyReportDaysCompanion.insert(
                reportId: reportId,
                dayDate: _dateText(day.localDate),
                dayKind: day.dayKind.storageValue,
              ),
            );

        for (final entry in day.entries) {
          final reportStudentId =
              reportStudentIdBySourceStudentId[entry.sourceStudentId];

          if (reportStudentId == null) {
            throw StateError(
              'Weekly snapshot entry references an unknown report student.',
            );
          }

          final recitations = entry.newMemorizationEntries;

          if (recitations.isEmpty) {
            await _database
                .into(_database.supportWeeklyReportDayEntries)
                .insert(
                  SupportWeeklyReportDayEntriesCompanion.insert(
                    reportDayId: reportDayId,
                    reportStudentId: reportStudentId,
                    attendanceStatusSnapshot: Value(
                      entry.attendanceStatus?.storageValue,
                    ),
                    achievedQuarterFaces: const Value(0),
                    entryOrder: 1,
                  ),
                );

            continue;
          }

          for (var index = 0; index < recitations.length; index++) {
            final recitation = recitations[index];
            final range = recitation.range;

            await _database
                .into(_database.supportWeeklyReportDayEntries)
                .insert(
                  SupportWeeklyReportDayEntriesCompanion.insert(
                    reportDayId: reportDayId,
                    reportStudentId: reportStudentId,
                    attendanceStatusSnapshot: Value(
                      index == 0 ? entry.attendanceStatus?.storageValue : null,
                    ),
                    achievedQuarterFaces: Value(
                      recitation.achievedQuarterFaces,
                    ),
                    startSurahSnapshot: Value(range.startSurah),
                    startAyahSnapshot: Value(range.startAyah),
                    endSurahSnapshot: Value(range.endSurah),
                    endAyahSnapshot: Value(range.endAyah),
                    noteSnapshot: Value(recitation.note),
                    entryOrder: index + 1,
                  ),
                );
          }
        }
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
    throw StateError('Invalid local report date: $value');
  }

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);

  if (year == null || month == null || day == null) {
    throw StateError('Invalid local report date: $value');
  }

  return DateTime(year, month, day);
}
