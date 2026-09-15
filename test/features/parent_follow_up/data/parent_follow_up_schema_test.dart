import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';

void main() {
  group('Package 6 parent follow up schema', () {
    test('supports one daily follow up per day and student', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        await database.customStatement(
          "INSERT INTO parent_follow_ups "
          "(day_id, student_id, type, status) "
          "VALUES (1, 1, 'daily', 'pending');",
        );

        await expectLater(
          database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(day_id, student_id, type, status) "
            "VALUES (1, 1, 'daily', 'pending');",
          ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test(
      'supports only one pending attendance correction per day and student',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(database);

          await database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(id, day_id, student_id, type, status, "
            "attendance_status_snapshot, snapshot_message, "
            "channel_snapshot, recipient_snapshot) "
            "VALUES ("
            "1, 1, 1, 'daily', 'handled', "
            "'present', 'الرسالة الأصلية', 'sms', '+967771234567'"
            ");",
          );

          await database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(day_id, student_id, type, status, corrects_follow_up_id) "
            "VALUES ("
            "1, 1, 'attendance_correction', 'pending', 1"
            ");",
          );

          await expectLater(
            database.customStatement(
              "INSERT INTO parent_follow_ups "
              "(day_id, student_id, type, status, corrects_follow_up_id) "
              "VALUES ("
              "1, 1, 'attendance_correction', 'pending', 1"
              ");",
            ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'allows a new pending correction after the earlier correction is handled',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(database);

          await database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(id, day_id, student_id, type, status, "
            "attendance_status_snapshot, snapshot_message, "
            "channel_snapshot, recipient_snapshot) "
            "VALUES ("
            "1, 1, 1, 'daily', 'handled', "
            "'present', 'الأصل', 'whatsapp', '+967771234567'"
            ");",
          );

          await database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(id, day_id, student_id, type, status, "
            "corrects_follow_up_id, attendance_status_snapshot, "
            "snapshot_message, channel_snapshot, recipient_snapshot) "
            "VALUES ("
            "2, 1, 1, 'attendance_correction', 'handled', "
            "1, 'absent', 'التصحيح الأول', "
            "'whatsapp', '+967771234567'"
            ");",
          );

          await database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(day_id, student_id, type, status, corrects_follow_up_id) "
            "VALUES ("
            "1, 1, 'attendance_correction', 'pending', 2"
            ");",
          );

          final rows = await database
              .customSelect(
                "SELECT id FROM parent_follow_ups "
                "WHERE type = 'attendance_correction' "
                "AND status = 'pending';",
              )
              .get();

          expect(rows, hasLength(1));
        } finally {
          await database.close();
        }
      },
    );

    test('pending rows cannot contain handled snapshots', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        await expectLater(
          database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(day_id, student_id, type, status, snapshot_message) "
            "VALUES ("
            "1, 1, 'daily', 'pending', 'لا تحفظ الآن'"
            ");",
          ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('handled rows require the exact payload snapshot fields', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        await expectLater(
          database.customStatement(
            "INSERT INTO parent_follow_ups "
            "(day_id, student_id, type, status) "
            "VALUES (1, 1, 'daily', 'handled');",
          ),
          throwsA(anything),
        );

        await database.customStatement(
          "INSERT INTO parent_follow_ups "
          "(day_id, student_id, type, status, "
          "attendance_status_snapshot, snapshot_message, "
          "channel_snapshot, recipient_snapshot) "
          "VALUES ("
          "1, 1, 'daily', 'handled', "
          "'absent', 'رسالة محفوظة', "
          "'whatsapp', '+967771234567'"
          ");",
        );

        final row = await database
            .customSelect(
              "SELECT status, attendance_status_snapshot, "
              "snapshot_message, channel_snapshot, recipient_snapshot "
              "FROM parent_follow_ups;",
            )
            .getSingle();

        expect(row.read<String>('status'), 'handled');
        expect(row.read<String>('attendance_status_snapshot'), 'absent');
        expect(row.read<String>('snapshot_message'), 'رسالة محفوظة');
        expect(row.read<String>('channel_snapshot'), 'whatsapp');
        expect(row.read<String>('recipient_snapshot'), '+967771234567');
      } finally {
        await database.close();
      }
    });

    test('Yemen recipient snapshot supports sms or whatsapp', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);
        await _seedSecondStudentAndDay(database);

        await database.customStatement(
          "INSERT INTO parent_follow_ups "
          "(day_id, student_id, type, status, "
          "attendance_status_snapshot, snapshot_message, "
          "channel_snapshot, recipient_snapshot) "
          "VALUES ("
          "1, 1, 'daily', 'handled', "
          "'present', 'رسالة SMS', 'sms', '+967771234567'"
          ");",
        );

        await database.customStatement(
          "INSERT INTO parent_follow_ups "
          "(day_id, student_id, type, status, "
          "attendance_status_snapshot, snapshot_message, "
          "channel_snapshot, recipient_snapshot) "
          "VALUES ("
          "2, 2, 'daily', 'handled', "
          "'present', 'رسالة واتساب', "
          "'whatsapp', '+967731234567'"
          ");",
        );

        final channels = await database
            .customSelect(
              "SELECT channel_snapshot "
              "FROM parent_follow_ups "
              "ORDER BY id;",
            )
            .get();

        expect(
          channels.map((row) => row.read<String>('channel_snapshot')).toList(),
          <String>['sms', 'whatsapp'],
        );
      } finally {
        await database.close();
      }
    });

    test('Saudi recipient snapshot supports whatsapp', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database);

        await database.customStatement(
          "INSERT INTO parent_follow_ups "
          "(day_id, student_id, type, status, "
          "attendance_status_snapshot, snapshot_message, "
          "channel_snapshot, recipient_snapshot) "
          "VALUES ("
          "1, 1, 'daily', 'handled', "
          "'present', 'رسالة واتساب', "
          "'whatsapp', '+966512345678'"
          ");",
        );

        final row = await database
            .customSelect(
              "SELECT channel_snapshot, recipient_snapshot "
              "FROM parent_follow_ups;",
            )
            .getSingle();

        expect(row.read<String>('channel_snapshot'), 'whatsapp');
        expect(row.read<String>('recipient_snapshot'), '+966512345678');
      } finally {
        await database.close();
      }
    });

    test(
      'attendance correction requires a valid corrected follow up',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(database);

          await expectLater(
            database.customStatement(
              "INSERT INTO parent_follow_ups "
              "(day_id, student_id, type, status, corrects_follow_up_id) "
              "VALUES ("
              "1, 1, 'attendance_correction', 'pending', 999"
              ");",
            ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'rejects unsupported type status channel and attendance tokens',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(database);

          for (final sql in <String>[
            "INSERT INTO parent_follow_ups "
                "(day_id, student_id, type, status) "
                "VALUES (1, 1, 'other', 'pending');",
            "INSERT INTO parent_follow_ups "
                "(day_id, student_id, type, status) "
                "VALUES (1, 1, 'daily', 'sent');",
            "INSERT INTO parent_follow_ups "
                "(day_id, student_id, type, status, "
                "attendance_status_snapshot, snapshot_message, "
                "channel_snapshot, recipient_snapshot) "
                "VALUES ("
                "1, 1, 'daily', 'handled', "
                "'present', 'رسالة', 'email', '+967771234567'"
                ");",
            "INSERT INTO parent_follow_ups "
                "(day_id, student_id, type, status, "
                "attendance_status_snapshot, snapshot_message, "
                "channel_snapshot, recipient_snapshot) "
                "VALUES ("
                "1, 1, 'daily', 'handled', "
                "'late', 'رسالة', 'sms', '+967771234567'"
                ");",
          ]) {
            await expectLater(database.customStatement(sql), throwsA(anything));
          }
        } finally {
          await database.close();
        }
      },
    );
  });
}

Future<void> _seed(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'الحلقة', 'المركز', "
    "'2026-09-15T10:00:00.000Z', "
    "'2026-09-15T10:00:00.000Z'"
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
    "INSERT INTO halaqah_days "
    "(id, halaqah_id, day_date, status) "
    "VALUES (1, 1, '2026-09-15', 'closed');",
  );
}

Future<void> _seedSecondStudentAndDay(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "2, 1, 'خالد', 'علي', 11, '+967', "
    "'731234567', 'جزء سابق', 2, 1"
    ");",
  );

  await database.customStatement(
    "INSERT INTO halaqah_days "
    "(id, halaqah_id, day_date, status) "
    "VALUES (2, 1, '2026-09-16', 'closed');",
  );
}
