import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_profile_screen.dart';

void main() {
  group('Student progress plan UI', () {
    testWidgets(
      'profile opens progress editor, saves plan, and refreshes displayed values',
      (tester) async {
        _configureView(tester);

        final harness = await _Harness.create();

        try {
          final student = await harness.createStudent();

          await _pumpProfile(tester, harness: harness, student: student);

          final editButton = find.byKey(const Key('edit_progress_plan_button'));

          await tester.ensureVisible(editButton);
          await tester.pumpAndSettle();

          await tester.tap(editButton);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('student_progress_plan_screen')),
            findsOneWidget,
          );

          await tester.enterText(
            find.byKey(const Key('current_juz_field')),
            '7',
          );

          await tester.enterText(
            find.byKey(const Key('daily_plan_text_field')),
            '  نصف وجه يوميًا  ',
          );

          await tester.tap(find.byKey(const Key('save_progress_plan_button')));

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('student_profile_screen')),
            findsOneWidget,
          );

          expect(find.text('7'), findsOneWidget);
          expect(find.text('نصف وجه يوميًا'), findsOneWidget);

          final stored = await harness.service.getProgressPlan(student.id);

          expect(stored, isNotNull);
          expect(stored!.currentJuz, 7);
          expect(stored.dailyPlanText, 'نصف وجه يوميًا');
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets('progress editor rejects current juz outside 1 to 30', (
      tester,
    ) async {
      _configureView(tester);

      final harness = await _Harness.create();

      try {
        final student = await harness.createStudent();

        await _pumpProfile(tester, harness: harness, student: student);

        final editButton = find.byKey(const Key('edit_progress_plan_button'));

        await tester.ensureVisible(editButton);
        await tester.pumpAndSettle();

        await tester.tap(editButton);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('current_juz_field')),
          '31',
        );

        await tester.tap(find.byKey(const Key('save_progress_plan_button')));

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('student_progress_plan_screen')),
          findsOneWidget,
        );

        expect(find.byKey(const Key('progress_plan_error')), findsOneWidget);

        final stored = await harness.service.getProgressPlan(student.id);

        expect(stored, isNull);
      } finally {
        await harness.close();
      }
    });

    testWidgets('progress editor allows both optional values to be cleared', (
      tester,
    ) async {
      _configureView(tester);

      final harness = await _Harness.create();

      try {
        final student = await harness.createStudent();

        await harness.service.updateProgressPlan(
          UpdateStudentProgressPlanRequest(
            studentId: student.id,
            currentJuz: 5,
            dailyPlanText: 'وجه يوميًا',
          ),
        );

        await _pumpProfile(tester, harness: harness, student: student);

        final editButton = find.byKey(const Key('edit_progress_plan_button'));

        await tester.ensureVisible(editButton);
        await tester.pumpAndSettle();

        await tester.tap(editButton);
        await tester.pumpAndSettle();

        expect(find.text('5'), findsOneWidget);

        expect(find.text('وجه يوميًا'), findsOneWidget);

        await tester.enterText(find.byKey(const Key('current_juz_field')), '');

        await tester.enterText(
          find.byKey(const Key('daily_plan_text_field')),
          '',
        );

        await tester.tap(find.byKey(const Key('save_progress_plan_button')));

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('student_profile_screen')), findsOneWidget);

        expect(find.text('غير محدد'), findsOneWidget);

        expect(find.text('غير محددة'), findsOneWidget);

        final stored = await harness.service.getProgressPlan(student.id);

        expect(stored, isNotNull);
        expect(stored!.currentJuz, isNull);
        expect(stored.dailyPlanText, isNull);
      } finally {
        await harness.close();
      }
    });
  });
}

void _configureView(WidgetTester tester) {
  tester.view.devicePixelRatio = 1.0;

  addTearDown(tester.view.resetDevicePixelRatio);

  tester.view.physicalSize = const Size(800, 900);

  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  required _Harness harness,
  required StudentRecord student,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: StudentProfileScreen(service: harness.service, student: student),
    ),
  );

  await tester.pumpAndSettle();
}

final class _Harness {
  _Harness({
    required this.database,
    required this.halaqahId,
    required this.service,
  });

  final AppDatabase database;
  final int halaqahId;
  final StudentService service;

  static Future<_Harness> create() async {
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
            status: 'disabled',
            organizationName: const Value<String?>(null),
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );

    final service = StudentService(
      repository: DriftStudentRepository(database),
      phoneNumberPolicy: const PhoneNumberPolicy(),
      clock: const _FixedClock(),
    );

    return _Harness(database: database, halaqahId: halaqahId, service: service);
  }

  Future<StudentRecord> createStudent() {
    return service.create(
      CreateStudentRequest(
        halaqahId: halaqahId,
        studentName: 'أحمد',
        fatherName: 'محمد',
        ageYears: 10,
        guardianCountry: GuardianPhoneCountry.yemen,
        guardianPhoneInput: '0771234567',
        previousMemorizationText: 'جزء عم',
      ),
    );
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
