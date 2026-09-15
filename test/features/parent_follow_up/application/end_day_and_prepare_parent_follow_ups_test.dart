import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/parent_follow_up/application/end_day_and_prepare_parent_follow_ups.dart';
import 'package:qurani/features/parent_follow_up/data/drift_parent_follow_up_repository.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_repository.dart';

void main() {
  group('Package 6 atomic end day and daily follow ups', () {
    test('closes the day and creates one pending daily follow up '
        'for every historical active student', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedBase(database);
        await _insertAttendance(database, studentId: 1, status: 'present');
        await _insertAttendance(database, studentId: 2, status: 'absent');

        final repository = DriftParentFollowUpRepository(database);
        final service = EndDayAndPrepareParentFollowUps(repository: repository);

        final result = await service(halaqahId: 1, dayId: 1);

        expect(result.day.isClosed, isTrue);
        expect(result.followUps, hasLength(2));

        expect(
          result.followUps.every(
            (followUp) =>
                followUp.type == ParentFollowUpType.daily &&
                followUp.status == ParentFollowUpStatus.pending &&
                followUp.handledSnapshot == null &&
                followUp.correctsFollowUpId == null,
          ),
          isTrue,
        );

        final day = await database
            .customSelect('SELECT status FROM halaqah_days WHERE id = 1;')
            .getSingle();

        expect(day.read<String>('status'), 'closed');

        final followUps = await database
            .customSelect(
              'SELECT student_id, type, status, '
              'attendance_status_snapshot, snapshot_message, '
              'channel_snapshot, recipient_snapshot '
              'FROM parent_follow_ups '
              'ORDER BY student_id;',
            )
            .get();

        expect(followUps, hasLength(2));

        for (final row in followUps) {
          expect(row.read<String>('type'), 'daily');
          expect(row.read<String>('status'), 'pending');
          expect(
            row.readNullable<String>('attendance_status_snapshot'),
            isNull,
          );
          expect(row.readNullable<String>('snapshot_message'), isNull);
          expect(row.readNullable<String>('channel_snapshot'), isNull);
          expect(row.readNullable<String>('recipient_snapshot'), isNull);
        }
      } finally {
        await database.close();
      }
    });

    test('operation is idempotent and never duplicates daily rows', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedBase(database);
        await _insertAttendance(database, studentId: 1, status: 'present');
        await _insertAttendance(
          database,
          studentId: 2,
          status: 'excused_absent',
        );

        final repository = DriftParentFollowUpRepository(database);
        final service = EndDayAndPrepareParentFollowUps(repository: repository);

        final first = await service(halaqahId: 1, dayId: 1);

        final second = await service(halaqahId: 1, dayId: 1);

        expect(first.day.isClosed, isTrue);
        expect(second.day.isClosed, isTrue);

        expect(
          second.followUps.map((item) => item.id).toList(),
          first.followUps.map((item) => item.id).toList(),
        );

        final count = await database
            .customSelect(
              'SELECT COUNT(*) AS total '
              'FROM parent_follow_ups '
              "WHERE day_id = 1 AND type = 'daily';",
            )
            .getSingle();

        expect(count.read<int>('total'), 2);
      } finally {
        await database.close();
      }
    });

    test(
      'missing attendance rolls back without closing or creating follow ups',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedBase(database);

          await _insertAttendance(database, studentId: 1, status: 'present');

          final repository = DriftParentFollowUpRepository(database);
          final service = EndDayAndPrepareParentFollowUps(
            repository: repository,
          );

          Object? capturedError;

          try {
            await service(halaqahId: 1, dayId: 1);
          } catch (error) {
            capturedError = error;
          }

          expect(
            capturedError,
            isA<ParentFollowUpIncompleteAttendanceException>(),
          );

          final attendanceError =
              capturedError as ParentFollowUpIncompleteAttendanceException;

          expect(attendanceError.missingStudentIds, <int>[2]);

          final day = await database
              .customSelect('SELECT status FROM halaqah_days WHERE id = 1;')
              .getSingle();

          expect(day.read<String>('status'), 'open');

          final count = await database
              .customSelect('SELECT COUNT(*) AS total FROM parent_follow_ups;')
              .getSingle();

          expect(count.read<int>('total'), 0);
        } finally {
          await database.close();
        }
      },
    );

    test('holiday never creates parent follow ups', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedBase(database, dayStatus: 'holiday');

        final repository = DriftParentFollowUpRepository(database);
        final service = EndDayAndPrepareParentFollowUps(repository: repository);

        await expectLater(service(halaqahId: 1, dayId: 1), throwsStateError);

        final day = await database
            .customSelect('SELECT status FROM halaqah_days WHERE id = 1;')
            .getSingle();

        expect(day.read<String>('status'), 'holiday');

        final count = await database
            .customSelect('SELECT COUNT(*) AS total FROM parent_follow_ups;')
            .getSingle();

        expect(count.read<int>('total'), 0);
      } finally {
        await database.close();
      }
    });

    test('database failure during follow up creation rolls back '
        'the day close and every earlier insert', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedBase(database);

        await _insertAttendance(database, studentId: 1, status: 'present');
        await _insertAttendance(database, studentId: 2, status: 'present');

        await database.customStatement('''
CREATE TRIGGER fail_second_parent_follow_up
BEFORE INSERT ON parent_follow_ups
WHEN NEW.student_id = 2
BEGIN
  SELECT RAISE(ABORT, 'forced parent follow up failure');
END;
''');

        final repository = DriftParentFollowUpRepository(database);
        final service = EndDayAndPrepareParentFollowUps(repository: repository);

        await expectLater(service(halaqahId: 1, dayId: 1), throwsA(anything));

        final day = await database
            .customSelect('SELECT status FROM halaqah_days WHERE id = 1;')
            .getSingle();

        expect(
          day.read<String>('status'),
          'open',
          reason: 'Day close must roll back when any follow up insert fails.',
        );

        final count = await database
            .customSelect('SELECT COUNT(*) AS total FROM parent_follow_ups;')
            .getSingle();

        expect(
          count.read<int>('total'),
          0,
          reason: 'Earlier follow up inserts must roll back too.',
        );
      } finally {
        await database.close();
      }
    });

    test('a historically inactive student is not included '
        'in the day follow ups', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedBase(database);

        await database.customStatement(
          "UPDATE student_activity_periods "
          "SET active_to_date = '2026-09-14' "
          "WHERE student_id = 2;",
        );

        await _insertAttendance(database, studentId: 1, status: 'present');

        final repository = DriftParentFollowUpRepository(database);
        final service = EndDayAndPrepareParentFollowUps(repository: repository);

        final result = await service(halaqahId: 1, dayId: 1);

        expect(result.followUps, hasLength(1));
        expect(result.followUps.single.studentId, 1);
        expect(result.day.isClosed, isTrue);
      } finally {
        await database.close();
      }
    });
  });
}

Future<void> _seedBase(
  AppDatabase database, {
  String dayStatus = 'open',
}) async {
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

  await _insertStudent(database, id: 1, name: 'أحمد', displayOrder: 1);

  await _insertStudent(database, id: 2, name: 'خالد', displayOrder: 2);

  await database.customStatement(
    "INSERT INTO student_activity_periods "
    "(student_id, active_from_date, active_to_date) "
    "VALUES (1, '2026-09-01', NULL);",
  );

  await database.customStatement(
    "INSERT INTO student_activity_periods "
    "(student_id, active_from_date, active_to_date) "
    "VALUES (2, '2026-09-01', NULL);",
  );

  await database.customStatement(
    'INSERT INTO halaqah_days '
    '(id, halaqah_id, day_date, status) '
    "VALUES (1, 1, '2026-09-15', '$dayStatus');",
  );
}

Future<void> _insertStudent(
  AppDatabase database, {
  required int id,
  required String name,
  required int displayOrder,
}) {
  return database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "$id, 1, '$name', 'ولي الأمر', 12, '+967', "
    "'77123456$id', 'جزء سابق', $displayOrder, 1"
    ");",
  );
}

Future<void> _insertAttendance(
  AppDatabase database, {
  required int studentId,
  required String status,
}) {
  return database.customStatement(
    'INSERT INTO attendance_records '
    '(day_id, student_id, status) '
    "VALUES (1, $studentId, '$status');",
  );
}
