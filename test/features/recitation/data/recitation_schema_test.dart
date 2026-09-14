import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';

void main() {
  group('Package 5 recitation schema', () {
    test(
      'allows multiple independent recitations for one day and student',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final seed = await _seedParents(database);

          await _insertRecitation(database, seed);
          await _insertRecitation(database, seed);

          final countRows = await database
              .customSelect(
                'SELECT COUNT(*) AS row_count '
                'FROM recitations '
                'WHERE day_id = ${seed.dayId} '
                'AND student_id = ${seed.studentId};',
              )
              .get();

          expect(countRows.single.read<int>('row_count'), 2);
        } finally {
          await database.close();
        }
      },
    );

    test('persists both approved recitation types', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seedParents(database);

        await _insertRecitation(database, seed, type: 'new_memorization');

        await _insertRecitation(database, seed, type: 'revision');

        final rows = await database
            .customSelect('SELECT type FROM recitations ORDER BY id;')
            .get();

        expect(rows.map((row) => row.read<String>('type')).toList(), <String>[
          'new_memorization',
          'revision',
        ]);
      } finally {
        await database.close();
      }
    });

    test('rejects unsupported recitation type', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seedParents(database);

        await expectLater(
          _insertRecitation(database, seed, type: 'unsupported'),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('requires positive quarter-face achievement', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seedParents(database);

        await expectLater(
          _insertRecitation(database, seed, facesQuarterAchieved: 0),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('accepts only the six canonical evaluation storage values', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seedParents(database);

        const values = <String>[
          'talqin',
          'excellent',
          'very_good',
          'good',
          'acceptable',
          'weak',
        ];

        for (final value in values) {
          await _insertRecitation(database, seed, evaluation: value);
        }

        await expectLater(
          _insertRecitation(database, seed, evaluation: 'unsupported'),
          throwsA(anything),
        );

        final rows = await database
            .customSelect('SELECT evaluation FROM recitations ORDER BY id;')
            .get();

        expect(
          rows.map((row) => row.read<String>('evaluation')).toList(),
          values,
        );
      } finally {
        await database.close();
      }
    });

    test('error count defaults to zero and rejects negative values', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seedParents(database);

        await database.customStatement('''
INSERT INTO recitations (
  day_id,
  student_id,
  type,
  start_surah,
  start_ayah,
  end_surah,
  end_ayah,
  faces_quarter_achieved,
  evaluation
) VALUES (
  ${seed.dayId},
  ${seed.studentId},
  'new_memorization',
  2,
  1,
  2,
  5,
  1,
  'excellent'
);
''');

        final row = await database
            .customSelect(
              'SELECT error_count FROM recitations ORDER BY id LIMIT 1;',
            )
            .getSingle();

        expect(row.read<int>('error_count'), 0);

        await expectLater(
          _insertRecitation(database, seed, errorCount: -1),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('planned range is either fully absent or fully present', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seedParents(database);

        await _insertRecitation(database, seed);

        await _insertRecitation(
          database,
          seed,
          plannedStartSurah: 2,
          plannedStartAyah: 20,
          plannedEndSurah: 3,
          plannedEndAyah: 5,
        );

        await expectLater(
          _insertRecitation(database, seed, plannedStartSurah: 2),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('enforces structural Quran position boundaries', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seedParents(database);

        await expectLater(
          _insertRecitation(database, seed, startSurah: 0),
          throwsA(anything),
        );

        await expectLater(
          _insertRecitation(database, seed, startAyah: 0),
          throwsA(anything),
        );

        await expectLater(
          _insertRecitation(database, seed, endSurah: 115),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });
  });
}

Future<_Seed> _seedParents(AppDatabase database) async {
  final now = DateTime.utc(2026, 9, 14, 12);

  final halaqahId = await database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: 'المعلم',
          halaqahName: 'الحلقة',
          centerName: 'المركز',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

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
        ),
      );

  final dayId = await database
      .into(database.halaqahDays)
      .insert(
        HalaqahDaysCompanion.insert(
          halaqahId: halaqahId,
          dayDate: '2026-09-14',
          status: 'open',
        ),
      );

  return _Seed(dayId: dayId, studentId: studentId);
}

Future<void> _insertRecitation(
  AppDatabase database,
  _Seed seed, {
  String type = 'new_memorization',
  int startSurah = 2,
  int startAyah = 1,
  int endSurah = 2,
  int endAyah = 5,
  int facesQuarterAchieved = 1,
  String evaluation = 'excellent',
  int errorCount = 0,
  int? plannedStartSurah,
  int? plannedStartAyah,
  int? plannedEndSurah,
  int? plannedEndAyah,
}) {
  String sqlValue(int? value) {
    return value == null ? 'NULL' : value.toString();
  }

  return database.customStatement('''
INSERT INTO recitations (
  day_id,
  student_id,
  type,
  start_surah,
  start_ayah,
  end_surah,
  end_ayah,
  faces_quarter_achieved,
  evaluation,
  error_count,
  planned_start_surah,
  planned_start_ayah,
  planned_end_surah,
  planned_end_ayah
) VALUES (
  ${seed.dayId},
  ${seed.studentId},
  '$type',
  $startSurah,
  $startAyah,
  $endSurah,
  $endAyah,
  $facesQuarterAchieved,
  '$evaluation',
  $errorCount,
  ${sqlValue(plannedStartSurah)},
  ${sqlValue(plannedStartAyah)},
  ${sqlValue(plannedEndSurah)},
  ${sqlValue(plannedEndAyah)}
);
''');
}

final class _Seed {
  const _Seed({required this.dayId, required this.studentId});

  final int dayId;
  final int studentId;
}
