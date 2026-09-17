import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

final class DriftSupportReportSourceRepository
    implements SupportReportSourceRepository {
  DriftSupportReportSourceRepository(this._database);

  final AppDatabase _database;

  @override
  Future<WeeklySupportReportSource> readWeeklySource({
    required int halaqahId,
    required WeeklySupportReportPeriod period,
  }) async {
    final halaqahRow = await (_database.select(
      _database.halaqahs,
    )..where((table) => table.id.equals(halaqahId))).getSingleOrNull();

    if (halaqahRow == null) {
      throw StateError(
        'Cannot read support report source for missing halaqah '
        '$halaqahId.',
      );
    }

    final supportPeriodRows =
        await (_database.select(_database.supportProgramPeriods)
              ..where((table) => table.halaqahId.equals(halaqahId))
              ..orderBy([
                (table) => OrderingTerm.asc(table.startedAtUtc),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    final allStudentRows =
        await (_database.select(_database.students)
              ..where((table) => table.halaqahId.equals(halaqahId))
              ..orderBy([
                (table) => OrderingTerm.asc(table.displayOrder),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    final halaqahStudentIds = allStudentRows.map((row) => row.id).toSet();

    final weekStartText = _localDateText(period.weekStart);
    final weekEndText = _localDateText(period.weekEnd);

    final allActivityRows = await _database
        .select(_database.studentActivityPeriods)
        .get();

    final overlappingActivityRows =
        allActivityRows
            .where(
              (row) =>
                  halaqahStudentIds.contains(row.studentId) &&
                  _overlaps(
                    activeFromDate: row.activeFromDate,
                    activeToDate: row.activeToDate,
                    weekStartDate: weekStartText,
                    weekEndDate: weekEndText,
                  ),
            )
            .toList(growable: false)
          ..sort((left, right) {
            final studentCompare = left.studentId.compareTo(right.studentId);

            if (studentCompare != 0) {
              return studentCompare;
            }

            final dateCompare = left.activeFromDate.compareTo(
              right.activeFromDate,
            );

            if (dateCompare != 0) {
              return dateCompare;
            }

            return left.id.compareTo(right.id);
          });

    final historicallyRelevantStudentIds = overlappingActivityRows
        .map((row) => row.studentId)
        .toSet();

    final allPlanRows = await _database
        .select(_database.studentProgressPlans)
        .get();

    final plansByStudentId = {
      for (final row in allPlanRows)
        if (historicallyRelevantStudentIds.contains(row.studentId))
          row.studentId: row,
    };

    final activityByStudentId =
        <int, List<SupportReportStudentActivityPeriodSource>>{};

    for (final row in overlappingActivityRows) {
      activityByStudentId
          .putIfAbsent(
            row.studentId,
            () => <SupportReportStudentActivityPeriodSource>[],
          )
          .add(
            SupportReportStudentActivityPeriodSource(
              id: row.id,
              activeFromDate: row.activeFromDate,
              activeToDate: row.activeToDate,
            ),
          );
    }

    final studentSources = allStudentRows
        .where((row) => historicallyRelevantStudentIds.contains(row.id))
        .map((row) {
          final plan = plansByStudentId[row.id];

          return SupportReportStudentSource(
            id: row.id,
            studentName: row.studentName,
            supportStudentNumber: row.supportStudentNumber,
            note: row.note,
            displayOrder: row.displayOrder,
            currentJuz: plan?.currentJuz,
            dailyPlanText: plan?.dailyPlanText,
            activityPeriods:
                activityByStudentId[row.id] ??
                const <SupportReportStudentActivityPeriodSource>[],
          );
        })
        .toList(growable: false);

    final officialDayDates = period.officialDates.map(_localDateText).toSet();

    final allHalaqahDayRows =
        await (_database.select(_database.halaqahDays)
              ..where((table) => table.halaqahId.equals(halaqahId))
              ..orderBy([
                (table) => OrderingTerm.asc(table.dayDate),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    final reportDayRows = allHalaqahDayRows
        .where((row) => officialDayDates.contains(row.dayDate))
        .toList(growable: false);

    final reportDayIds = reportDayRows.map((row) => row.id).toSet();

    final allAttendanceRows = await _database
        .select(_database.attendanceRecords)
        .get();

    final reportAttendanceRows =
        allAttendanceRows
            .where((row) => reportDayIds.contains(row.dayId))
            .toList(growable: false)
          ..sort((left, right) {
            final dayCompare = left.dayId.compareTo(right.dayId);

            if (dayCompare != 0) {
              return dayCompare;
            }

            final studentCompare = left.studentId.compareTo(right.studentId);

            if (studentCompare != 0) {
              return studentCompare;
            }

            return left.id.compareTo(right.id);
          });

    final allRecitationRows = await _database
        .select(_database.recitations)
        .get();

    final reportNewMemorizationRows =
        allRecitationRows
            .where(
              (row) =>
                  reportDayIds.contains(row.dayId) &&
                  row.type == 'new_memorization',
            )
            .toList(growable: false)
          ..sort((left, right) {
            final dayCompare = left.dayId.compareTo(right.dayId);

            if (dayCompare != 0) {
              return dayCompare;
            }

            final studentCompare = left.studentId.compareTo(right.studentId);

            if (studentCompare != 0) {
              return studentCompare;
            }

            return left.id.compareTo(right.id);
          });

    return WeeklySupportReportSource(
      period: period,
      halaqah: SupportReportHalaqahSource(
        id: halaqahRow.id,
        teacherName: halaqahRow.teacherName,
        halaqahName: halaqahRow.halaqahName,
        centerName: halaqahRow.centerName,
      ),
      supportPeriods: supportPeriodRows.map(
        (row) => SupportReportSupportPeriodSource(
          id: row.id,
          organizationName: row.organizationName,
          startedAtUtc: row.startedAtUtc,
          endedAtUtc: row.endedAtUtc,
        ),
      ),
      students: studentSources,
      days: reportDayRows.map(
        (row) => SupportReportDaySource(
          id: row.id,
          dayDate: row.dayDate,
          status: row.status,
        ),
      ),
      attendance: reportAttendanceRows.map(
        (row) => SupportReportAttendanceSource(
          id: row.id,
          dayId: row.dayId,
          studentId: row.studentId,
          status: row.status,
        ),
      ),
      newMemorization: reportNewMemorizationRows.map(
        (row) => SupportReportNewMemorizationSource(
          id: row.id,
          dayId: row.dayId,
          studentId: row.studentId,
          startSurah: row.startSurah,
          startAyah: row.startAyah,
          endSurah: row.endSurah,
          endAyah: row.endAyah,
          facesQuarterAchieved: row.facesQuarterAchieved,
          note: row.note,
        ),
      ),
    );
  }
}

bool _overlaps({
  required String activeFromDate,
  required String? activeToDate,
  required String weekStartDate,
  required String weekEndDate,
}) {
  return activeFromDate.compareTo(weekEndDate) <= 0 &&
      (activeToDate == null || activeToDate.compareTo(weekStartDate) >= 0);
}

String _localDateText(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
