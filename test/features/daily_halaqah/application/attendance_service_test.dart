import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';

void main() {
  group('Package 4 attendance states and mark all present', () {
    test(
      'setAttendance creates and updates one row per day and student',
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

          final service = _service(database);
          final session = await service.startToday(halaqahId: 1);

          final present = await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.present,
          );

          expect(present.status, AttendanceStatus.present);

          final absent = await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.absent,
          );

          expect(absent.status, AttendanceStatus.absent);

          final excused = await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.excusedAbsent,
          );

          expect(excused.status, AttendanceStatus.excusedAbsent);

          final count = await database
              .customSelect(
                'SELECT COUNT(*) AS total '
                'FROM attendance_records '
                'WHERE day_id = ? AND student_id = ?;',
                variables: const [Variable<int>(1), Variable<int>(1)],
              )
              .getSingle();

          expect(count.read<int>('total'), 1);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'markAllPresent fills only unspecified students and preserves exceptions',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          for (final student in <({int id, int order})>[
            (id: 1, order: 1),
            (id: 2, order: 2),
            (id: 3, order: 3),
          ]) {
            await _insertStudent(
              database,
              id: student.id,
              name: 'Student ${student.id}',
              displayOrder: student.order,
              isActive: true,
            );

            await _insertActivityPeriod(
              database,
              studentId: student.id,
              from: '2026-09-01',
            );
          }

          final service = _service(database);
          final session = await service.startToday(halaqahId: 1);

          await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 2,
            status: AttendanceStatus.absent,
          );

          await service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 3,
            status: AttendanceStatus.excusedAbsent,
          );

          final inserted = await service.markAllPresent(
            halaqahId: 1,
            dayId: session.day.id,
          );

          expect(inserted, 1);

          final attendance = await service.attendanceForDay(
            halaqahId: 1,
            dayId: session.day.id,
          );

          final byStudent = <int, AttendanceStatus>{
            for (final record in attendance) record.studentId: record.status,
          };

          expect(byStudent[1], AttendanceStatus.present);
          expect(byStudent[2], AttendanceStatus.absent);
          expect(byStudent[3], AttendanceStatus.excusedAbsent);

          final secondPass = await service.markAllPresent(
            halaqahId: 1,
            dayId: session.day.id,
          );

          expect(secondPass, 0);
        } finally {
          await database.close();
        }
      },
    );

    test('attendance rejects a student not active on the day', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _insertHalaqah(database);

        await _insertStudent(
          database,
          id: 1,
          name: 'Future student',
          displayOrder: 1,
          isActive: true,
        );

        await _insertActivityPeriod(database, studentId: 1, from: '2026-09-15');

        final service = _service(database);
        final session = await service.startToday(halaqahId: 1);

        await expectLater(
          service.setAttendance(
            halaqahId: 1,
            dayId: session.day.id,
            studentId: 1,
            status: AttendanceStatus.present,
          ),
          throwsA(isA<StateError>()),
        );

        final attendance = await service.attendanceForDay(
          halaqahId: 1,
          dayId: session.day.id,
        );

        expect(attendance, isEmpty);
      } finally {
        await database.close();
      }
    });

    test(
      'markAllPresent uses historical activity even when current isActive is false',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          await _insertStudent(
            database,
            id: 1,
            name: 'Historical student',
            displayOrder: 1,
            isActive: false,
          );

          await _insertActivityPeriod(
            database,
            studentId: 1,
            from: '2026-09-01',
            to: '2026-09-14',
          );

          final service = _service(database);
          final session = await service.startToday(halaqahId: 1);

          expect(session.students.map((student) => student.id).toList(), <int>[
            1,
          ]);

          final inserted = await service.markAllPresent(
            halaqahId: 1,
            dayId: session.day.id,
          );

          expect(inserted, 1);

          final attendance = await service.attendanceForDay(
            halaqahId: 1,
            dayId: session.day.id,
          );

          expect(attendance, hasLength(1));
          expect(attendance.single.studentId, 1);
          expect(attendance.single.status, AttendanceStatus.present);
        } finally {
          await database.close();
        }
      },
    );
  });
}

DailyHalaqahService _service(AppDatabase database) {
  return DailyHalaqahService(
    repository: DriftDailyHalaqahRepository(database),
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
