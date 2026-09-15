import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/daily_halaqah/domain/daily_halaqah.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_service.dart';
import 'package:qurani/features/parent_follow_up/data/drift_parent_follow_up_repository.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';

void main() {
  group('Package 6 attendance corrections', () {
    test('attendance edit before any handled follow up '
        'updates live preview without creating correction', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(database, dailyHandled: false, attendanceStatus: 'absent');

        final service = _service(database);

        final result = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.present,
        );

        expect(result.attendance.status, AttendanceStatus.present);
        expect(result.pendingCorrection, isNull);

        final correctionCount = await _correctionCount(database);

        expect(correctionCount, 0);

        final preview = await service.previewMessage(1);

        expect(preview, contains('الحضور: حاضر'));
      } finally {
        await database.close();
      }
    });

    test('attendance change after handled creates one pending '
        'correction linked to the latest handled snapshot', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(
          database,
          dailyHandled: true,
          attendanceStatus: 'absent',
          handledAttendanceSnapshot: 'absent',
        );

        final service = _service(database);

        final result = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.present,
        );

        final correction = result.pendingCorrection;

        expect(correction, isNotNull);
        expect(correction!.isAttendanceCorrection, isTrue);
        expect(correction.isPending, isTrue);
        expect(correction.correctsFollowUpId, 1);
        expect(correction.handledSnapshot, isNull);

        expect(await _correctionCount(database), 1);
        expect(await _pendingCorrectionCount(database), 1);

        final preview = await service.previewMessage(correction.id);

        expect(preview, contains('تصحيح متابعة الحضور'));
        expect(preview, contains('الحالة السابقة: غائب'));
        expect(preview, contains('الحالة الصحيحة: حاضر'));
      } finally {
        await database.close();
      }
    });

    test('multiple attendance edits keep the same single '
        'pending correction and refresh its live preview', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(
          database,
          dailyHandled: true,
          attendanceStatus: 'absent',
          handledAttendanceSnapshot: 'absent',
        );

        final service = _service(database);

        final first = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.present,
        );

        final firstId = first.pendingCorrection!.id;

        final second = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.excusedAbsent,
        );

        expect(second.pendingCorrection, isNotNull);
        expect(second.pendingCorrection!.id, firstId);
        expect(await _pendingCorrectionCount(database), 1);

        final preview = await service.previewMessage(firstId);

        expect(preview, contains('الحالة السابقة: غائب'));
        expect(preview, contains('الحالة الصحيحة: غائب بعذر'));
      } finally {
        await database.close();
      }
    });

    test('reverting attendance to latest handled snapshot '
        'removes the pending correction', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(
          database,
          dailyHandled: true,
          attendanceStatus: 'absent',
          handledAttendanceSnapshot: 'absent',
        );

        final service = _service(database);

        final changed = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.present,
        );

        expect(changed.pendingCorrection, isNotNull);
        expect(await _pendingCorrectionCount(database), 1);

        final reverted = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.absent,
        );

        expect(reverted.pendingCorrection, isNull);
        expect(await _correctionCount(database), 0);
        expect(await _pendingCorrectionCount(database), 0);
      } finally {
        await database.close();
      }
    });

    test('after a correction is handled the next attendance '
        'change links a new correction to that handled correction', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(
          database,
          dailyHandled: true,
          attendanceStatus: 'absent',
          handledAttendanceSnapshot: 'absent',
        );

        final service = _service(database);

        final firstChange = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.present,
        );

        final firstCorrection = firstChange.pendingCorrection!;

        final payload = await service.preparePayload(
          followUpId: firstCorrection.id,
          channel: ParentFollowUpChannel.sms,
          recipient: '+967771234567',
        );

        expect(
          payload.attendanceStatus,
          ParentFollowUpAttendanceStatus.present,
        );
        expect(payload.message, contains('تصحيح متابعة الحضور'));

        final handled = await service.confirmHandled(payload);

        expect(handled.isHandled, isTrue);
        expect(
          handled.handledSnapshot!.attendanceStatus,
          ParentFollowUpAttendanceStatus.present,
        );

        expect(await _pendingCorrectionCount(database), 0);

        final secondChange = await service.setAttendanceAndReconcileCorrection(
          halaqahId: 1,
          dayId: 1,
          studentId: 1,
          status: AttendanceStatus.excusedAbsent,
        );

        final secondCorrection = secondChange.pendingCorrection!;

        expect(secondCorrection.id, isNot(firstCorrection.id));
        expect(secondCorrection.correctsFollowUpId, firstCorrection.id);

        final preview = await service.previewMessage(secondCorrection.id);

        expect(preview, contains('الحالة السابقة: حاضر'));
        expect(preview, contains('الحالة الصحيحة: غائب بعذر'));
      } finally {
        await database.close();
      }
    });

    test(
      'stale prepared correction is snapshotted exactly '
      'and a fresh pending correction is created for current attendance',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seed(
            database,
            dailyHandled: true,
            attendanceStatus: 'absent',
            handledAttendanceSnapshot: 'absent',
          );

          final service = _service(database);

          final firstChange = await service.setAttendanceAndReconcileCorrection(
            halaqahId: 1,
            dayId: 1,
            studentId: 1,
            status: AttendanceStatus.present,
          );

          final correction = firstChange.pendingCorrection!;

          final prepared = await service.preparePayload(
            followUpId: correction.id,
            channel: ParentFollowUpChannel.whatsapp,
            recipient: '+967771234567',
          );

          expect(
            prepared.attendanceStatus,
            ParentFollowUpAttendanceStatus.present,
          );
          expect(prepared.message, contains('الحالة الصحيحة: حاضر'));

          final laterChange = await service.setAttendanceAndReconcileCorrection(
            halaqahId: 1,
            dayId: 1,
            studentId: 1,
            status: AttendanceStatus.excusedAbsent,
          );

          expect(laterChange.pendingCorrection!.id, correction.id);

          final handled = await service.confirmHandled(prepared);

          expect(handled.isHandled, isTrue);
          expect(
            handled.handledSnapshot!.attendanceStatus,
            ParentFollowUpAttendanceStatus.present,
          );
          expect(handled.handledSnapshot!.message, prepared.message);

          final rows = await database
              .customSelect(
                'SELECT id, status, corrects_follow_up_id, '
                'attendance_status_snapshot '
                'FROM parent_follow_ups '
                "WHERE type = 'attendance_correction' "
                'ORDER BY id;',
              )
              .get();

          expect(rows, hasLength(2));

          expect(rows[0].read<int>('id'), correction.id);
          expect(rows[0].read<String>('status'), 'handled');
          expect(rows[0].read<String>('attendance_status_snapshot'), 'present');

          expect(rows[1].read<String>('status'), 'pending');
          expect(rows[1].read<int>('corrects_follow_up_id'), correction.id);
          expect(
            rows[1].readNullable<String>('attendance_status_snapshot'),
            isNull,
          );

          final latestPreview = await service.previewMessage(
            rows[1].read<int>('id'),
          );

          expect(latestPreview, contains('الحالة السابقة: حاضر'));
          expect(latestPreview, contains('الحالة الصحيحة: غائب بعذر'));
        } finally {
          await database.close();
        }
      },
    );

    test('recitation edits never create an attendance correction', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(
          database,
          dailyHandled: true,
          attendanceStatus: 'present',
          handledAttendanceSnapshot: 'present',
        );

        await database.customStatement(
          "INSERT INTO recitations "
          "(id, day_id, student_id, type, "
          "start_surah, start_ayah, end_surah, end_ayah, "
          "faces_quarter_achieved, evaluation, error_count, note) "
          "VALUES ("
          "1, 1, 1, 'new_memorization', "
          "112, 1, 112, 4, "
          "1, 'excellent', 0, 'قبل التعديل'"
          ");",
        );

        await database.customStatement(
          "UPDATE recitations "
          "SET note = 'بعد التعديل', "
          "faces_quarter_achieved = 2 "
          "WHERE id = 1;",
        );

        expect(await _correctionCount(database), 0);
      } finally {
        await database.close();
      }
    });

    test('holiday attendance write is rejected without correction', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seed(
          database,
          dailyHandled: false,
          attendanceStatus: 'absent',
          dayStatus: 'holiday',
          createDailyFollowUp: false,
        );

        final service = _service(database);

        await expectLater(
          service.setAttendanceAndReconcileCorrection(
            halaqahId: 1,
            dayId: 1,
            studentId: 1,
            status: AttendanceStatus.present,
          ),
          throwsStateError,
        );

        final attendance = await database
            .customSelect(
              'SELECT status FROM attendance_records '
              'WHERE day_id = 1 AND student_id = 1;',
            )
            .getSingle();

        expect(attendance.read<String>('status'), 'absent');
        expect(await _correctionCount(database), 0);
      } finally {
        await database.close();
      }
    });
  });
}

ParentFollowUpService _service(AppDatabase database) {
  return ParentFollowUpService(
    repository: DriftParentFollowUpRepository(database),
  );
}

Future<int> _correctionCount(AppDatabase database) async {
  final row = await database
      .customSelect(
        'SELECT COUNT(*) AS total '
        'FROM parent_follow_ups '
        "WHERE type = 'attendance_correction';",
      )
      .getSingle();

  return row.read<int>('total');
}

Future<int> _pendingCorrectionCount(AppDatabase database) async {
  final row = await database
      .customSelect(
        'SELECT COUNT(*) AS total '
        'FROM parent_follow_ups '
        "WHERE type = 'attendance_correction' "
        "AND status = 'pending';",
      )
      .getSingle();

  return row.read<int>('total');
}

Future<void> _seed(
  AppDatabase database, {
  required bool dailyHandled,
  required String attendanceStatus,
  String handledAttendanceSnapshot = 'absent',
  String dayStatus = 'closed',
  bool createDailyFollowUp = true,
}) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'حلقة ذي النورين', 'المركز الرئيسي', "
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
    "INSERT INTO student_activity_periods "
    "(student_id, active_from_date, active_to_date) "
    "VALUES (1, '2026-09-01', NULL);",
  );

  await database.customStatement(
    'INSERT INTO halaqah_days '
    '(id, halaqah_id, day_date, status) '
    "VALUES (1, 1, '2026-09-15', '$dayStatus');",
  );

  await database.customStatement(
    'INSERT INTO attendance_records '
    '(day_id, student_id, status) '
    "VALUES (1, 1, '$attendanceStatus');",
  );

  if (!createDailyFollowUp) {
    return;
  }

  if (dailyHandled) {
    await database.customStatement(
      "INSERT INTO parent_follow_ups "
      "(id, day_id, student_id, type, status, "
      "attendance_status_snapshot, snapshot_message, "
      "channel_snapshot, recipient_snapshot) "
      "VALUES ("
      "1, 1, 1, 'daily', 'handled', "
      "'$handledAttendanceSnapshot', "
      "'الرسالة اليومية المعالجة', "
      "'whatsapp', '+967771234567'"
      ");",
    );
  } else {
    await database.customStatement(
      "INSERT INTO parent_follow_ups "
      "(id, day_id, student_id, type, status) "
      "VALUES (1, 1, 1, 'daily', 'pending');",
    );
  }
}
