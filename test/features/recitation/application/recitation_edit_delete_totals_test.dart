import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/application/recitation_validator.dart';
import 'package:qurani/features/recitation/data/drift_recitation_repository.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

void main() {
  group('Package 5 edit delete and derived totals', () {
    test('derived totals separate new memorization from revision', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final service = _service(database);

        await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(
            type: RecitationType.newMemorization,
            facesQuarterAchieved: 2,
          ),
        );

        await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(type: RecitationType.revision, facesQuarterAchieved: 8),
        );

        await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(
            type: RecitationType.newMemorization,
            facesQuarterAchieved: 3,
          ),
        );

        final daily = DriftDailyHalaqahRepository(database);
        final day = await daily.findDay(halaqahId: 1, dayDate: '2026-09-14');

        expect(day, isNotNull);

        final dayTotals = await service.totalsForDayStudent(
          halaqahId: 1,
          dayId: day!.id,
          studentId: 1,
        );

        final allTotals = await service.totalsForStudent(
          halaqahId: 1,
          studentId: 1,
        );

        expect(dayTotals.newMemorizationQuarterFaces, 5);
        expect(dayTotals.revisionQuarterFaces, 8);
        expect(dayTotals.calculatedProgressQuarterFaces, 5);
        expect(dayTotals.calculatedProgressFaces, 1.25);
        expect(dayTotals.totalRecordedQuarterFaces, 13);

        expect(allTotals.newMemorizationQuarterFaces, 5);
        expect(allTotals.revisionQuarterFaces, 8);
        expect(allTotals.calculatedProgressQuarterFaces, 5);
      } finally {
        await database.close();
      }
    });

    test('editing recalculates totals from persisted recitations', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final service = _service(database);

        final created = await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(
            type: RecitationType.newMemorization,
            facesQuarterAchieved: 4,
          ),
        );

        final before = await service.totalsForStudent(
          halaqahId: 1,
          studentId: 1,
        );

        expect(before.calculatedProgressQuarterFaces, 4);
        expect(before.revisionQuarterFaces, 0);

        final updated = await service.update(
          halaqahId: 1,
          recitationId: created.id,
          data: _data(
            type: RecitationType.revision,
            facesQuarterAchieved: 6,
            evaluation: RecitationEvaluation.good,
            errorCount: 2,
            note: '  تعديل  ',
          ),
        );

        expect(updated.id, created.id);
        expect(updated.type, RecitationType.revision);
        expect(updated.facesQuarterAchieved, 6);
        expect(updated.evaluation, RecitationEvaluation.good);
        expect(updated.errorCount, 2);
        expect(updated.note, 'تعديل');

        final after = await service.totalsForStudent(
          halaqahId: 1,
          studentId: 1,
        );

        expect(after.newMemorizationQuarterFaces, 0);
        expect(after.revisionQuarterFaces, 6);
        expect(after.calculatedProgressQuarterFaces, 0);
      } finally {
        await database.close();
      }
    });

    test('deleting recalculates totals without stored manual totals', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final service = _service(database);

        final newRecitation = await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(
            type: RecitationType.newMemorization,
            facesQuarterAchieved: 2,
          ),
        );

        await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(type: RecitationType.revision, facesQuarterAchieved: 4),
        );

        await service.delete(halaqahId: 1, recitationId: newRecitation.id);

        final totals = await service.totalsForStudent(
          halaqahId: 1,
          studentId: 1,
        );

        expect(totals.newMemorizationQuarterFaces, 0);
        expect(totals.revisionQuarterFaces, 4);
        expect(totals.calculatedProgressQuarterFaces, 0);

        final daily = DriftDailyHalaqahRepository(database);
        final day = await daily.findDay(halaqahId: 1, dayDate: '2026-09-14');

        final records = await service.listForDayStudent(
          halaqahId: 1,
          dayId: day!.id,
          studentId: 1,
        );

        expect(records, hasLength(1));
        expect(records.single.type, RecitationType.revision);
      } finally {
        await database.close();
      }
    });

    test('edit and delete remain allowed on a closed day', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final dayId = await database
            .into(database.halaqahDays)
            .insert(
              HalaqahDaysCompanion.insert(
                halaqahId: 1,
                dayDate: '2026-09-13',
                status: 'closed',
              ),
            );

        final service = _service(database);

        final created = await service.createForDay(
          halaqahId: 1,
          dayId: dayId,
          studentId: 1,
          data: _data(facesQuarterAchieved: 1),
        );

        final updated = await service.update(
          halaqahId: 1,
          recitationId: created.id,
          data: _data(
            facesQuarterAchieved: 4,
            evaluation: RecitationEvaluation.veryGood,
          ),
        );

        expect(updated.facesQuarterAchieved, 4);

        await service.delete(halaqahId: 1, recitationId: updated.id);

        final records = await service.listForDayStudent(
          halaqahId: 1,
          dayId: dayId,
          studentId: 1,
        );

        expect(records, isEmpty);

        final day = await (database.select(
          database.halaqahDays,
        )..where((table) => table.id.equals(dayId))).getSingle();

        expect(day.status, 'closed');
      } finally {
        await database.close();
      }
    });

    test('invalid edit is rejected without changing the record', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        final service = _service(database);

        final created = await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(facesQuarterAchieved: 2),
        );

        await expectLater(
          service.update(
            halaqahId: 1,
            recitationId: created.id,
            data: _data(facesQuarterAchieved: 0),
          ),
          throwsA(isA<RecitationValidationException>()),
        );

        final stored = await DriftRecitationRepository(
          database,
        ).findById(created.id);

        expect(stored, isNotNull);
        expect(stored!.facesQuarterAchieved, 2);
      } finally {
        await database.close();
      }
    });

    test(
      'recitation activity blocks holiday conversion with full prevalidation',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(database);

          final service = _service(database);

          await service.createToday(halaqahId: 1, studentId: 1, data: _data());

          final daily = DriftDailyHalaqahRepository(database);
          final holidays = HalaqahHolidayService(daily);

          await expectLater(
            holidays.markRange(
              halaqahId: 1,
              startLocalDate: DateTime(2026, 9, 14),
              endLocalDate: DateTime(2026, 9, 15),
            ),
            throwsA(
              isA<HolidayConflictException>().having(
                (error) => error.conflictingDayDates,
                'conflictingDayDates',
                <String>['2026-09-14'],
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
          expect(days.single.read<String>('day_date'), '2026-09-14');
          expect(days.single.read<String>('status'), 'open');
        } finally {
          await database.close();
        }
      },
    );

    test('edit and delete reject recitation from another halaqah', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);
        await _insertHalaqah(database, id: 2, name: 'حلقة أخرى');

        final service = _service(database);

        final created = await service.createToday(
          halaqahId: 1,
          studentId: 1,
          data: _data(),
        );

        await expectLater(
          service.update(
            halaqahId: 2,
            recitationId: created.id,
            data: _data(facesQuarterAchieved: 3),
          ),
          throwsStateError,
        );

        await expectLater(
          service.delete(halaqahId: 2, recitationId: created.id),
          throwsStateError,
        );

        final stored = await DriftRecitationRepository(
          database,
        ).findById(created.id);

        expect(stored, isNotNull);

        final foreignTotals = await service.totalsForStudent(
          halaqahId: 2,
          studentId: 1,
        );

        expect(foreignTotals.totalRecordedQuarterFaces, 0);
      } finally {
        await database.close();
      }
    });
  });
}

RecitationService _service(AppDatabase database) {
  return RecitationService(
    repository: DriftRecitationRepository(database),
    dailyHalaqahRepository: DriftDailyHalaqahRepository(database),
    clock: const _FixedClock(),
  );
}

RecitationWriteData _data({
  RecitationType type = RecitationType.newMemorization,
  int facesQuarterAchieved = 1,
  RecitationEvaluation evaluation = RecitationEvaluation.excellent,
  int errorCount = 0,
  String? note,
}) {
  return RecitationWriteData(
    type: type,
    actualRange: const QuranRange(
      start: QuranPosition(surahNumber: 2, ayahNumber: 1),
      end: QuranPosition(surahNumber: 2, ayahNumber: 5),
    ),
    facesQuarterAchieved: facesQuarterAchieved,
    evaluation: evaluation,
    errorCount: errorCount,
    note: note,
  );
}

Future<void> _seed(AppDatabase database) async {
  await _insertHalaqah(database, id: 1, name: 'الحلقة');

  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "1, "
    "1, "
    "'أحمد', "
    "'محمد', "
    "12, "
    "'+967', "
    "'771234567', "
    "'جزء سابق', "
    "1, "
    "1"
    ");",
  );

  await database.customStatement(
    "INSERT INTO student_activity_periods "
    "(student_id, active_from_date, active_to_date) "
    "VALUES (1, '2026-09-01', NULL);",
  );
}

Future<void> _insertHalaqah(
  AppDatabase database, {
  required int id,
  required String name,
}) {
  return database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "$id, "
    "'المعلم', "
    "'$name', "
    "'المركز', "
    "'2026-09-01T10:00:00.000Z', "
    "'2026-09-01T10:00:00.000Z'"
    ");",
  );
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 14, 12);

  @override
  DateTime todayLocal() => DateTime(2026, 9, 14);
}
