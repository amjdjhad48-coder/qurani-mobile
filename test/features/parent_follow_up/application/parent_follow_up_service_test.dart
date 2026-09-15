import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_service.dart';
import 'package:qurani/features/parent_follow_up/data/drift_parent_follow_up_repository.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';

void main() {
  group('Package 6 pending handled exact snapshots', () {
    test('pending preview is rebuilt from current attendance '
        'and recitation data without storing snapshots', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final service = _service(database);

        final first = await service.previewMessage(1);

        expect(first, contains('الحضور: غائب'));
        expect(first, contains('ملاحظة أولى'));

        await database.customStatement(
          "UPDATE attendance_records "
          "SET status = 'present' "
          "WHERE day_id = 1 AND student_id = 1;",
        );

        await database.customStatement(
          "UPDATE recitations "
          "SET note = 'ملاحظة محدثة', "
          "faces_quarter_achieved = 2 "
          "WHERE day_id = 1 AND student_id = 1;",
        );

        final second = await service.previewMessage(1);

        expect(second, contains('الحضور: حاضر'));
        expect(second, contains('ملاحظة محدثة'));
        expect(second, contains('نصف وجه'));
        expect(second, isNot(first));

        final stored = await database
            .customSelect(
              'SELECT status, attendance_status_snapshot, '
              'snapshot_message, channel_snapshot, recipient_snapshot '
              'FROM parent_follow_ups WHERE id = 1;',
            )
            .getSingle();

        expect(stored.read<String>('status'), 'pending');
        expect(
          stored.readNullable<String>('attendance_status_snapshot'),
          isNull,
        );
        expect(stored.readNullable<String>('snapshot_message'), isNull);
        expect(stored.readNullable<String>('channel_snapshot'), isNull);
        expect(stored.readNullable<String>('recipient_snapshot'), isNull);
      } finally {
        await database.close();
      }
    });

    test('confirmation persists the exact prepared payload '
        'even if source data changes after preparation', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final service = _service(database);

        final prepared = await service.preparePayload(
          followUpId: 1,
          channel: ParentFollowUpChannel.whatsapp,
          recipient: '  +967771234567  ',
        );

        expect(
          prepared.attendanceStatus,
          ParentFollowUpAttendanceStatus.absent,
        );
        expect(prepared.message, contains('الحضور: غائب'));
        expect(prepared.message, contains('ملاحظة أولى'));
        expect(prepared.recipient, '+967771234567');

        await database.customStatement(
          "UPDATE attendance_records "
          "SET status = 'present' "
          "WHERE day_id = 1 AND student_id = 1;",
        );

        await database.customStatement(
          "UPDATE recitations "
          "SET note = 'تغير بعد فتح التطبيق الخارجي' "
          "WHERE day_id = 1 AND student_id = 1;",
        );

        final currentLivePreview = await service.previewMessage(1);

        expect(currentLivePreview, contains('الحضور: حاضر'));
        expect(currentLivePreview, contains('تغير بعد فتح التطبيق الخارجي'));

        final handled = await service.confirmHandled(prepared);

        expect(handled.isHandled, isTrue);
        expect(
          handled.handledSnapshot!.attendanceStatus,
          ParentFollowUpAttendanceStatus.absent,
        );
        expect(handled.handledSnapshot!.message, prepared.message);
        expect(
          handled.handledSnapshot!.channel,
          ParentFollowUpChannel.whatsapp,
        );
        expect(handled.handledSnapshot!.recipient, '+967771234567');

        final stored = await database
            .customSelect(
              'SELECT status, attendance_status_snapshot, '
              'snapshot_message, channel_snapshot, recipient_snapshot '
              'FROM parent_follow_ups WHERE id = 1;',
            )
            .getSingle();

        expect(stored.read<String>('status'), 'handled');
        expect(stored.read<String>('attendance_status_snapshot'), 'absent');
        expect(stored.read<String>('snapshot_message'), prepared.message);
        expect(stored.read<String>('channel_snapshot'), 'whatsapp');
        expect(stored.read<String>('recipient_snapshot'), '+967771234567');

        final frozenPreview = await service.previewMessage(1);

        expect(frozenPreview, prepared.message);
        expect(frozenPreview, contains('الحضور: غائب'));
        expect(frozenPreview, isNot(contains('تغير بعد فتح التطبيق الخارجي')));
      } finally {
        await database.close();
      }
    });

    test('handled confirmation is idempotent and cannot overwrite '
        'the original snapshot', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final service = _service(database);

        final firstPayload = await service.preparePayload(
          followUpId: 1,
          channel: ParentFollowUpChannel.sms,
          recipient: '+967771234567',
        );

        final firstHandled = await service.confirmHandled(firstPayload);

        expect(firstHandled.isHandled, isTrue);

        const conflictingPayload = PreparedParentFollowUpPayload(
          followUpId: 1,
          attendanceStatus: ParentFollowUpAttendanceStatus.present,
          message: 'رسالة مختلفة لا يجب أن تستبدل الأصل',
          channel: ParentFollowUpChannel.whatsapp,
          recipient: '+967731111111',
        );

        final secondHandled = await service.confirmHandled(conflictingPayload);

        expect(secondHandled.isHandled, isTrue);
        expect(secondHandled.handledSnapshot!.message, firstPayload.message);
        expect(
          secondHandled.handledSnapshot!.attendanceStatus,
          firstPayload.attendanceStatus,
        );
        expect(
          secondHandled.handledSnapshot!.channel,
          ParentFollowUpChannel.sms,
        );
        expect(secondHandled.handledSnapshot!.recipient, '+967771234567');

        final count = await database
            .customSelect(
              'SELECT COUNT(*) AS total '
              'FROM parent_follow_ups WHERE id = 1;',
            )
            .getSingle();

        expect(count.read<int>('total'), 1);
      } finally {
        await database.close();
      }
    });

    test('preparing a payload without confirmation leaves '
        'the follow up pending with null snapshots', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final service = _service(database);

        final prepared = await service.preparePayload(
          followUpId: 1,
          channel: ParentFollowUpChannel.sms,
          recipient: '+967771234567',
        );

        expect(prepared.message, isNotEmpty);

        final followUp = await service.requiredFollowUp(1);

        expect(followUp.isPending, isTrue);
        expect(followUp.handledSnapshot, isNull);

        final stored = await database
            .customSelect(
              'SELECT status, snapshot_message '
              'FROM parent_follow_ups WHERE id = 1;',
            )
            .getSingle();

        expect(stored.read<String>('status'), 'pending');
        expect(stored.readNullable<String>('snapshot_message'), isNull);
      } finally {
        await database.close();
      }
    });

    test('Yemen payload supports either sms or whatsapp', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final service = _service(database);

        final sms = await service.preparePayload(
          followUpId: 1,
          channel: ParentFollowUpChannel.sms,
          recipient: '+967771234567',
        );

        final whatsapp = await service.preparePayload(
          followUpId: 1,
          channel: ParentFollowUpChannel.whatsapp,
          recipient: '+967771234567',
        );

        expect(sms.channel, ParentFollowUpChannel.sms);
        expect(whatsapp.channel, ParentFollowUpChannel.whatsapp);
        expect(sms.message, whatsapp.message);
      } finally {
        await database.close();
      }
    });

    test('blank recipient is rejected before any state change', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final service = _service(database);

        await expectLater(
          service.preparePayload(
            followUpId: 1,
            channel: ParentFollowUpChannel.sms,
            recipient: '   ',
          ),
          throwsArgumentError,
        );

        final followUp = await service.requiredFollowUp(1);

        expect(followUp.isPending, isTrue);
        expect(followUp.handledSnapshot, isNull);
      } finally {
        await database.close();
      }
    });

    test('unknown follow up fails explicitly', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final service = _service(database);

        await expectLater(service.previewMessage(999), throwsStateError);
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

Future<void> _seedPendingDaily(AppDatabase database) async {
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
    "INSERT INTO halaqah_days "
    "(id, halaqah_id, day_date, status) "
    "VALUES (1, 1, '2026-09-15', 'closed');",
  );

  await database.customStatement(
    "INSERT INTO attendance_records "
    "(day_id, student_id, status) "
    "VALUES (1, 1, 'absent');",
  );

  await database.customStatement(
    "INSERT INTO recitations "
    "(id, day_id, student_id, type, "
    "start_surah, start_ayah, end_surah, end_ayah, "
    "faces_quarter_achieved, evaluation, error_count, note) "
    "VALUES ("
    "1, 1, 1, 'new_memorization', "
    "112, 1, 112, 4, "
    "1, 'excellent', 0, 'ملاحظة أولى'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO parent_follow_ups "
    "(id, day_id, student_id, type, status) "
    "VALUES (1, 1, 1, 'daily', 'pending');",
  );
}
