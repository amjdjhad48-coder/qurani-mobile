import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';

void main() {
  group('Package 4 ensure day and historical students', () {
    test('startToday creates one open day using the local date', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _insertHalaqah(database);

        final service = _service(database, today: DateTime(2026, 9, 14));

        final first = await service.startToday(halaqahId: 1);
        final second = await service.startToday(halaqahId: 1);

        expect(first.day.dayDate, '2026-09-14');
        expect(first.day.status, 'open');
        expect(second.day.id, first.day.id);

        final rows = await database
            .customSelect(
              "SELECT COUNT(*) AS total "
              "FROM halaqah_days "
              "WHERE halaqah_id = 1 "
              "AND day_date = '2026-09-14';",
            )
            .getSingle();

        expect(rows.read<int>('total'), 1);
      } finally {
        await database.close();
      }
    });

    test(
      'ensureToday reuses an existing day without changing its status',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          final service = _service(database, today: DateTime(2026, 9, 14));

          final day = await service.ensureToday(halaqahId: 1);

          await database.customStatement(
            "UPDATE halaqah_days "
            "SET status = 'closed' "
            "WHERE id = ${day.id};",
          );

          final reused = await service.ensureToday(halaqahId: 1);

          expect(reused.id, day.id);
          expect(reused.status, 'closed');
        } finally {
          await database.close();
        }
      },
    );

    test(
      'historical selection uses activity periods instead of current isActive',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          await _insertStudent(
            database,
            id: 1,
            name: 'Current',
            displayOrder: 2,
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
            name: 'Archived historical',
            displayOrder: 1,
            isActive: false,
          );

          await _insertActivityPeriod(
            database,
            studentId: 2,
            from: '2026-08-01',
            to: '2026-09-10',
          );

          await _insertStudent(
            database,
            id: 3,
            name: 'Future',
            displayOrder: 3,
            isActive: true,
          );

          await _insertActivityPeriod(
            database,
            studentId: 3,
            from: '2026-09-20',
          );

          final service = _service(database, today: DateTime(2026, 9, 14));

          final onSeptember10 = await service.studentsActiveOn(
            halaqahId: 1,
            localDate: DateTime(2026, 9, 10),
          );

          expect(onSeptember10.map((student) => student.id).toList(), <int>[
            2,
            1,
          ]);

          final onSeptember11 = await service.studentsActiveOn(
            halaqahId: 1,
            localDate: DateTime(2026, 9, 11),
          );

          expect(onSeptember11.map((student) => student.id).toList(), <int>[1]);
        } finally {
          await database.close();
        }
      },
    );

    test('historical selection keeps persisted student ordering', () async {
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
          name: 'First',
          displayOrder: 1,
          isActive: true,
        );

        await _insertStudent(
          database,
          id: 12,
          name: 'Second',
          displayOrder: 2,
          isActive: true,
        );

        for (final id in <int>[10, 11, 12]) {
          await _insertActivityPeriod(
            database,
            studentId: id,
            from: '2026-09-01',
          );
        }

        final service = _service(database, today: DateTime(2026, 9, 14));

        final students = await service.studentsActiveOn(
          halaqahId: 1,
          localDate: DateTime(2026, 9, 14),
        );

        expect(students.map((student) => student.id).toList(), <int>[
          11,
          12,
          10,
        ]);
      } finally {
        await database.close();
      }
    });

    test(
      'startToday returns the historically active students for today',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          await _insertStudent(
            database,
            id: 21,
            name: 'Today student',
            displayOrder: 1,
            isActive: true,
          );

          await _insertActivityPeriod(
            database,
            studentId: 21,
            from: '2026-09-14',
          );

          await _insertStudent(
            database,
            id: 22,
            name: 'Tomorrow student',
            displayOrder: 2,
            isActive: true,
          );

          await _insertActivityPeriod(
            database,
            studentId: 22,
            from: '2026-09-15',
          );

          final service = _service(database, today: DateTime(2026, 9, 14));

          final session = await service.startToday(halaqahId: 1);

          expect(session.day.dayDate, '2026-09-14');
          expect(session.students.map((student) => student.id).toList(), <int>[
            21,
          ]);
        } finally {
          await database.close();
        }
      },
    );
  });
}

DailyHalaqahService _service(AppDatabase database, {required DateTime today}) {
  return DailyHalaqahService(
    repository: DriftDailyHalaqahRepository(database),
    clock: _FixedClock(today),
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
  const _FixedClock(this._today);

  final DateTime _today;

  @override
  DateTime nowUtc() => DateTime.utc(_today.year, _today.month, _today.day, 12);

  @override
  DateTime todayLocal() => DateTime(_today.year, _today.month, _today.day);
}
