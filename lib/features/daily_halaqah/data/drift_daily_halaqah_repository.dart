import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah_repository.dart';

final class DriftDailyHalaqahRepository implements DailyHalaqahRepository {
  DriftDailyHalaqahRepository(this._database);

  final AppDatabase _database;

  @override
  Future<HalaqahDayRecord> ensureDay({
    required int halaqahId,
    required String dayDate,
  }) {
    return _database.transaction(() async {
      final existing =
          await (_database.select(_database.halaqahDays)..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.dayDate.equals(dayDate),
              ))
              .getSingleOrNull();

      if (existing != null) {
        return _mapDay(existing);
      }

      final id = await _database
          .into(_database.halaqahDays)
          .insert(
            HalaqahDaysCompanion.insert(
              halaqahId: halaqahId,
              dayDate: dayDate,
              status: 'open',
            ),
          );

      final created = await (_database.select(
        _database.halaqahDays,
      )..where((table) => table.id.equals(id))).getSingle();

      return _mapDay(created);
    });
  }

  @override
  Future<HalaqahDayRecord?> findDayById(int dayId) async {
    final row = await (_database.select(
      _database.halaqahDays,
    )..where((table) => table.id.equals(dayId))).getSingleOrNull();

    return row == null ? null : _mapDay(row);
  }

  @override
  Future<HalaqahDayRecord?> findDay({
    required int halaqahId,
    required String dayDate,
  }) async {
    final row =
        await (_database.select(_database.halaqahDays)..where(
              (table) =>
                  table.halaqahId.equals(halaqahId) &
                  table.dayDate.equals(dayDate),
            ))
            .getSingleOrNull();

    return row == null ? null : _mapDay(row);
  }

  @override
  Future<List<DailyHalaqahStudentRecord>> historicallyActiveStudents({
    required int halaqahId,
    required String dayDate,
  }) async {
    final rows = await _database
        .customSelect(
          '''
SELECT
  s.id AS student_id,
  s.student_name AS student_name,
  s.display_order AS display_order
FROM students AS s
WHERE s.halaqah_id = ?
  AND EXISTS (
    SELECT 1
    FROM student_activity_periods AS p
    WHERE p.student_id = s.id
      AND p.active_from_date <= ?
      AND (
        p.active_to_date IS NULL
        OR p.active_to_date >= ?
      )
  )
ORDER BY s.display_order ASC, s.id ASC;
''',
          variables: <Variable<Object>>[
            Variable<int>(halaqahId),
            Variable<String>(dayDate),
            Variable<String>(dayDate),
          ],
          readsFrom: <ResultSetImplementation>{
            _database.students,
            _database.studentActivityPeriods,
          },
        )
        .get();

    return rows
        .map(
          (row) => DailyHalaqahStudentRecord(
            id: row.read<int>('student_id'),
            studentName: row.read<String>('student_name'),
            displayOrder: row.read<int>('display_order'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<StudentAttendanceRecord> setAttendance({
    required int dayId,
    required int studentId,
    required AttendanceStatus status,
  }) {
    return _database.transaction(() async {
      final existing =
          await (_database.select(_database.attendanceRecords)..where(
                (table) =>
                    table.dayId.equals(dayId) &
                    table.studentId.equals(studentId),
              ))
              .getSingleOrNull();

      if (existing == null) {
        await _database
            .into(_database.attendanceRecords)
            .insert(
              AttendanceRecordsCompanion.insert(
                dayId: dayId,
                studentId: studentId,
                status: status.storageValue,
              ),
            );
      } else {
        final affected =
            await (_database.update(
              _database.attendanceRecords,
            )..where((table) => table.id.equals(existing.id))).write(
              AttendanceRecordsCompanion(
                status: Value<String>(status.storageValue),
              ),
            );

        if (affected != 1) {
          throw StateError(
            'Attendance for student $studentId on day $dayId '
            'could not be updated.',
          );
        }
      }

      final saved =
          await (_database.select(_database.attendanceRecords)..where(
                (table) =>
                    table.dayId.equals(dayId) &
                    table.studentId.equals(studentId),
              ))
              .getSingle();

      return _mapAttendance(saved);
    });
  }

  @override
  Future<List<StudentAttendanceRecord>> attendanceForDay(int dayId) async {
    final rows =
        await (_database.select(_database.attendanceRecords)
              ..where((table) => table.dayId.equals(dayId))
              ..orderBy([(table) => OrderingTerm.asc(table.id)]))
            .get();

    return rows.map(_mapAttendance).toList(growable: false);
  }

  @override
  Future<int> markUnspecifiedPresent({
    required int dayId,
    required List<int> studentIds,
  }) {
    return _database.transaction(() async {
      if (studentIds.isEmpty) {
        return 0;
      }

      final eligibleIds = studentIds.toSet();

      final existing = await (_database.select(
        _database.attendanceRecords,
      )..where((table) => table.dayId.equals(dayId))).get();

      final alreadySpecified = existing.map((row) => row.studentId).toSet();

      final missingIds = eligibleIds
          .where((studentId) => !alreadySpecified.contains(studentId))
          .toList(growable: false);

      for (final studentId in missingIds) {
        await _database
            .into(_database.attendanceRecords)
            .insert(
              AttendanceRecordsCompanion.insert(
                dayId: dayId,
                studentId: studentId,
                status: AttendanceStatus.present.storageValue,
              ),
            );
      }

      return missingIds.length;
    });
  }

  @override
  Future<List<HalaqahDayHistoryItem>> dayHistory({
    required int halaqahId,
  }) async {
    final rows = await _database
        .customSelect(
          '''
SELECT
  d.id AS day_id,
  d.halaqah_id AS halaqah_id,
  d.day_date AS day_date,
  d.status AS day_status,
  COUNT(a.id) AS total_count,
  COALESCE(
    SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END),
    0
  ) AS present_count,
  COALESCE(
    SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END),
    0
  ) AS absent_count,
  COALESCE(
    SUM(CASE WHEN a.status = 'excused_absent' THEN 1 ELSE 0 END),
    0
  ) AS excused_absent_count
FROM halaqah_days AS d
LEFT JOIN attendance_records AS a
  ON a.day_id = d.id
WHERE d.halaqah_id = ?
  AND d.status IN ('closed', 'holiday')
GROUP BY
  d.id,
  d.halaqah_id,
  d.day_date,
  d.status
ORDER BY d.day_date DESC, d.id DESC;
''',
          variables: <Variable<Object>>[Variable<int>(halaqahId)],
          readsFrom: <ResultSetImplementation>{
            _database.halaqahDays,
            _database.attendanceRecords,
          },
        )
        .get();

    return rows
        .map(
          (row) => HalaqahDayHistoryItem(
            day: HalaqahDayRecord(
              id: row.read<int>('day_id'),
              halaqahId: row.read<int>('halaqah_id'),
              dayDate: row.read<String>('day_date'),
              status: row.read<String>('day_status'),
            ),
            attendance: AttendanceSummaryCounts(
              totalStudents: row.read<int>('total_count'),
              presentCount: row.read<int>('present_count'),
              absentCount: row.read<int>('absent_count'),
              excusedAbsentCount: row.read<int>('excused_absent_count'),
              unsetCount: 0,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<HalaqahDayRecord>> markHolidayRange({
    required int halaqahId,
    required List<String> dayDates,
  }) {
    return _database.transaction(() async {
      if (dayDates.isEmpty) {
        return const <HalaqahDayRecord>[];
      }

      final normalizedDates = dayDates.toSet().toList(growable: false)..sort();

      final existingRows =
          await (_database.select(_database.halaqahDays)..where(
                (table) =>
                    table.halaqahId.equals(halaqahId) &
                    table.dayDate.isIn(normalizedDates),
              ))
              .get();

      final existingByDate = <String, HalaqahDay>{
        for (final row in existingRows) row.dayDate: row,
      };

      final conflictingDates = <String>[];

      for (final dayDate in normalizedDates) {
        final existing = existingByDate[dayDate];

        if (existing == null || existing.status == 'holiday') {
          continue;
        }

        if (existing.status == 'closed') {
          conflictingDates.add(dayDate);
          continue;
        }

        final attendanceRows = await (_database.select(
          _database.attendanceRecords,
        )..where((table) => table.dayId.equals(existing.id))).get();

        if (attendanceRows.isNotEmpty) {
          conflictingDates.add(dayDate);
        }
      }

      if (conflictingDates.isNotEmpty) {
        throw HolidayConflictException(conflictingDates);
      }

      for (final dayDate in normalizedDates) {
        final existing = existingByDate[dayDate];

        if (existing == null) {
          await _database
              .into(_database.halaqahDays)
              .insert(
                HalaqahDaysCompanion.insert(
                  halaqahId: halaqahId,
                  dayDate: dayDate,
                  status: 'holiday',
                ),
              );

          continue;
        }

        if (existing.status == 'holiday') {
          continue;
        }

        final affected =
            await (_database.update(_database.halaqahDays)..where(
                  (table) =>
                      table.id.equals(existing.id) &
                      table.status.equals('open'),
                ))
                .write(
                  HalaqahDaysCompanion(status: const Value<String>('holiday')),
                );

        if (affected != 1) {
          throw StateError(
            'Halaqah day ${existing.id} could not be marked as holiday.',
          );
        }
      }

      final holidayRows =
          await (_database.select(_database.halaqahDays)
                ..where(
                  (table) =>
                      table.halaqahId.equals(halaqahId) &
                      table.dayDate.isIn(normalizedDates),
                )
                ..orderBy([(table) => OrderingTerm.asc(table.dayDate)]))
              .get();

      return holidayRows.map(_mapDay).toList(growable: false);
    });
  }

  @override
  Future<HalaqahDayRecord> closeDay(int dayId) {
    return _database.transaction(() async {
      final current = await (_database.select(
        _database.halaqahDays,
      )..where((table) => table.id.equals(dayId))).getSingleOrNull();

      if (current == null) {
        throw StateError('Halaqah day $dayId was not found.');
      }

      if (current.status == 'closed') {
        return _mapDay(current);
      }

      if (current.status != 'open') {
        throw StateError('Only an open halaqah day can be closed.');
      }

      final affected =
          await (_database.update(_database.halaqahDays)..where(
                (table) => table.id.equals(dayId) & table.status.equals('open'),
              ))
              .write(
                HalaqahDaysCompanion(status: const Value<String>('closed')),
              );

      if (affected != 1) {
        throw StateError('Halaqah day $dayId could not be closed.');
      }

      final closed = await (_database.select(
        _database.halaqahDays,
      )..where((table) => table.id.equals(dayId))).getSingle();

      return _mapDay(closed);
    });
  }

  HalaqahDayRecord _mapDay(HalaqahDay row) {
    return HalaqahDayRecord(
      id: row.id,
      halaqahId: row.halaqahId,
      dayDate: row.dayDate,
      status: row.status,
    );
  }

  StudentAttendanceRecord _mapAttendance(AttendanceRecord row) {
    return StudentAttendanceRecord(
      id: row.id,
      dayId: row.dayId,
      studentId: row.studentId,
      status: AttendanceStatus.fromStorage(row.status),
    );
  }
}
