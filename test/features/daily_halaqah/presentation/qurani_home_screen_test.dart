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
import 'package:qurani/features/daily_halaqah/presentation/qurani_home_screen.dart';

void main() {
  testWidgets('home shows before-start state and opens the daily halaqah', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());

    try {
      await _seed(database);

      final runtimeContext = _context(database);

      await tester.pumpWidget(
        MaterialApp(
          home: QuraniHomeScreen(
            runtimeContext: runtimeContext,
            onChangePin: () {},
            onLockNow: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('لم يبدأ يوم الحلقة بعد.'), findsOneWidget);

      expect(find.text('بدء يوم الحلقة'), findsOneWidget);

      await tester.tap(find.byKey(const Key('home_primary_day_action')));

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('daily_halaqah_screen')), findsOneWidget);

      final day = await runtimeContext.service.findToday(
        halaqahId: runtimeContext.halaqahId,
      );

      expect(day, isNotNull);
      expect(day!.status, 'open');
    } finally {
      await database.close();
    }
  });
}

DailyHalaqahRuntimeContext _context(AppDatabase database) {
  final repository = DriftDailyHalaqahRepository(database);
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
    "1, "
    "'Teacher', "
    "'Halaqah', "
    "'Center', "
    "'2026-09-01T10:00:00.000Z', "
    "'2026-09-01T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "1, 1, 'Student', 'Father', 10, '+967', "
    "'771234567', 'Previous', 1, 1"
    ");",
  );

  await database.customStatement(
    "INSERT INTO student_activity_periods "
    "(student_id, active_from_date, active_to_date) "
    "VALUES (1, '2026-09-01', NULL);",
  );
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 14, 12);

  @override
  DateTime todayLocal() => DateTime(2026, 9, 14);
}
