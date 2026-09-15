import 'package:drift/drift.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_repository.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

final class DriftParentFollowUpRepository implements ParentFollowUpRepository {
  DriftParentFollowUpRepository(this._database);

  final AppDatabase _database;

  @override
  Future<EndDayAndPrepareParentFollowUpsResult> endDayAndPrepareDailyFollowUps({
    required int halaqahId,
    required int dayId,
  }) {
    return _database.transaction(() async {
      final currentDay = await (_database.select(
        _database.halaqahDays,
      )..where((table) => table.id.equals(dayId))).getSingleOrNull();

      if (currentDay == null) {
        throw StateError('Halaqah day $dayId was not found.');
      }

      if (currentDay.halaqahId != halaqahId) {
        throw StateError(
          'Halaqah day $dayId does not belong to halaqah $halaqahId.',
        );
      }

      if (currentDay.status == 'holiday') {
        throw StateError('A holiday cannot create daily parent follow ups.');
      }

      if (currentDay.status != 'open' && currentDay.status != 'closed') {
        throw StateError(
          'Halaqah day $dayId has unsupported status '
          '${currentDay.status}.',
        );
      }

      final studentRows = await _database
          .customSelect(
            '''
SELECT
  s.id AS student_id
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
              Variable<String>(currentDay.dayDate),
              Variable<String>(currentDay.dayDate),
            ],
            readsFrom: {_database.students, _database.studentActivityPeriods},
          )
          .get();

      final studentIds = studentRows
          .map((row) => row.read<int>('student_id'))
          .toList(growable: false);

      final attendanceRows = await (_database.select(
        _database.attendanceRecords,
      )..where((table) => table.dayId.equals(dayId))).get();

      final specifiedStudentIds = attendanceRows
          .map((row) => row.studentId)
          .toSet();

      final missingStudentIds = studentIds
          .where((studentId) => !specifiedStudentIds.contains(studentId))
          .toList(growable: false);

      if (missingStudentIds.isNotEmpty) {
        throw ParentFollowUpIncompleteAttendanceException(missingStudentIds);
      }

      if (currentDay.status == 'open') {
        final affected =
            await (_database.update(_database.halaqahDays)..where(
                  (table) =>
                      table.id.equals(dayId) & table.status.equals('open'),
                ))
                .write(
                  HalaqahDaysCompanion(status: const Value<String>('closed')),
                );

        if (affected != 1) {
          throw StateError(
            'Halaqah day $dayId could not be closed atomically.',
          );
        }
      }

      for (final studentId in studentIds) {
        await _database.customStatement(
          'INSERT OR IGNORE INTO parent_follow_ups '
          '(day_id, student_id, type, status) '
          "VALUES (?, ?, 'daily', 'pending');",
          <Object?>[dayId, studentId],
        );
      }

      final followUpRows =
          await (_database.select(_database.parentFollowUps)
                ..where(
                  (table) =>
                      table.dayId.equals(dayId) & table.type.equals('daily'),
                )
                ..orderBy([
                  (table) => OrderingTerm.asc(table.studentId),
                  (table) => OrderingTerm.asc(table.id),
                ]))
              .get();

      final followUpStudentIds = followUpRows
          .map((row) => row.studentId)
          .toSet();

      final expectedStudentIds = studentIds.toSet();

      if (followUpRows.length != studentIds.length ||
          followUpStudentIds.length != expectedStudentIds.length ||
          !followUpStudentIds.containsAll(expectedStudentIds)) {
        throw StateError(
          'Daily parent follow ups for day $dayId are incomplete.',
        );
      }

      final closedDay = await (_database.select(
        _database.halaqahDays,
      )..where((table) => table.id.equals(dayId))).getSingle();

      if (closedDay.status != 'closed') {
        throw StateError('Halaqah day $dayId was not closed atomically.');
      }

      return EndDayAndPrepareParentFollowUpsResult(
        day: _mapDay(closedDay),
        followUps: followUpRows.map(_mapFollowUp),
      );
    });
  }

  @override
  Future<ParentFollowUpRecord?> findById(int followUpId) async {
    final row = await (_database.select(
      _database.parentFollowUps,
    )..where((table) => table.id.equals(followUpId))).getSingleOrNull();

    return row == null ? null : _mapFollowUp(row);
  }

  @override
  Future<List<ParentFollowUpRecord>> listForDay(int dayId) async {
    final rows =
        await (_database.select(_database.parentFollowUps)
              ..where((table) => table.dayId.equals(dayId))
              ..orderBy([
                (table) => OrderingTerm.asc(table.studentId),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();

    return rows.map(_mapFollowUp).toList(growable: false);
  }

  @override
  Future<ParentFollowUpDailyPreviewInput> loadLiveDailyPreview(
    int followUpId,
  ) async {
    final followUp = await (_database.select(
      _database.parentFollowUps,
    )..where((table) => table.id.equals(followUpId))).getSingleOrNull();

    if (followUp == null) {
      throw StateError('Parent follow up $followUpId was not found.');
    }

    if (followUp.type != ParentFollowUpType.daily.storageValue) {
      throw StateError(
        'Parent follow up $followUpId is not a daily follow up.',
      );
    }

    final day = await (_database.select(
      _database.halaqahDays,
    )..where((table) => table.id.equals(followUp.dayId))).getSingleOrNull();

    if (day == null) {
      throw StateError('Halaqah day ${followUp.dayId} was not found.');
    }

    if (day.status == 'holiday') {
      throw StateError('A holiday cannot have a live daily parent preview.');
    }

    final student = await (_database.select(
      _database.students,
    )..where((table) => table.id.equals(followUp.studentId))).getSingleOrNull();

    if (student == null) {
      throw StateError('Student ${followUp.studentId} was not found.');
    }

    if (student.halaqahId != day.halaqahId) {
      throw StateError(
        'Student ${student.id} and day ${day.id} '
        'belong to different halaqahs.',
      );
    }

    final halaqah = await (_database.select(
      _database.halaqahs,
    )..where((table) => table.id.equals(day.halaqahId))).getSingleOrNull();

    if (halaqah == null) {
      throw StateError('Halaqah ${day.halaqahId} was not found.');
    }

    final attendance =
        await (_database.select(_database.attendanceRecords)..where(
              (table) =>
                  table.dayId.equals(day.id) &
                  table.studentId.equals(student.id),
            ))
            .getSingleOrNull();

    if (attendance == null) {
      throw StateError(
        'Attendance for student ${student.id} '
        'on day ${day.id} was not found.',
      );
    }

    final recitationRows =
        await (_database.select(_database.recitations)
              ..where(
                (table) =>
                    table.dayId.equals(day.id) &
                    table.studentId.equals(student.id),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.id)]))
            .get();

    final recitations = recitationRows
        .map(
          (row) => ParentFollowUpRecitationPreview(
            type: RecitationType.fromStorage(row.type),
            actualRange: QuranRange(
              start: QuranPosition(
                surahNumber: row.startSurah,
                ayahNumber: row.startAyah,
              ),
              end: QuranPosition(
                surahNumber: row.endSurah,
                ayahNumber: row.endAyah,
              ),
            ),
            facesQuarterAchieved: row.facesQuarterAchieved,
            evaluation: RecitationEvaluation.fromStorage(row.evaluation),
            note: row.note,
          ),
        )
        .toList(growable: false);

    return ParentFollowUpDailyPreviewInput(
      studentName: student.studentName,
      dayDate: day.dayDate,
      attendanceStatus: ParentFollowUpAttendanceStatus.fromStorage(
        attendance.status,
      ),
      recitations: recitations,
      teacherName: halaqah.teacherName,
      halaqahName: halaqah.halaqahName,
      centerName: halaqah.centerName,
    );
  }

  @override
  Future<ParentFollowUpAttendanceCorrectionInput>
  loadLiveAttendanceCorrectionPreview(int followUpId) async {
    final correction = await (_database.select(
      _database.parentFollowUps,
    )..where((table) => table.id.equals(followUpId))).getSingleOrNull();

    if (correction == null) {
      throw StateError('Parent follow up $followUpId was not found.');
    }

    if (correction.type !=
        ParentFollowUpType.attendanceCorrection.storageValue) {
      throw StateError(
        'Parent follow up $followUpId is not '
        'an attendance correction.',
      );
    }

    if (correction.status != ParentFollowUpStatus.pending.storageValue) {
      throw StateError(
        'Only a pending attendance correction '
        'has a live correction preview.',
      );
    }

    final correctedId = correction.correctsFollowUpId;

    if (correctedId == null) {
      throw StateError(
        'Attendance correction $followUpId '
        'does not reference a handled follow up.',
      );
    }

    final corrected = await (_database.select(
      _database.parentFollowUps,
    )..where((table) => table.id.equals(correctedId))).getSingleOrNull();

    if (corrected == null ||
        corrected.status != ParentFollowUpStatus.handled.storageValue ||
        corrected.attendanceStatusSnapshot == null) {
      throw StateError(
        'Corrected follow up $correctedId is not '
        'a valid handled attendance baseline.',
      );
    }

    final day = await (_database.select(
      _database.halaqahDays,
    )..where((table) => table.id.equals(correction.dayId))).getSingleOrNull();

    if (day == null) {
      throw StateError('Halaqah day ${correction.dayId} was not found.');
    }

    final student =
        await (_database.select(_database.students)
              ..where((table) => table.id.equals(correction.studentId)))
            .getSingleOrNull();

    if (student == null) {
      throw StateError('Student ${correction.studentId} was not found.');
    }

    final halaqah = await (_database.select(
      _database.halaqahs,
    )..where((table) => table.id.equals(day.halaqahId))).getSingleOrNull();

    if (halaqah == null) {
      throw StateError('Halaqah ${day.halaqahId} was not found.');
    }

    final attendance =
        await (_database.select(_database.attendanceRecords)..where(
              (table) =>
                  table.dayId.equals(day.id) &
                  table.studentId.equals(student.id),
            ))
            .getSingleOrNull();

    if (attendance == null) {
      throw StateError(
        'Attendance for student ${student.id} '
        'on day ${day.id} was not found.',
      );
    }

    final previousStatus = ParentFollowUpAttendanceStatus.fromStorage(
      corrected.attendanceStatusSnapshot!,
    );

    final currentStatus = ParentFollowUpAttendanceStatus.fromStorage(
      attendance.status,
    );

    if (previousStatus == currentStatus) {
      throw StateError(
        'Attendance correction $followUpId no longer '
        'differs from its handled baseline.',
      );
    }

    return ParentFollowUpAttendanceCorrectionInput(
      studentName: student.studentName,
      dayDate: day.dayDate,
      previousStatus: previousStatus,
      currentStatus: currentStatus,
      teacherName: halaqah.teacherName,
      halaqahName: halaqah.halaqahName,
      centerName: halaqah.centerName,
    );
  }

  @override
  Future<AttendanceCorrectionReconciliationResult>
  setAttendanceAndReconcileCorrection({
    required int halaqahId,
    required int dayId,
    required int studentId,
    required AttendanceStatus status,
  }) {
    return _database.transaction(() async {
      final day = await (_database.select(
        _database.halaqahDays,
      )..where((table) => table.id.equals(dayId))).getSingleOrNull();

      if (day == null) {
        throw StateError('Halaqah day $dayId was not found.');
      }

      if (day.halaqahId != halaqahId) {
        throw StateError(
          'Halaqah day $dayId does not belong to halaqah $halaqahId.',
        );
      }

      if (day.status == 'holiday') {
        throw StateError('Attendance cannot be written on a holiday.');
      }

      if (day.status != 'open' && day.status != 'closed') {
        throw StateError(
          'Halaqah day $dayId has unsupported status ${day.status}.',
        );
      }

      final eligibleRows = await _database
          .customSelect(
            '''
SELECT 1 AS eligible
FROM students AS s
WHERE s.id = ?
  AND s.halaqah_id = ?
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
LIMIT 1;
''',
            variables: <Variable<Object>>[
              Variable<int>(studentId),
              Variable<int>(halaqahId),
              Variable<String>(day.dayDate),
              Variable<String>(day.dayDate),
            ],
            readsFrom: {_database.students, _database.studentActivityPeriods},
          )
          .get();

      if (eligibleRows.isEmpty) {
        throw StateError(
          'Student $studentId was not active in halaqah '
          '$halaqahId on ${day.dayDate}.',
        );
      }

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

      final pending = await _reconcilePendingCorrection(
        dayId: dayId,
        studentId: studentId,
        currentStatus: saved.status,
      );

      return AttendanceCorrectionReconciliationResult(
        attendance: _mapAttendance(saved),
        pendingCorrection: pending == null ? null : _mapFollowUp(pending),
      );
    });
  }

  @override
  Future<ParentFollowUpRecord> markHandled({
    required int followUpId,
    required ParentFollowUpHandledSnapshot snapshot,
  }) {
    return _database.transaction(() async {
      final current = await (_database.select(
        _database.parentFollowUps,
      )..where((table) => table.id.equals(followUpId))).getSingleOrNull();

      if (current == null) {
        throw StateError('Parent follow up $followUpId was not found.');
      }

      if (current.status == ParentFollowUpStatus.handled.storageValue) {
        return _mapFollowUp(current);
      }

      if (current.status != ParentFollowUpStatus.pending.storageValue) {
        throw StateError(
          'Parent follow up $followUpId has unsupported status '
          '${current.status}.',
        );
      }

      final message = snapshot.message.trim();
      final recipient = snapshot.recipient.trim();

      if (message.isEmpty) {
        throw ArgumentError.value(
          snapshot.message,
          'message',
          'Handled message snapshot must not be blank.',
        );
      }

      if (recipient.isEmpty) {
        throw ArgumentError.value(
          snapshot.recipient,
          'recipient',
          'Handled recipient snapshot must not be blank.',
        );
      }

      final affected =
          await (_database.update(_database.parentFollowUps)..where(
                (table) =>
                    table.id.equals(followUpId) &
                    table.status.equals(
                      ParentFollowUpStatus.pending.storageValue,
                    ),
              ))
              .write(
                ParentFollowUpsCompanion(
                  status: Value<String>(
                    ParentFollowUpStatus.handled.storageValue,
                  ),
                  attendanceStatusSnapshot: Value<String?>(
                    snapshot.attendanceStatus.storageValue,
                  ),
                  snapshotMessage: Value<String?>(message),
                  channelSnapshot: Value<String?>(
                    snapshot.channel.storageValue,
                  ),
                  recipientSnapshot: Value<String?>(recipient),
                ),
              );

      if (affected != 1) {
        final concurrent = await (_database.select(
          _database.parentFollowUps,
        )..where((table) => table.id.equals(followUpId))).getSingleOrNull();

        if (concurrent != null &&
            concurrent.status == ParentFollowUpStatus.handled.storageValue) {
          return _mapFollowUp(concurrent);
        }

        throw StateError(
          'Parent follow up $followUpId could not be marked handled.',
        );
      }

      final saved = await (_database.select(
        _database.parentFollowUps,
      )..where((table) => table.id.equals(followUpId))).getSingle();

      final attendance =
          await (_database.select(_database.attendanceRecords)..where(
                (table) =>
                    table.dayId.equals(saved.dayId) &
                    table.studentId.equals(saved.studentId),
              ))
              .getSingleOrNull();

      if (attendance == null) {
        throw StateError(
          'Attendance for student ${saved.studentId} '
          'on day ${saved.dayId} was not found.',
        );
      }

      await _reconcilePendingCorrection(
        dayId: saved.dayId,
        studentId: saved.studentId,
        currentStatus: attendance.status,
      );

      return _mapFollowUp(saved);
    });
  }

  Future<ParentFollowUp?> _reconcilePendingCorrection({
    required int dayId,
    required int studentId,
    required String currentStatus,
  }) async {
    final handledRows =
        await (_database.select(_database.parentFollowUps)
              ..where(
                (table) =>
                    table.dayId.equals(dayId) &
                    table.studentId.equals(studentId) &
                    table.status.equals(
                      ParentFollowUpStatus.handled.storageValue,
                    ),
              )
              ..orderBy([(table) => OrderingTerm.desc(table.id)])
              ..limit(1))
            .get();

    final latestHandled = handledRows.isEmpty ? null : handledRows.single;

    final pending =
        await (_database.select(_database.parentFollowUps)..where(
              (table) =>
                  table.dayId.equals(dayId) &
                  table.studentId.equals(studentId) &
                  table.type.equals(
                    ParentFollowUpType.attendanceCorrection.storageValue,
                  ) &
                  table.status.equals(
                    ParentFollowUpStatus.pending.storageValue,
                  ),
            ))
            .getSingleOrNull();

    if (latestHandled == null) {
      if (pending != null) {
        await (_database.delete(
          _database.parentFollowUps,
        )..where((table) => table.id.equals(pending.id))).go();
      }

      return null;
    }

    final baselineStatus = latestHandled.attendanceStatusSnapshot;

    if (baselineStatus == null) {
      throw StateError(
        'Handled parent follow up ${latestHandled.id} '
        'has no attendance snapshot.',
      );
    }

    if (currentStatus == baselineStatus) {
      if (pending != null) {
        await (_database.delete(
          _database.parentFollowUps,
        )..where((table) => table.id.equals(pending.id))).go();
      }

      return null;
    }

    if (pending == null) {
      await _database.customStatement(
        'INSERT INTO parent_follow_ups '
        '(day_id, student_id, type, status, corrects_follow_up_id) '
        "VALUES (?, ?, 'attendance_correction', 'pending', ?);",
        <Object?>[dayId, studentId, latestHandled.id],
      );
    } else if (pending.correctsFollowUpId != latestHandled.id) {
      final affected =
          await (_database.update(
            _database.parentFollowUps,
          )..where((table) => table.id.equals(pending.id))).write(
            ParentFollowUpsCompanion(
              correctsFollowUpId: Value<int?>(latestHandled.id),
            ),
          );

      if (affected != 1) {
        throw StateError(
          'Pending attendance correction ${pending.id} '
          'could not be reconciled.',
        );
      }
    }

    return (_database.select(_database.parentFollowUps)..where(
          (table) =>
              table.dayId.equals(dayId) &
              table.studentId.equals(studentId) &
              table.type.equals(
                ParentFollowUpType.attendanceCorrection.storageValue,
              ) &
              table.status.equals(ParentFollowUpStatus.pending.storageValue),
        ))
        .getSingle();
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

  ParentFollowUpRecord _mapFollowUp(ParentFollowUp row) {
    final type = ParentFollowUpType.fromStorage(row.type);
    final status = ParentFollowUpStatus.fromStorage(row.status);

    final snapshot = status == ParentFollowUpStatus.handled
        ? ParentFollowUpHandledSnapshot(
            attendanceStatus: ParentFollowUpAttendanceStatus.fromStorage(
              row.attendanceStatusSnapshot!,
            ),
            message: row.snapshotMessage!,
            channel: ParentFollowUpChannel.fromStorage(row.channelSnapshot!),
            recipient: row.recipientSnapshot!,
          )
        : null;

    return ParentFollowUpRecord(
      id: row.id,
      dayId: row.dayId,
      studentId: row.studentId,
      type: type,
      status: status,
      correctsFollowUpId: row.correctsFollowUpId,
      handledSnapshot: snapshot,
    );
  }
}
