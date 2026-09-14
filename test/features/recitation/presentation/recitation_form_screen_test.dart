import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/data/drift_recitation_repository.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';
import 'package:qurani/features/recitation/presentation/recitation_form_screen.dart';

void main() {
  group('Package 5 recitation form', () {
    testWidgets('creates revision with quarter achievement and optional plan', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final dailyRepository = DriftDailyHalaqahRepository(database);
        final day = await dailyRepository.ensureDay(
          halaqahId: 1,
          dayDate: '2026-09-14',
        );

        final service = _service(database);

        await tester.pumpWidget(
          MaterialApp(
            home: RecitationFormScreen(
              service: service,
              halaqahId: 1,
              dayId: day.id,
              studentId: 1,
              studentName: 'أحمد',
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('recitation_form_screen')), findsOneWidget);
        expect(find.text('أحمد'), findsOneWidget);

        await tester.tap(find.text('مراجعة'));
        await tester.pump();

        await tester.enterText(
          find.byKey(const Key('recitation_end_ayah_field')),
          '5',
        );

        await tester.tap(find.byKey(const Key('recitation_quarter_2')));
        await tester.pump();

        await tester.scrollUntilVisible(
          find.byKey(const Key('recitation_error_count_field')),
          250,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.enterText(
          find.byKey(const Key('recitation_error_count_field')),
          '2',
        );

        await tester.scrollUntilVisible(
          find.byKey(const Key('recitation_note_field')),
          250,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.enterText(
          find.byKey(const Key('recitation_note_field')),
          '  يحتاج متابعة  ',
        );

        await tester.scrollUntilVisible(
          find.byKey(const Key('recitation_planned_range_toggle')),
          250,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.tap(
          find.byKey(const Key('recitation_planned_range_toggle')),
        );
        await tester.pump();

        await tester.scrollUntilVisible(
          find.byKey(const Key('recitation_planned_end_ayah_field')),
          250,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.enterText(
          find.byKey(const Key('recitation_planned_end_ayah_field')),
          '7',
        );

        await tester.scrollUntilVisible(
          find.byKey(const Key('save_recitation_button')),
          250,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.tap(find.byKey(const Key('save_recitation_button')));

        await tester.pumpAndSettle();

        final records = await service.listForDayStudent(
          halaqahId: 1,
          dayId: day.id,
          studentId: 1,
        );

        expect(records, hasLength(1));

        final record = records.single;

        expect(record.type, RecitationType.revision);
        expect(record.actualRange.start.surahNumber, 1);
        expect(record.actualRange.start.ayahNumber, 1);
        expect(record.actualRange.end.surahNumber, 1);
        expect(record.actualRange.end.ayahNumber, 5);
        expect(record.facesQuarterAchieved, 2);
        expect(record.errorCount, 2);
        expect(record.note, 'يحتاج متابعة');

        expect(record.plannedRange, isNotNull);
        expect(record.plannedRange!.start.surahNumber, 1);
        expect(record.plannedRange!.start.ayahNumber, 1);
        expect(record.plannedRange!.end.surahNumber, 1);
        expect(record.plannedRange!.end.ayahNumber, 7);
      } finally {
        await database.close();
      }
    });

    testWidgets('edits an existing recitation without changing identity', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final dailyRepository = DriftDailyHalaqahRepository(database);
        final day = await dailyRepository.ensureDay(
          halaqahId: 1,
          dayDate: '2026-09-14',
        );

        final service = _service(database);

        final created = await service.createForDay(
          halaqahId: 1,
          dayId: day.id,
          studentId: 1,
          data: const RecitationWriteData(
            type: RecitationType.newMemorization,
            actualRange: QuranRange(
              start: QuranPosition(surahNumber: 1, ayahNumber: 1),
              end: QuranPosition(surahNumber: 1, ayahNumber: 3),
            ),
            facesQuarterAchieved: 1,
            evaluation: RecitationEvaluation.excellent,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: RecitationFormScreen(
              service: service,
              halaqahId: 1,
              dayId: day.id,
              studentId: 1,
              studentName: 'أحمد',
              existing: created,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('تعديل التسميع'), findsOneWidget);

        await tester.tap(find.byKey(const Key('recitation_quarter_4')));

        await tester.scrollUntilVisible(
          find.byKey(const Key('recitation_note_field')),
          250,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.enterText(
          find.byKey(const Key('recitation_note_field')),
          'تم التعديل',
        );

        await tester.scrollUntilVisible(
          find.byKey(const Key('save_recitation_button')),
          250,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.tap(find.byKey(const Key('save_recitation_button')));

        await tester.pumpAndSettle();

        final records = await service.listForDayStudent(
          halaqahId: 1,
          dayId: day.id,
          studentId: 1,
        );

        expect(records, hasLength(1));
        expect(records.single.id, created.id);
        expect(records.single.facesQuarterAchieved, 4);
        expect(records.single.note, 'تم التعديل');
      } finally {
        await database.close();
      }
    });

    testWidgets(
      'shows validation error and writes nothing for invalid Quran range',
      (tester) async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(database);

          final dailyRepository = DriftDailyHalaqahRepository(database);
          final day = await dailyRepository.ensureDay(
            halaqahId: 1,
            dayDate: '2026-09-14',
          );

          final service = _service(database);

          await tester.pumpWidget(
            MaterialApp(
              home: RecitationFormScreen(
                service: service,
                halaqahId: 1,
                dayId: day.id,
                studentId: 1,
                studentName: 'أحمد',
              ),
            ),
          );

          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('recitation_start_ayah_field')),
            '7',
          );

          await tester.enterText(
            find.byKey(const Key('recitation_end_ayah_field')),
            '1',
          );

          await tester.scrollUntilVisible(
            find.byKey(const Key('save_recitation_button')),
            250,
            scrollable: find.byType(Scrollable).first,
          );

          await tester.tap(find.byKey(const Key('save_recitation_button')));

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('recitation_form_error')),
            findsOneWidget,
          );

          final records = await service.listForDayStudent(
            halaqahId: 1,
            dayId: day.id,
            studentId: 1,
          );

          expect(records, isEmpty);
        } finally {
          await database.close();
        }
      },
    );
  });
}

RecitationService _service(AppDatabase database) {
  final dailyRepository = DriftDailyHalaqahRepository(database);

  return RecitationService(
    repository: DriftRecitationRepository(database),
    dailyHalaqahRepository: dailyRepository,
    clock: const _FixedClock(),
  );
}

Future<void> _seed(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'الحلقة', 'المركز', "
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
    "1, 1, 'أحمد', 'محمد', 12, '+967', "
    "'771234567', 'جزء سابق', 1, 1"
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
