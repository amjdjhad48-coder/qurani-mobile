import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_read_service.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/daily_halaqah/presentation/daily_halaqah_screen.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/data/drift_recitation_repository.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

void main() {
  group('Package 5 daily recitation integration', () {
    testWidgets(
      'student card shows multiple recitations totals add edit and delete',
      (tester) async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(database);

          final dailyRepository = DriftDailyHalaqahRepository(database);
          final day = await dailyRepository.ensureDay(
            halaqahId: 1,
            dayDate: '2026-09-14',
          );

          final recitationService = _recitationService(
            database,
            dailyRepository,
          );

          final newMemorization = await recitationService.createForDay(
            halaqahId: 1,
            dayId: day.id,
            studentId: 1,
            data: _data(type: RecitationType.newMemorization, quarters: 2),
          );

          final revision = await recitationService.createForDay(
            halaqahId: 1,
            dayId: day.id,
            studentId: 1,
            data: _data(type: RecitationType.revision, quarters: 4),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: DailyHalaqahScreen(
                runtimeContext: _context(dailyRepository, recitationService),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('student_recitation_section_1')),
            findsOneWidget,
          );

          expect(
            find.byKey(Key('recitation_record_${newMemorization.id}')),
            findsOneWidget,
          );

          expect(
            find.byKey(Key('recitation_record_${revision.id}')),
            findsOneWidget,
          );

          expect(
            find.text('التقدم المحسوب - الحفظ الجديد فقط: 2 ربع وجه'),
            findsOneWidget,
          );

          expect(find.text('المراجعة: 4 ربع وجه'), findsOneWidget);

          final dailyScroll = find
              .descendant(
                of: find.byKey(const Key('daily_halaqah_student_list')),
                matching: find.byType(Scrollable),
              )
              .first;

          await tester.scrollUntilVisible(
            find.byKey(const Key('add_recitation_1')),
            250,
            scrollable: dailyScroll,
          );

          await tester.tap(find.byKey(const Key('add_recitation_1')));

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('recitation_form_screen')),
            findsOneWidget,
          );

          expect(find.text('Student 1'), findsOneWidget);

          await tester.pageBack();
          await tester.pumpAndSettle();

          await tester.scrollUntilVisible(
            find.byKey(Key('edit_recitation_${newMemorization.id}')),
            250,
            scrollable: dailyScroll,
          );

          await tester.tap(
            find.byKey(Key('edit_recitation_${newMemorization.id}')),
          );

          await tester.pumpAndSettle();

          expect(find.text('تعديل التسميع'), findsOneWidget);

          await tester.pageBack();
          await tester.pumpAndSettle();

          await tester.scrollUntilVisible(
            find.byKey(Key('delete_recitation_${revision.id}')),
            250,
            scrollable: dailyScroll,
          );

          await tester.tap(find.byKey(Key('delete_recitation_${revision.id}')));

          await tester.pumpAndSettle();

          expect(find.text('حذف التسميع'), findsOneWidget);

          await tester.tap(
            find.byKey(Key('confirm_delete_recitation_${revision.id}')),
          );

          await tester.pumpAndSettle();

          expect(
            find.byKey(Key('recitation_record_${revision.id}')),
            findsNothing,
          );

          expect(
            find.byKey(Key('recitation_record_${newMemorization.id}')),
            findsOneWidget,
          );

          expect(find.text('المراجعة: 0 ربع وجه'), findsOneWidget);
        } finally {
          await database.close();
        }
      },
    );

    testWidgets('closed day still exposes recitation actions', (tester) async {
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

        final recitationService = _recitationService(database, dailyRepository);

        await tester.pumpWidget(
          MaterialApp(
            home: DailyHalaqahScreen(
              runtimeContext: _context(dailyRepository, recitationService),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('add_recitation_1')), findsOneWidget);

        await tester.tap(find.byKey(const Key('add_recitation_1')));

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('recitation_form_screen')), findsOneWidget);

        expect(find.text('تسجيل التسميع'), findsOneWidget);
      } finally {
        await database.close();
      }
    });
  });
}

DailyHalaqahRuntimeContext _context(
  DriftDailyHalaqahRepository dailyRepository,
  RecitationService recitationService,
) {
  const clock = _FixedClock();

  return DailyHalaqahRuntimeContext(
    halaqahId: 1,
    halaqahName: 'حلقة الاختبار',
    teacherName: 'المعلم',
    clock: clock,
    service: DailyHalaqahService(repository: dailyRepository, clock: clock),
    readService: DailyHalaqahReadService(dailyRepository),
    holidayService: HalaqahHolidayService(dailyRepository),
    closeDayCore: CloseHalaqahDayCore(dailyRepository),
    recitationService: recitationService,
  );
}

RecitationService _recitationService(
  AppDatabase database,
  DriftDailyHalaqahRepository dailyRepository,
) {
  return RecitationService(
    repository: DriftRecitationRepository(database),
    dailyHalaqahRepository: dailyRepository,
    clock: const _FixedClock(),
  );
}

RecitationWriteData _data({
  required RecitationType type,
  required int quarters,
}) {
  return RecitationWriteData(
    type: type,
    actualRange: const QuranRange(
      start: QuranPosition(surahNumber: 2, ayahNumber: 1),
      end: QuranPosition(surahNumber: 2, ayahNumber: 5),
    ),
    facesQuarterAchieved: quarters,
    evaluation: RecitationEvaluation.excellent,
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
