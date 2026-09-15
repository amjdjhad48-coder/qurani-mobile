import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_dispatch_service.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_recipient_policy.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_service.dart';
import 'package:qurani/features/parent_follow_up/data/drift_parent_follow_up_repository.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_external_gateway.dart';
import 'package:qurani/features/students/domain/student.dart';

void main() {
  group('Package 6 return confirmation coordinator', () {
    test(
      'YES marks handled using the exact payload opened externally',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          await _seedPendingDaily(database);

          final gateway = _FakeGateway();

          final dispatch = _dispatch(database, gateway);

          final session = await dispatch.open(
            followUpId: 1,
            student: _student(countryCode: '+967', nationalNumber: '771234567'),
            channel: ParentFollowUpChannel.whatsapp,
          );

          expect(gateway.callCount, 1);
          expect(gateway.lastPayload, isNotNull);
          expect(gateway.lastPayload!.message, session.payload.message);
          expect(gateway.lastPayload!.recipient, '+967771234567');
          expect(session.payload.channel, ParentFollowUpChannel.whatsapp);

          final handled = await dispatch.confirmReturn(
            session: session,
            didSend: true,
          );

          expect(handled.isHandled, isTrue);

          final snapshot = handled.handledSnapshot!;

          expect(snapshot.message, session.payload.message);
          expect(snapshot.attendanceStatus, session.payload.attendanceStatus);
          expect(snapshot.channel, ParentFollowUpChannel.whatsapp);
          expect(snapshot.recipient, '+967771234567');

          final stored = await database
              .customSelect(
                'SELECT status, snapshot_message, '
                'attendance_status_snapshot, '
                'channel_snapshot, recipient_snapshot '
                'FROM parent_follow_ups WHERE id = 1;',
              )
              .getSingle();

          expect(stored.read<String>('status'), 'handled');
          expect(
            stored.read<String>('snapshot_message'),
            session.payload.message,
          );
          expect(
            stored.read<String>('attendance_status_snapshot'),
            session.payload.attendanceStatus.storageValue,
          );
          expect(stored.read<String>('channel_snapshot'), 'whatsapp');
          expect(stored.read<String>('recipient_snapshot'), '+967771234567');
        } finally {
          await database.close();
        }
      },
    );

    test('NO leaves the row pending and stores no snapshots', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final gateway = _FakeGateway();

        final dispatch = _dispatch(database, gateway);

        final session = await dispatch.open(
          followUpId: 1,
          student: _student(countryCode: '+967', nationalNumber: '731234567'),
          channel: ParentFollowUpChannel.sms,
        );

        final pending = await dispatch.confirmReturn(
          session: session,
          didSend: false,
        );

        expect(gateway.callCount, 1);
        expect(pending.isPending, isTrue);
        expect(pending.handledSnapshot, isNull);

        final stored = await database
            .customSelect(
              'SELECT status, snapshot_message, '
              'attendance_status_snapshot, '
              'channel_snapshot, recipient_snapshot '
              'FROM parent_follow_ups WHERE id = 1;',
            )
            .getSingle();

        expect(stored.read<String>('status'), 'pending');

        expect(stored.readNullable<String>('snapshot_message'), isNull);
        expect(
          stored.readNullable<String>('attendance_status_snapshot'),
          isNull,
        );
        expect(stored.readNullable<String>('channel_snapshot'), isNull);
        expect(stored.readNullable<String>('recipient_snapshot'), isNull);
      } finally {
        await database.close();
      }
    });

    test('invalid guardian phone requires phone fix '
        'before any external launch', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final gateway = _FakeGateway();

        final dispatch = _dispatch(database, gateway);

        await expectLater(
          dispatch.open(
            followUpId: 1,
            student: _student(countryCode: '+967', nationalNumber: '721234567'),
            channel: ParentFollowUpChannel.whatsapp,
          ),
          throwsA(
            isA<ParentFollowUpPhoneFixRequiredException>().having(
              (error) => error.studentId,
              'studentId',
              1,
            ),
          ),
        );

        expect(gateway.callCount, 0);

        final followUp = await ParentFollowUpService(
          repository: DriftParentFollowUpRepository(database),
        ).requiredFollowUp(1);

        expect(followUp.isPending, isTrue);
        expect(followUp.handledSnapshot, isNull);
      } finally {
        await database.close();
      }
    });

    test('Saudi SMS is blocked before any external launch', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final gateway = _FakeGateway();

        final dispatch = _dispatch(database, gateway);

        await expectLater(
          dispatch.open(
            followUpId: 1,
            student: _student(countryCode: '+966', nationalNumber: '551234567'),
            channel: ParentFollowUpChannel.sms,
          ),
          throwsA(isA<ParentFollowUpChannelNotAllowedException>()),
        );

        expect(gateway.callCount, 0);
      } finally {
        await database.close();
      }
    });

    test('follow up cannot be sent using another student recipient', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final gateway = _FakeGateway();

        final dispatch = _dispatch(database, gateway);

        await expectLater(
          dispatch.open(
            followUpId: 1,
            student: _student(
              id: 2,
              countryCode: '+967',
              nationalNumber: '771111111',
            ),
            channel: ParentFollowUpChannel.whatsapp,
          ),
          throwsStateError,
        );

        expect(gateway.callCount, 0);
      } finally {
        await database.close();
      }
    });

    test('failed external launch never changes pending state', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await _seedPendingDaily(database);

        final gateway = _FakeGateway(launched: false);

        final dispatch = _dispatch(database, gateway);

        await expectLater(
          dispatch.open(
            followUpId: 1,
            student: _student(countryCode: '+967', nationalNumber: '771234567'),
            channel: ParentFollowUpChannel.whatsapp,
          ),
          throwsStateError,
        );

        expect(gateway.callCount, 1);

        final followUp = await ParentFollowUpService(
          repository: DriftParentFollowUpRepository(database),
        ).requiredFollowUp(1);

        expect(followUp.isPending, isTrue);
        expect(followUp.handledSnapshot, isNull);
      } finally {
        await database.close();
      }
    });
  });
}

ParentFollowUpDispatchService _dispatch(
  AppDatabase database,
  _FakeGateway gateway,
) {
  final parentFollowUpService = ParentFollowUpService(
    repository: DriftParentFollowUpRepository(database),
  );

  return ParentFollowUpDispatchService(
    parentFollowUpService: parentFollowUpService,
    recipientPolicy: const ParentFollowUpRecipientPolicy(),
    externalGateway: gateway,
  );
}

StudentRecord _student({
  int id = 1,
  required String countryCode,
  required String nationalNumber,
}) {
  return StudentRecord(
    id: id,
    halaqahId: 1,
    studentName: 'أحمد',
    fatherName: 'محمد',
    ageYears: 12,
    guardianCountryCode: countryCode,
    guardianNationalNumber: nationalNumber,
    previousMemorizationText: 'جزء سابق',
    note: null,
    supportStudentNumber: null,
    displayOrder: 1,
    isActive: true,
    archivedAtUtc: null,
  );
}

Future<void> _seedPendingDaily(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'حلقة ذي النورين', "
    "'المركز الرئيسي', "
    "'2026-09-15T10:00:00.000Z', "
    "'2026-09-15T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, "
    "age_years, guardian_country_code, "
    "guardian_national_number, "
    "previous_memorization_text, display_order, "
    "is_active) "
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
    "INSERT INTO parent_follow_ups "
    "(id, day_id, student_id, type, status) "
    "VALUES (1, 1, 1, 'daily', 'pending');",
  );
}

final class _FakeGateway implements ParentFollowUpExternalGateway {
  _FakeGateway({this.launched = true});

  final bool launched;

  int callCount = 0;
  PreparedParentFollowUpPayload? lastPayload;

  @override
  Future<ParentFollowUpExternalLaunch> open(
    PreparedParentFollowUpPayload payload,
  ) async {
    callCount += 1;
    lastPayload = payload;

    return ParentFollowUpExternalLaunch(
      channel: payload.channel,
      launched: launched,
      action: payload.channel == ParentFollowUpChannel.sms
          ? 'android.intent.action.SENDTO'
          : 'android.intent.action.VIEW',
      uriScheme: payload.channel == ParentFollowUpChannel.sms
          ? 'smsto'
          : 'https',
      recipient: payload.recipient,
    );
  }
}
