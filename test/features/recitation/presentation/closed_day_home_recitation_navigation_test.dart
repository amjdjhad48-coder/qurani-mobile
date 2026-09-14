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
import 'package:qurani/features/daily_halaqah/presentation/qurani_home_screen.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/data/drift_recitation_repository.dart';

void main() {
  testWidgets(
    'home reopens a closed day through DailyHalaqahScreen so recitation remains reachable',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final dailyRepository = DriftDailyHalaqahRepository(database);

        final day = await dailyRepository.ensureDay(
          halaqahId: 1,
          dayDate: '2026-09-14',
        );

        await dailyRepository.setAttendance(
          dayId: day.id,
          studentId: 1,
          status: AttendanceStatus.present,
        );

        await dailyRepository.closeDay(day.id);

        final recitationService = RecitationService(
          repository: DriftRecitationRepository(database),
          dailyHalaqahRepository: dailyRepository,
          clock: const _FixedClock(),
        );

        final runtimeContext = DailyHalaqahRuntimeContext(
          halaqahId: 1,
          halaqahName: 'حلقة الاختبار',
          teacherName: 'المعلم',
          clock: const _FixedClock(),
          service: DailyHalaqahService(
            repository: dailyRepository,
            clock: const _FixedClock(),
          ),
          readService: DailyHalaqahReadService(dailyRepository),
          holidayService: HalaqahHolidayService(dailyRepository),
          closeDayCore: CloseHalaqahDayCore(dailyRepository),
          recitationService: recitationService,
        );

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

        expect(find.text('تم إنهاء يوم الحلقة.'), findsOneWidget);

        expect(find.text('فتح يوم الحلقة'), findsOneWidget);

        await tester.tap(find.byKey(const Key('home_primary_day_action')));

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('daily_halaqah_screen')), findsOneWidget);

        expect(find.byKey(const Key('add_recitation_1')), findsOneWidget);

        expect(
          find.byKey(const Key('open_current_day_summary_button')),
          findsOneWidget,
        );
      } finally {
        await database.close();
      }
    },
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

  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "1, 1, 'Student 1', 'Father', 10, '+967', "
    "'771234561', 'Previous', 1, 1"
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
