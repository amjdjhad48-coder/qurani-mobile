import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_read_service.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/presentation/daily_halaqah_screen.dart';

void main() {
  testWidgets(
    'daily UI marks all unspecified present and closes a complete day',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final repository = DriftDailyHalaqahRepository(database);
        final runtimeContext = _context(database, repository);

        await tester.pumpWidget(
          MaterialApp(home: DailyHalaqahScreen(runtimeContext: runtimeContext)),
        );

        await tester.pumpAndSettle();

        expect(find.text('Student 1'), findsOneWidget);
        expect(find.text('Student 2'), findsOneWidget);

        await tester.tap(find.byKey(const Key('mark_all_present_button')));

        await tester.pumpAndSettle();

        final day = await runtimeContext.service.findToday(halaqahId: 1);

        expect(day, isNotNull);

        final attendance = await repository.attendanceForDay(day!.id);

        expect(attendance, hasLength(2));
        expect(
          attendance.every(
            (record) => record.status == AttendanceStatus.present,
          ),
          isTrue,
        );

        await tester.tap(find.byKey(const Key('end_halaqah_day_button')));

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('confirm_end_day_button')), findsOneWidget);

        await tester.tap(find.byKey(const Key('confirm_end_day_button')));

        await tester.pumpAndSettle();

        final closed = await repository.findDayById(day.id);

        expect(closed, isNotNull);
        expect(closed!.status, 'closed');

        expect(
          find.byKey(const Key('halaqah_day_summary_screen')),
          findsOneWidget,
        );
      } finally {
        await database.close();
      }
    },
  );
}

DailyHalaqahRuntimeContext _context(
  AppDatabase database,
  DriftDailyHalaqahRepository repository,
) {
  const clock = _FixedClock();

  return DailyHalaqahRuntimeContext(
    halaqahId: 1,
    halaqahName: 'حلقة الاختبار',
    teacherName: 'المعلم',
    clock: clock,
    service: DailyHalaqahService(repository: repository, clock: clock),
    readService: DailyHalaqahReadService(repository),
    holidayService: HalaqahHolidayService(repository),
    closeDayCore: CloseHalaqahDayCore(repository),
  );
}

Future<void> _seed(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'Teacher', 'Halaqah', 'Center', "
    "'2026-09-01T10:00:00.000Z', "
    "'2026-09-01T10:00:00.000Z'"
    ");",
  );

  for (var id = 1; id <= 2; id++) {
    await database.customStatement(
      "INSERT INTO students "
      "(id, halaqah_id, student_name, father_name, age_years, "
      "guardian_country_code, guardian_national_number, "
      "previous_memorization_text, display_order, is_active) "
      "VALUES ("
      "$id, 1, 'Student $id', 'Father', 10, '+967', "
      "'77123456$id', 'Previous', $id, 1"
      ");",
    );

    await database.customStatement(
      "INSERT INTO student_activity_periods "
      "(student_id, active_from_date, active_to_date) "
      "VALUES ($id, '2026-09-01', NULL);",
    );
  }
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 14, 12);

  @override
  DateTime todayLocal() => DateTime(2026, 9, 14);
}
