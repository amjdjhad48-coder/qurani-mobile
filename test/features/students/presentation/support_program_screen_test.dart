import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/application/support_program_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/data/drift_support_program_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/students_list_screen.dart';
import 'package:qurani/features/students/presentation/support_program_screen.dart';

void main() {
  group('SupportProgramScreen', () {
    testWidgets(
      'disabled support begins pending activation and shows missing students',
      (tester) async {
        _configureView(tester);

        final harness = await _Harness.create(status: 'disabled');

        try {
          final student = await harness.createStudent(name: 'أحمد الناقص');

          await _pumpSupportScreen(tester, harness);

          expect(find.text('غير مفعل'), findsOneWidget);

          await tester.enterText(
            find.byKey(const Key('support_organization_field')),
            '  مؤسسة الخير  ',
          );

          await tester.tap(
            find.byKey(const Key('begin_support_activation_button')),
          );

          await tester.pumpAndSettle();

          expect(find.text('بانتظار استكمال التفعيل'), findsOneWidget);

          expect(find.text('الجهة الداعمة: مؤسسة الخير'), findsOneWidget);

          expect(find.text('أحمد الناقص'), findsOneWidget);

          expect(
            find.byKey(ValueKey<String>('support_gap_${student.id}')),
            findsOneWidget,
          );

          final activateButton = tester.widget<FilledButton>(
            find.byKey(const Key('activate_support_button')),
          );

          expect(activateButton.onPressed, isNull);

          final settings = await harness.settings();

          expect(settings.status, 'pending_activation');

          expect(settings.organizationName, 'مؤسسة الخير');
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets(
      'pending support with complete student numbers requires explicit confirmation and activates',
      (tester) async {
        _configureView(tester);

        final harness = await _Harness.create(
          status: 'pending_activation',
          organizationName: 'مؤسسة الخير',
        );

        try {
          await harness.createStudent(name: 'أحمد', supportNumber: 'SUP-101');

          await _pumpSupportScreen(tester, harness);

          expect(
            find.byKey(const Key('support_activation_ready')),
            findsOneWidget,
          );

          final activateFinder = find.byKey(
            const Key('activate_support_button'),
          );

          await tester.ensureVisible(activateFinder);
          await tester.pumpAndSettle();

          await tester.tap(activateFinder);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('activate_support_dialog')),
            findsOneWidget,
          );

          var settings = await harness.settings();

          expect(settings.status, 'pending_activation');

          expect(await harness.supportPeriods(), isEmpty);

          await tester.tap(
            find.byKey(const Key('confirm_activate_support_button')),
          );

          await tester.pumpAndSettle();

          expect(find.text('مفعل'), findsOneWidget);

          settings = await harness.settings();

          expect(settings.status, 'enabled');

          final periods = await harness.supportPeriods();

          expect(periods, hasLength(1));
          expect(periods.single.endedAtUtc, isNull);
          expect(periods.single.organizationName, 'مؤسسة الخير');
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets(
      'enabled support requires confirmation and disables by closing current period',
      (tester) async {
        _configureView(tester);

        final harness = await _Harness.create(
          status: 'enabled',
          organizationName: 'مؤسسة الخير',
          openSupportPeriod: true,
        );

        try {
          await _pumpSupportScreen(tester, harness);

          expect(find.text('مفعل'), findsOneWidget);

          final disableFinder = find.byKey(const Key('disable_support_button'));

          await tester.ensureVisible(disableFinder);
          await tester.pumpAndSettle();

          await tester.tap(disableFinder);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('disable_support_dialog')),
            findsOneWidget,
          );

          await tester.tap(
            find.byKey(const Key('confirm_disable_support_button')),
          );

          await tester.pumpAndSettle();

          expect(find.text('غير مفعل'), findsOneWidget);

          final settings = await harness.settings();

          expect(settings.status, 'disabled');

          expect(settings.organizationName, isNull);

          final periods = await harness.supportPeriods();

          expect(periods, hasLength(1));
          expect(periods.single.endedAtUtc, isNotNull);
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets(
      'main students list opens support program using runtime support service',
      (tester) async {
        _configureView(tester);

        final harness = await _Harness.create(status: 'disabled');

        try {
          final runtimeContext = StudentRuntimeContext(
            halaqahId: harness.halaqahId,
            service: harness.studentService,
            supportProgramService: harness.supportService,
          );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                studentRuntimeContextProvider.overrideWith(
                  (ref) async => runtimeContext,
                ),
              ],
              child: MaterialApp(
                home: StudentsListScreen(onChangePin: () {}, onLockNow: () {}),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final supportButton = find.byKey(const Key('support_program_button'));

          expect(supportButton, findsOneWidget);

          await tester.ensureVisible(supportButton);
          await tester.pumpAndSettle();

          await tester.tap(supportButton);

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('support_program_screen')),
            findsOneWidget,
          );

          expect(find.text('غير مفعل'), findsOneWidget);
        } finally {
          await harness.close();
        }
      },
    );
  });
}

void _configureView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;

  addTearDown(tester.view.resetDevicePixelRatio);

  tester.view.physicalSize = const Size(800, 900);

  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _pumpSupportScreen(WidgetTester tester, _Harness harness) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SupportProgramScreen(
        service: harness.supportService,
        halaqahId: harness.halaqahId,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

final class _Harness {
  _Harness({
    required this.database,
    required this.halaqahId,
    required this.studentService,
    required this.supportService,
  });

  final AppDatabase database;
  final int halaqahId;
  final StudentService studentService;
  final SupportProgramService supportService;

  static Future<_Harness> create({
    required String status,
    String? organizationName,
    bool openSupportPeriod = false,
  }) async {
    final database = AppDatabase(NativeDatabase.memory());

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

    await database
        .into(database.supportProgramSettings)
        .insert(
          SupportProgramSettingsCompanion.insert(
            halaqahId: halaqahId,
            status: status,
            organizationName: Value<String?>(organizationName),
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );

    if (openSupportPeriod) {
      await database
          .into(database.supportProgramPeriods)
          .insert(
            SupportProgramPeriodsCompanion.insert(
              halaqahId: halaqahId,
              organizationName: organizationName!,
              startedAtUtc: DateTime.utc(2026, 9, 13, 12),
            ),
          );
    }

    const clock = _FixedClock();

    final studentService = StudentService(
      repository: DriftStudentRepository(database),
      phoneNumberPolicy: const PhoneNumberPolicy(),
      clock: clock,
    );

    final supportService = SupportProgramService(
      DriftSupportProgramRepository(database),
      clock,
    );

    return _Harness(
      database: database,
      halaqahId: halaqahId,
      studentService: studentService,
      supportService: supportService,
    );
  }

  Future<StudentRecord> createStudent({
    required String name,
    String? supportNumber,
  }) {
    return studentService.create(
      CreateStudentRequest(
        halaqahId: halaqahId,
        studentName: name,
        fatherName: 'محمد',
        ageYears: 10,
        guardianCountry: GuardianPhoneCountry.yemen,
        guardianPhoneInput: '0771234567',
        previousMemorizationText: 'جزء عم',
        supportStudentNumber: supportNumber,
      ),
    );
  }

  Future<SupportProgramSetting> settings() {
    return (database.select(
      database.supportProgramSettings,
    )..where((table) => table.halaqahId.equals(halaqahId))).getSingle();
  }

  Future<List<SupportProgramPeriod>> supportPeriods() {
    return (database.select(
      database.supportProgramPeriods,
    )..where((table) => table.halaqahId.equals(halaqahId))).get();
  }

  Future<void> close() {
    return database.close();
  }
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime nowUtc() {
    return DateTime.utc(2026, 9, 14, 12);
  }

  @override
  DateTime todayLocal() {
    return DateTime(2026, 9, 14);
  }
}
