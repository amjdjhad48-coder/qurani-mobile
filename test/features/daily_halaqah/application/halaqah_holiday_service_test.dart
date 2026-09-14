import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';

void main() {
  group('Package 4 holidays', () {
    test('marks a single day as holiday and is idempotent', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _insertHalaqah(database);

        final repository = DriftDailyHalaqahRepository(database);
        final holidays = HalaqahHolidayService(repository);

        final first = await holidays.markDay(
          halaqahId: 1,
          localDate: DateTime(2026, 9, 14),
        );

        final second = await holidays.markDay(
          halaqahId: 1,
          localDate: DateTime(2026, 9, 14),
        );

        expect(first.status, 'holiday');
        expect(second.id, first.id);
        expect(second.status, 'holiday');

        final row = await database
            .customSelect(
              "SELECT COUNT(*) AS total "
              "FROM halaqah_days "
              "WHERE halaqah_id = 1 "
              "AND day_date = '2026-09-14';",
            )
            .getSingle();

        expect(row.read<int>('total'), 1);
      } finally {
        await database.close();
      }
    });

    test(
      'range converts an empty open day and creates the missing holiday days',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _insertHalaqah(database);

          final repository = DriftDailyHalaqahRepository(database);
          final holidays = HalaqahHolidayService(repository);

          final existingOpen = await repository.ensureDay(
            halaqahId: 1,
            dayDate: '2026-09-15',
          );

          final result = await holidays.markRange(
            halaqahId: 1,
            startLocalDate: DateTime(2026, 9, 14),
            endLocalDate: DateTime(2026, 9, 16),
          );

          expect(result.map((day) => day.dayDate).toList(), <String>[
            '2026-09-14',
            '2026-09-15',
            '2026-09-16',
          ]);

          expect(result.every((day) => day.status == 'holiday'), isTrue);

          final converted = result.singleWhere(
            (day) => day.dayDate == '2026-09-15',
          );

          expect(converted.id, existingOpen.id);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'full prevalidation prevents every write when one day has attendance',
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
          final holidays = HalaqahHolidayService(repository);

          final activeDay = await repository.ensureDay(
            halaqahId: 1,
            dayDate: '2026-09-15',
          );

          await service.setAttendance(
            halaqahId: 1,
            dayId: activeDay.id,
            studentId: 1,
            status: AttendanceStatus.present,
          );

          await expectLater(
            holidays.markRange(
              halaqahId: 1,
              startLocalDate: DateTime(2026, 9, 14),
              endLocalDate: DateTime(2026, 9, 16),
            ),
            throwsA(
              isA<HolidayConflictException>().having(
                (error) => error.conflictingDayDates,
                'conflictingDayDates',
                <String>['2026-09-15'],
              ),
            ),
          );

          final days = await database
              .customSelect(
                'SELECT day_date, status '
                'FROM halaqah_days '
                'ORDER BY day_date;',
              )
              .get();

          expect(days, hasLength(1));
          expect(days.single.read<String>('day_date'), '2026-09-15');
          expect(days.single.read<String>('status'), 'open');
        } finally {
          await database.close();
        }
      },
    );

    test('closed day cannot be silently converted to holiday', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _insertHalaqah(database);

        final repository = DriftDailyHalaqahRepository(database);
        final closeDay = CloseHalaqahDayCore(repository);
        final holidays = HalaqahHolidayService(repository);

        final openDay = await repository.ensureDay(
          halaqahId: 1,
          dayDate: '2026-09-14',
        );

        final closed = await closeDay(halaqahId: 1, dayId: openDay.id);

        expect(closed.status, 'closed');

        await expectLater(
          holidays.markDay(halaqahId: 1, localDate: DateTime(2026, 9, 14)),
          throwsA(isA<HolidayConflictException>()),
        );

        final unchanged = await repository.findDayById(openDay.id);

        expect(unchanged, isNotNull);
        expect(unchanged!.status, 'closed');
      } finally {
        await database.close();
      }
    });

    test('attendance cannot be written on a holiday', () async {
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
        final service = _service(repository);
        final holidays = HalaqahHolidayService(repository);

        final holiday = await holidays.markDay(
          halaqahId: 1,
          localDate: DateTime(2026, 9, 14),
        );

        await expectLater(
          service.setAttendance(
            halaqahId: 1,
            dayId: holiday.id,
            studentId: 1,
            status: AttendanceStatus.present,
          ),
          throwsA(isA<StateError>()),
        );

        await expectLater(
          service.markAllPresent(halaqahId: 1, dayId: holiday.id),
          throwsA(isA<StateError>()),
        );

        final rows = await database
            .customSelect('SELECT COUNT(*) AS total FROM attendance_records;')
            .getSingle();

        expect(rows.read<int>('total'), 0);
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
