import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_read_service.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';

void main() {
  group('Package 4 day history and summary', () {
    test(
      'history shows only completed days and holidays newest first with attendance counts',
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

          await _insertStudent(
            database,
            id: 2,
            name: 'Second',
            displayOrder: 2,
            isActive: true,
          );

          for (final id in <int>[1, 2]) {
            await _insertActivityPeriod(
              database,
              studentId: id,
              from: '2026-09-01',
            );
          }

          final repository = DriftDailyHalaqahRepository(database);
          final attendanceService = _service(repository);
          final closeDay = CloseHalaqahDayCore(repository);
          final holidays = HalaqahHolidayService(repository);
          final reads = DailyHalaqahReadService(repository);

          final closedDay = await repository.ensureDay(
            halaqahId: 1,
            dayDate: '2026-09-10',
          );

          await attendanceService.setAttendance(
            halaqahId: 1,
            dayId: closedDay.id,
            studentId: 1,
            status: AttendanceStatus.present,
          );

          await attendanceService.setAttendance(
            halaqahId: 1,
            dayId: closedDay.id,
            studentId: 2,
            status: AttendanceStatus.absent,
          );

          await closeDay(halaqahId: 1, dayId: closedDay.id);

          await repository.ensureDay(halaqahId: 1, dayDate: '2026-09-11');

          await holidays.markDay(
            halaqahId: 1,
            localDate: DateTime(2026, 9, 12),
          );

          final history = await reads.history(halaqahId: 1);

          expect(history, hasLength(2));

          expect(history[0].day.dayDate, '2026-09-12');
          expect(history[0].day.status, 'holiday');
          expect(history[0].attendance.totalStudents, 0);
          expect(history[0].attendance.presentCount, 0);
          expect(history[0].attendance.absentCount, 0);
          expect(history[0].attendance.excusedAbsentCount, 0);
          expect(history[0].attendance.unsetCount, 0);

          expect(history[1].day.dayDate, '2026-09-10');
          expect(history[1].day.status, 'closed');
          expect(history[1].attendance.totalStudents, 2);
          expect(history[1].attendance.presentCount, 1);
          expect(history[1].attendance.absentCount, 1);
          expect(history[1].attendance.excusedAbsentCount, 0);
          expect(history[1].attendance.unsetCount, 0);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'day summary preserves persisted student ordering and exposes unset attendance',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          await _insertStudent(
            database,
            id: 10,
            name: 'Third',
            displayOrder: 3,
            isActive: true,
          );

          await _insertStudent(
            database,
            id: 11,
            name: 'First historical',
            displayOrder: 1,
            isActive: false,
          );

          await _insertStudent(
            database,
            id: 12,
            name: 'Second',
            displayOrder: 2,
            isActive: true,
          );

          await _insertActivityPeriod(
            database,
            studentId: 10,
            from: '2026-09-01',
          );

          await _insertActivityPeriod(
            database,
            studentId: 11,
            from: '2026-09-01',
            to: '2026-09-14',
          );

          await _insertActivityPeriod(
            database,
            studentId: 12,
            from: '2026-09-01',
          );

          final repository = DriftDailyHalaqahRepository(database);
          final attendanceService = _service(repository);
          final reads = DailyHalaqahReadService(repository);

          final day = await repository.ensureDay(
            halaqahId: 1,
            dayDate: '2026-09-14',
          );

          await attendanceService.setAttendance(
            halaqahId: 1,
            dayId: day.id,
            studentId: 11,
            status: AttendanceStatus.excusedAbsent,
          );

          await attendanceService.setAttendance(
            halaqahId: 1,
            dayId: day.id,
            studentId: 12,
            status: AttendanceStatus.present,
          );

          final summary = await reads.summary(halaqahId: 1, dayId: day.id);

          expect(
            summary.students.map((item) => item.student.id).toList(),
            <int>[11, 12, 10],
          );

          expect(
            summary.students.map((item) => item.attendanceStatus).toList(),
            <AttendanceStatus?>[
              AttendanceStatus.excusedAbsent,
              AttendanceStatus.present,
              null,
            ],
          );

          expect(summary.attendance.totalStudents, 3);
          expect(summary.attendance.presentCount, 1);
          expect(summary.attendance.absentCount, 0);
          expect(summary.attendance.excusedAbsentCount, 1);
          expect(summary.attendance.unsetCount, 1);
        } finally {
          await database.close();
        }
      },
    );

    test('holiday summary has no absent or active student rows', () async {
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

        await _insertActivityPeriod(database, studentId: 1, from: '2026-09-01');

        final repository = DriftDailyHalaqahRepository(database);
        final holidays = HalaqahHolidayService(repository);
        final reads = DailyHalaqahReadService(repository);

        final holiday = await holidays.markDay(
          halaqahId: 1,
          localDate: DateTime(2026, 9, 14),
        );

        final summary = await reads.summary(halaqahId: 1, dayId: holiday.id);

        expect(summary.day.status, 'holiday');
        expect(summary.students, isEmpty);
        expect(summary.attendance.totalStudents, 0);
        expect(summary.attendance.presentCount, 0);
        expect(summary.attendance.absentCount, 0);
        expect(summary.attendance.excusedAbsentCount, 0);
        expect(summary.attendance.unsetCount, 0);
      } finally {
        await database.close();
      }
    });

    test('summary rejects a day belonging to another halaqah', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _insertHalaqah(database);

        await database.customStatement(
          "INSERT INTO halaqahs "
          "(id, teacher_name, halaqah_name, center_name, "
          "created_at_utc, updated_at_utc) "
          "VALUES ("
          "2, "
          "'Teacher 2', "
          "'Halaqah 2', "
          "'Center', "
          "'2026-09-01T10:00:00.000Z', "
          "'2026-09-01T10:00:00.000Z'"
          ");",
        );

        final repository = DriftDailyHalaqahRepository(database);
        final reads = DailyHalaqahReadService(repository);

        final otherDay = await repository.ensureDay(
          halaqahId: 2,
          dayDate: '2026-09-14',
        );

        await expectLater(
          reads.summary(halaqahId: 1, dayId: otherDay.id),
          throwsA(isA<StateError>()),
        );
      } finally {
        await database.close();
      }
    });
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
