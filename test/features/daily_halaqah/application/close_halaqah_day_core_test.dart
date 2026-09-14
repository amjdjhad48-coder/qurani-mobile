import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';

void main() {
  group('Package 4 close halaqah day core', () {
    test(
      'closes an open day when attendance is complete for historical students',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          await _insertStudent(
            database,
            id: 1,
            name: 'Current student',
            displayOrder: 1,
            isActive: true,
          );

          await _insertActivityPeriod(
            database,
            studentId: 1,
            from: '2026-09-01',
          );

          await _insertStudent(
            database,
            id: 2,
            name: 'Historical student',
            displayOrder: 2,
            isActive: false,
          );

          await _insertActivityPeriod(
            database,
            studentId: 2,
            from: '2026-09-01',
            to: '2026-09-14',
          );

          final repository = DriftDailyHalaqahRepository(database);
          final service = _service(repository);
          final closeDay = CloseHalaqahDayCore(repository);

          final session = await service.startToday(halaqahId: 1);

          await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.present,
          );

          await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 2,
            status: AttendanceStatus.absent,
          );

          final closed = await closeDay(halaqahId: 1, dayId: session.day.id);

          expect(closed.status, 'closed');
          expect(closed.isClosed, isTrue);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'rejects closing while a historical student has unset attendance',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          await _insertStudent(
            database,
            id: 1,
            name: 'First',
            displayOrder: 1,
            isActive: true,
          );

          await _insertActivityPeriod(
            database,
            studentId: 1,
            from: '2026-09-01',
          );

          await _insertStudent(
            database,
            id: 2,
            name: 'Archived but active that day',
            displayOrder: 2,
            isActive: false,
          );

          await _insertActivityPeriod(
            database,
            studentId: 2,
            from: '2026-09-01',
            to: '2026-09-14',
          );

          final repository = DriftDailyHalaqahRepository(database);
          final service = _service(repository);
          final closeDay = CloseHalaqahDayCore(repository);

          final session = await service.startToday(halaqahId: 1);

          await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.present,
          );

          await expectLater(
            closeDay(halaqahId: 1, dayId: session.day.id),
            throwsA(
              isA<IncompleteAttendanceException>()
                  .having((error) => error.missingCount, 'missingCount', 1)
                  .having(
                    (error) => error.missingStudentIds,
                    'missingStudentIds',
                    <int>[2],
                  ),
            ),
          );

          final stillOpen = await repository.findDayById(session.day.id);

          expect(stillOpen, isNotNull);
          expect(stillOpen!.status, 'open');
        } finally {
          await database.close();
        }
      },
    );

    test(
      'attendance remains editable after close without reopening the day',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          await _insertStudent(
            database,
            id: 1,
            name: 'Student',
            displayOrder: 1,
            isActive: true,
          );

          await _insertActivityPeriod(
            database,
            studentId: 1,
            from: '2026-09-01',
          );

          final repository = DriftDailyHalaqahRepository(database);
          final service = _service(repository);
          final closeDay = CloseHalaqahDayCore(repository);

          final session = await service.startToday(halaqahId: 1);

          await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.absent,
          );

          await closeDay(halaqahId: 1, dayId: session.day.id);

          final edited = await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.excusedAbsent,
          );

          expect(edited.status, AttendanceStatus.excusedAbsent);

          final dayAfterEdit = await repository.findDayById(session.day.id);

          expect(dayAfterEdit, isNotNull);
          expect(dayAfterEdit!.status, 'closed');

          final attendance = await service.attendanceForDay(
            halaqahId: 1,
            dayId: session.day.id,
          );

          expect(attendance, hasLength(1));
          expect(attendance.single.status, AttendanceStatus.excusedAbsent);
        } finally {
          await database.close();
        }
      },
    );
  });
}

DailyHalaqahService _service(DriftDailyHalaqahRepository repository) {
  return DailyHalaqahService(
    repository: repository,
    clock: const _FixedClock(),
  );
}

Future<void> _insertHalaqah(AppDatabase database) {
  return database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, "
    "'Teacher', "
    "'Halaqah', "
    "'Center', "
    "'2026-09-01T10:00:00.000Z', "
    "'2026-09-01T10:00:00.000Z'"
    ");",
  );
}

Future<void> _insertStudent(
  AppDatabase database, {
  required int id,
  required String name,
  required int displayOrder,
  required bool isActive,
}) {
  return database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "$id, "
    "1, "
    "'$name', "
    "'Father', "
    "10, "
    "'+967', "
    "'771234567', "
    "'Previous', "
    "$displayOrder, "
    "${isActive ? 1 : 0}"
    ");",
  );
}

Future<void> _insertActivityPeriod(
  AppDatabase database, {
  required int studentId,
  required String from,
  String? to,
}) {
  final toSql = to == null ? 'NULL' : "'$to'";

  return database.customStatement(
    "INSERT INTO student_activity_periods "
    "(student_id, active_from_date, active_to_date) "
    "VALUES ($studentId, '$from', $toSql);",
  );
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 14, 12);

  @override
  DateTime todayLocal() => DateTime(2026, 9, 14);
}
