import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';

void main() {
  group('Package 4 halaqah day and attendance schema', () {
    test('persists approved halaqah day states', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedStudent(database);

        for (final entry in <String, String>{
          '2026-09-14': 'open',
          '2026-09-15': 'closed',
          '2026-09-16': 'holiday',
        }.entries) {
          await database.customStatement(
            "INSERT INTO halaqah_days "
            "(halaqah_id, day_date, status) "
            "VALUES (1, '${entry.key}', '${entry.value}');",
          );
        }

        final rows = await database
            .customSelect(
              'SELECT day_date, status '
              'FROM halaqah_days '
              'ORDER BY day_date;',
            )
            .get();

        expect(rows.map((row) => row.read<String>('status')).toList(), <String>[
          'open',
          'closed',
          'holiday',
        ]);
      } finally {
        await database.close();
      }
    });

    test('keeps one halaqah day per halaqah and local date', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedStudent(database);

        await database.customStatement(
          "INSERT INTO halaqah_days "
          "(halaqah_id, day_date, status) "
          "VALUES (1, '2026-09-14', 'open');",
        );

        await expectLater(
          database.customStatement(
            "INSERT INTO halaqah_days "
            "(halaqah_id, day_date, status) "
            "VALUES (1, '2026-09-14', 'closed');",
          ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('rejects unsupported halaqah day status', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedStudent(database);

        await expectLater(
          database.customStatement(
            "INSERT INTO halaqah_days "
            "(halaqah_id, day_date, status) "
            "VALUES (1, '2026-09-14', 'cancelled');",
          ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test(
      'persists only present absent and excused_absent attendance states',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedStudent(database);

          final statuses = <String>['present', 'absent', 'excused_absent'];

          for (var index = 0; index < statuses.length; index++) {
            final date = '2026-09-${(14 + index).toString().padLeft(2, '0')}';

            await database.customStatement(
              "INSERT INTO halaqah_days "
              "(halaqah_id, day_date, status) "
              "VALUES (1, '$date', 'open');",
            );

            final dayRows = await database
                .customSelect(
                  "SELECT id FROM halaqah_days WHERE day_date = '$date';",
                )
                .get();

            final dayId = dayRows.single.read<int>('id');

            await database.customStatement(
              "INSERT INTO attendance_records "
              "(day_id, student_id, status) "
              "VALUES ($dayId, 1, '${statuses[index]}');",
            );
          }

          final rows = await database
              .customSelect(
                'SELECT status FROM attendance_records ORDER BY id;',
              )
              .get();

          expect(
            rows.map((row) => row.read<String>('status')).toList(),
            statuses,
          );
        } finally {
          await database.close();
        }
      },
    );

    test('keeps one attendance row per day and student', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedStudent(database);

        await database.customStatement(
          "INSERT INTO halaqah_days "
          "(halaqah_id, day_date, status) "
          "VALUES (1, '2026-09-14', 'open');",
        );

        await database.customStatement(
          "INSERT INTO attendance_records "
          "(day_id, student_id, status) "
          "VALUES (1, 1, 'present');",
        );

        await expectLater(
          database.customStatement(
            "INSERT INTO attendance_records "
            "(day_id, student_id, status) "
            "VALUES (1, 1, 'absent');",
          ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('rejects unsupported attendance states', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedStudent(database);

        await database.customStatement(
          "INSERT INTO halaqah_days "
          "(halaqah_id, day_date, status) "
          "VALUES (1, '2026-09-14', 'open');",
        );

        await expectLater(
          database.customStatement(
            "INSERT INTO attendance_records "
            "(day_id, student_id, status) "
            "VALUES (1, 1, 'late');",
          ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });
  });
}

Future<void> _seedStudent(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "'Teacher', "
    "'Halaqah', "
    "'Center', "
    "'2026-09-14T10:00:00.000Z', "
    "'2026-09-14T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO students "
    "(halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "1, "
    "'Student', "
    "'Father', "
    "10, "
    "'+967', "
    "'771234567', "
    "'Juz Amma', "
    "1, "
    "1"
    ");",
  );
}
