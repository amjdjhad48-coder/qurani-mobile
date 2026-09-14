import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/reference/quran_reference_data.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/recitation/application/recitation_service.dart';
import 'package:qurani/features/recitation/data/drift_recitation_repository.dart';
import 'package:qurani/features/recitation/domain/recitation.dart';

void main() {
  group('Package 5 recitation create and day rules', () {
    test('creates today implicitly before explicit day start', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seed(database, activeFromDate: '2026-09-01');

        final service = _service(database);

        final before = await _dayRows(database);
        expect(before, isEmpty);

        final created = await service.createToday(
          halaqahId: seed.halaqahId,
          studentId: seed.studentId,
          data: _data(),
        );

        final days = await _dayRows(database);

        expect(days, hasLength(1));
        expect(days.single.dayDate, '2026-09-14');
        expect(days.single.status, 'open');
        expect(created.dayId, days.single.id);
      } finally {
        await database.close();
      }
    });

    test('allows multiple recitations for one student on one day', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seed(database, activeFromDate: '2026-09-01');

        final service = _service(database);

        await service.createToday(
          halaqahId: seed.halaqahId,
          studentId: seed.studentId,
          data: _data(
            type: RecitationType.newMemorization,
            facesQuarterAchieved: 2,
          ),
        );

        await service.createToday(
          halaqahId: seed.halaqahId,
          studentId: seed.studentId,
          data: _data(
            type: RecitationType.revision,
            actualRange: _range(3, 1, 3, 10),
            facesQuarterAchieved: 4,
          ),
        );

        final day = (await _dayRows(database)).single;

        final records = await service.listForDayStudent(
          halaqahId: seed.halaqahId,
          dayId: day.id,
          studentId: seed.studentId,
        );

        expect(records, hasLength(2));
        expect(records[0].type, RecitationType.newMemorization);
        expect(records[1].type, RecitationType.revision);
        expect(records[0].facesQuarterAchieved, 2);
        expect(records[1].facesQuarterAchieved, 4);
      } finally {
        await database.close();
      }
    });

    test('allows recitation after the halaqah day is closed', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seed(database, activeFromDate: '2026-09-01');

        final dayId = await database
            .into(database.halaqahDays)
            .insert(
              HalaqahDaysCompanion.insert(
                halaqahId: seed.halaqahId,
                dayDate: '2026-09-14',
                status: 'closed',
              ),
            );

        final service = _service(database);

        final created = await service.createToday(
          halaqahId: seed.halaqahId,
          studentId: seed.studentId,
          data: _data(),
        );

        expect(created.dayId, dayId);

        final day = await (database.select(
          database.halaqahDays,
        )..where((table) => table.id.equals(dayId))).getSingle();

        expect(day.status, 'closed');
      } finally {
        await database.close();
      }
    });

    test('blocks recitation on a holiday day', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seed(database, activeFromDate: '2026-09-01');

        await database
            .into(database.halaqahDays)
            .insert(
              HalaqahDaysCompanion.insert(
                halaqahId: seed.halaqahId,
                dayDate: '2026-09-14',
                status: 'holiday',
              ),
            );

        final service = _service(database);

        await expectLater(
          service.createToday(
            halaqahId: seed.halaqahId,
            studentId: seed.studentId,
            data: _data(),
          ),
          throwsA(isA<RecitationOnHolidayException>()),
        );

        final recitations = await database.select(database.recitations).get();
        expect(recitations, isEmpty);
      } finally {
        await database.close();
      }
    });

    test(
      'historical activity periods decide student eligibility instead of current isActive',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final seed = await _seed(
            database,
            activeFromDate: '2026-09-01',
            activeToDate: '2026-09-14',
            studentIsActive: false,
          );

          final service = _service(database);

          final created = await service.createToday(
            halaqahId: seed.halaqahId,
            studentId: seed.studentId,
            data: _data(),
          );

          expect(created.studentId, seed.studentId);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'ineligible student failure does not create an implicit day',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final seed = await _seed(database, activeFromDate: '2026-09-15');

          final service = _service(database);

          await expectLater(
            service.createToday(
              halaqahId: seed.halaqahId,
              studentId: seed.studentId,
              data: _data(),
            ),
            throwsStateError,
          );

          expect(await _dayRows(database), isEmpty);
          expect(await database.select(database.recitations).get(), isEmpty);
        } finally {
          await database.close();
        }
      },
    );

    test('repository round-trips note and optional planned range', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seed(database, activeFromDate: '2026-09-01');

        final service = _service(database);

        final created = await service.createToday(
          halaqahId: seed.halaqahId,
          studentId: seed.studentId,
          data: _data(
            actualRange: _range(2, 280, 3, 2),
            facesQuarterAchieved: 5,
            evaluation: RecitationEvaluation.veryGood,
            errorCount: 3,
            note: '  يحتاج متابعة  ',
            plannedRange: _range(3, 3, 3, 20),
          ),
        );

        expect(created.actualRange.start.surahNumber, 2);
        expect(created.actualRange.start.ayahNumber, 280);
        expect(created.actualRange.end.surahNumber, 3);
        expect(created.actualRange.end.ayahNumber, 2);
        expect(created.facesQuarterAchieved, 5);
        expect(created.evaluation, RecitationEvaluation.veryGood);
        expect(created.errorCount, 3);
        expect(created.note, 'يحتاج متابعة');

        expect(created.plannedRange, isNotNull);
        expect(created.plannedRange!.start.surahNumber, 3);
        expect(created.plannedRange!.start.ayahNumber, 3);
        expect(created.plannedRange!.end.surahNumber, 3);
        expect(created.plannedRange!.end.ayahNumber, 20);
      } finally {
        await database.close();
      }
    });

    test('createForDay rejects a day belonging to another halaqah', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final first = await _seed(database, activeFromDate: '2026-09-01');

        final otherHalaqahId = await _insertHalaqah(
          database,
          name: 'حلقة أخرى',
        );

        final foreignDayId = await database
            .into(database.halaqahDays)
            .insert(
              HalaqahDaysCompanion.insert(
                halaqahId: otherHalaqahId,
                dayDate: '2026-09-14',
                status: 'open',
              ),
            );

        final service = _service(database);

        await expectLater(
          service.createForDay(
            halaqahId: first.halaqahId,
            dayId: foreignDayId,
            studentId: first.studentId,
            data: _data(),
          ),
          throwsStateError,
        );

        expect(await database.select(database.recitations).get(), isEmpty);
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
  QuranRange? actualRange,
  int facesQuarterAchieved = 1,
  RecitationEvaluation evaluation = RecitationEvaluation.excellent,
  int errorCount = 0,
  String? note,
  QuranRange? plannedRange,
}) {
  return RecitationWriteData(
    type: type,
    actualRange: actualRange ?? _range(2, 1, 2, 5),
    facesQuarterAchieved: facesQuarterAchieved,
    evaluation: evaluation,
    errorCount: errorCount,
    note: note,
    plannedRange: plannedRange,
  );
}

QuranRange _range(int startSurah, int startAyah, int endSurah, int endAyah) {
  return QuranRange(
    start: QuranPosition(surahNumber: startSurah, ayahNumber: startAyah),
    end: QuranPosition(surahNumber: endSurah, ayahNumber: endAyah),
  );
}

Future<_Seed> _seed(
  AppDatabase database, {
  required String activeFromDate,
  String? activeToDate,
  bool studentIsActive = true,
}) async {
  final halaqahId = await _insertHalaqah(database, name: 'الحلقة');

  final studentId = await database
      .into(database.students)
      .insert(
        StudentsCompanion.insert(
          halaqahId: halaqahId,
          studentName: 'أحمد',
          fatherName: 'محمد',
          ageYears: 12,
          guardianCountryCode: '+967',
          guardianNationalNumber: '771234567',
          previousMemorizationText: 'جزء سابق',
          displayOrder: 1,
          isActive: Value<bool>(studentIsActive),
        ),
      );

  await database
      .into(database.studentActivityPeriods)
      .insert(
        StudentActivityPeriodsCompanion.insert(
          studentId: studentId,
          activeFromDate: activeFromDate,
          activeToDate: Value<String?>(activeToDate),
        ),
      );

  return _Seed(halaqahId: halaqahId, studentId: studentId);
}

Future<int> _insertHalaqah(AppDatabase database, {required String name}) {
  final now = DateTime.utc(2026, 9, 14, 12);

  return database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: 'المعلم',
          halaqahName: name,
          centerName: 'المركز',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
}

Future<List<HalaqahDay>> _dayRows(AppDatabase database) {
  return database.select(database.halaqahDays).get();
}

final class _Seed {
  const _Seed({required this.halaqahId, required this.studentId});

  final int halaqahId;
  final int studentId;
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 14, 12);

  @override
  DateTime todayLocal() => DateTime(2026, 9, 14);
}
