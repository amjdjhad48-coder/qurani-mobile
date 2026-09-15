import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/daily_halaqah/application/close_halaqah_day_core.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_read_service.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_service.dart';
import 'package:qurani/features/daily_halaqah/application/halaqah_holiday_service.dart';
import 'package:qurani/features/daily_halaqah/data/drift_daily_halaqah_repository.dart';
import 'package:qurani/features/daily_halaqah/presentation/halaqah_day_summary_screen.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_dispatch_service.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_recipient_policy.dart';
import 'package:qurani/features/parent_follow_up/application/parent_follow_up_service.dart';
import 'package:qurani/features/parent_follow_up/data/drift_parent_follow_up_repository.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_dispatch.dart';
import 'package:qurani/features/parent_follow_up/domain/parent_follow_up_external_gateway.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';

void main() {
  group('Package 6 day summary family follow up UI', () {
    testWidgets(
      'Yemen offers SMS and WhatsApp and YES handles exact launched payload '
      'only after external return',
      (tester) async {
        final harness = await _Harness.create(
          countryCode: '+967',
          nationalNumber: '771234567',
        );

        try {
          await _pumpSummary(tester, harness);

          expect(
            find.byKey(const Key('parent_follow_up_section_title')),
            findsOneWidget,
          );

          expect(
            find.byKey(const ValueKey<String>('parent_follow_up_pending_1')),
            findsOneWidget,
          );

          final whatsapp = find.byKey(
            const ValueKey<String>('parent_follow_up_send_whatsapp_1'),
          );

          final sms = find.byKey(
            const ValueKey<String>('parent_follow_up_send_sms_1'),
          );

          expect(whatsapp, findsOneWidget);
          expect(sms, findsOneWidget);

          await tester.ensureVisible(whatsapp);
          await tester.pumpAndSettle();

          await tester.tap(whatsapp);
          await tester.pumpAndSettle();

          expect(harness.gateway.callCount, 1);
          expect(harness.gateway.lastPayload, isNotNull);
          expect(harness.gateway.lastPayload!.recipient, '+967771234567');
          expect(
            harness.gateway.lastPayload!.channel,
            ParentFollowUpChannel.whatsapp,
          );

          expect(
            find.text('هل أتممت إرسال الرسالة؟'),
            findsNothing,
            reason:
                'The confirmation must wait until the app actually returns.',
          );

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          await tester.pump();

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.hidden,
          );
          await tester.pump();

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pump();

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pumpAndSettle();

          expect(find.text('هل أتممت إرسال الرسالة؟'), findsOneWidget);

          await tester.tap(
            find.byKey(const Key('parent_follow_up_return_yes_button')),
          );
          await tester.pumpAndSettle();

          final stored = await harness.database
              .customSelect(
                'SELECT status, snapshot_message, '
                'attendance_status_snapshot, '
                'channel_snapshot, recipient_snapshot '
                'FROM parent_follow_ups '
                'WHERE id = 1;',
              )
              .getSingle();

          expect(stored.read<String>('status'), 'handled');
          expect(
            stored.read<String>('snapshot_message'),
            harness.gateway.lastPayload!.message,
          );
          expect(
            stored.read<String>('attendance_status_snapshot'),
            harness.gateway.lastPayload!.attendanceStatus.storageValue,
          );
          expect(stored.read<String>('channel_snapshot'), 'whatsapp');
          expect(stored.read<String>('recipient_snapshot'), '+967771234567');

          expect(
            find.byKey(const ValueKey<String>('parent_follow_up_handled_1')),
            findsOneWidget,
          );
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets(
      'NO after external return keeps follow up pending with null snapshots',
      (tester) async {
        final harness = await _Harness.create(
          countryCode: '+967',
          nationalNumber: '731234567',
        );

        try {
          await _pumpSummary(tester, harness);

          final sms = find.byKey(
            const ValueKey<String>('parent_follow_up_send_sms_1'),
          );

          await tester.ensureVisible(sms);
          await tester.pumpAndSettle();

          await tester.tap(sms);
          await tester.pumpAndSettle();

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          await tester.pump();

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.hidden,
          );
          await tester.pump();

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pump();

          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pumpAndSettle();

          await tester.tap(
            find.byKey(const Key('parent_follow_up_return_no_button')),
          );
          await tester.pumpAndSettle();

          final stored = await harness.database
              .customSelect(
                'SELECT status, snapshot_message, '
                'attendance_status_snapshot, '
                'channel_snapshot, recipient_snapshot '
                'FROM parent_follow_ups '
                'WHERE id = 1;',
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

          expect(
            find.byKey(const ValueKey<String>('parent_follow_up_pending_1')),
            findsOneWidget,
          );
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets('invalid guardian phone routes to existing student form and '
        'a corrected number unlocks approved send channels', (tester) async {
      final harness = await _Harness.create(
        countryCode: '+967',
        nationalNumber: '721234567',
      );

      try {
        await _pumpSummary(tester, harness);

        final fix = find.byKey(
          const ValueKey<String>('parent_follow_up_fix_phone_1'),
        );

        expect(fix, findsOneWidget);

        expect(
          find.byKey(const ValueKey<String>('parent_follow_up_send_sms_1')),
          findsNothing,
        );

        expect(
          find.byKey(
            const ValueKey<String>('parent_follow_up_send_whatsapp_1'),
          ),
          findsNothing,
        );

        await tester.ensureVisible(fix);
        await tester.pumpAndSettle();

        await tester.tap(fix);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('student_form_screen')), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('guardian_phone_field')),
          '0771234567',
        );

        final submit = find.byKey(const Key('submit_student_button'));

        await tester.ensureVisible(submit);
        await tester.pumpAndSettle();

        await tester.tap(submit);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('halaqah_day_summary_screen')),
          findsOneWidget,
        );

        expect(
          find.byKey(const ValueKey<String>('parent_follow_up_send_sms_1')),
          findsOneWidget,
        );

        expect(
          find.byKey(
            const ValueKey<String>('parent_follow_up_send_whatsapp_1'),
          ),
          findsOneWidget,
        );

        final student = await harness.database
            .customSelect(
              'SELECT guardian_country_code, '
              'guardian_national_number '
              'FROM students WHERE id = 1;',
            )
            .getSingle();

        expect(student.read<String>('guardian_country_code'), '+967');

        expect(student.read<String>('guardian_national_number'), '771234567');
      } finally {
        await harness.close();
      }
    });

    testWidgets('Saudi guardian exposes WhatsApp only', (tester) async {
      final harness = await _Harness.create(
        countryCode: '+966',
        nationalNumber: '551234567',
      );

      try {
        await _pumpSummary(tester, harness);

        expect(
          find.byKey(
            const ValueKey<String>('parent_follow_up_send_whatsapp_1'),
          ),
          findsOneWidget,
        );

        expect(
          find.byKey(const ValueKey<String>('parent_follow_up_send_sms_1')),
          findsNothing,
        );
      } finally {
        await harness.close();
      }
    });
  });
}

Future<void> _pumpSummary(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(
    MaterialApp(
      home: HalaqahDaySummaryScreen(runtimeContext: harness.context, dayId: 1),
    ),
  );

  await tester.pumpAndSettle();
}

final class _Harness {
  _Harness({
    required this.database,
    required this.context,
    required this.gateway,
  });

  final AppDatabase database;
  final DailyHalaqahRuntimeContext context;
  final _FakeGateway gateway;

  static Future<_Harness> create({
    required String countryCode,
    required String nationalNumber,
  }) async {
    final database = AppDatabase(NativeDatabase.memory());

    await _seed(
      database,
      countryCode: countryCode,
      nationalNumber: nationalNumber,
    );

    final dailyRepository = DriftDailyHalaqahRepository(database);

    final parentRepository = DriftParentFollowUpRepository(database);

    final parentService = ParentFollowUpService(repository: parentRepository);

    final gateway = _FakeGateway();

    final dispatch = ParentFollowUpDispatchService(
      parentFollowUpService: parentService,
      recipientPolicy: const ParentFollowUpRecipientPolicy(),
      externalGateway: gateway,
    );

    const clock = _FixedClock();

    final studentService = StudentService(
      repository: DriftStudentRepository(database),
      phoneNumberPolicy: const PhoneNumberPolicy(),
      clock: clock,
    );

    final context = DailyHalaqahRuntimeContext(
      halaqahId: 1,
      halaqahName: 'حلقة الاختبار',
      teacherName: 'المعلم',
      clock: clock,
      service: DailyHalaqahService(repository: dailyRepository, clock: clock),
      readService: DailyHalaqahReadService(dailyRepository),
      holidayService: HalaqahHolidayService(dailyRepository),
      closeDayCore: CloseHalaqahDayCore(dailyRepository),
      parentFollowUpService: parentService,
      parentFollowUpDispatchService: dispatch,
      studentService: studentService,
    );

    return _Harness(database: database, context: context, gateway: gateway);
  }

  Future<void> close() {
    return database.close();
  }
}

Future<void> _seed(
  AppDatabase database, {
  required String countryCode,
  required String nationalNumber,
}) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'حلقة الاختبار', 'المركز', "
    "'2026-09-15T10:00:00.000Z', "
    "'2026-09-15T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO support_program_settings "
    "(halaqah_id, status, organization_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'disabled', NULL, "
    "'2026-09-15T10:00:00.000Z', "
    "'2026-09-15T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, "
    "age_years, guardian_country_code, "
    "guardian_national_number, "
    "previous_memorization_text, "
    "display_order, is_active) "
    "VALUES ("
    "1, 1, 'أحمد', 'محمد', 12, "
    "'$countryCode', '$nationalNumber', "
    "'جزء سابق', 1, 1"
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
    "VALUES ("
    "1, 1, '2026-09-15', 'closed'"
    ");",
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
      launched: true,
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

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() {
    return DateTime.utc(2026, 9, 15, 12);
  }

  @override
  DateTime todayLocal() {
    return DateTime(2026, 9, 15);
  }
}
