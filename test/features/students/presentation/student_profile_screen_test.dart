import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/student_runtime_providers.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';
import 'package:qurani/features/students/domain/student.dart';
import 'package:qurani/features/students/presentation/student_profile_screen.dart';
import 'package:qurani/features/students/presentation/students_list_screen.dart';

void main() {
  group('StudentProfileScreen', () {
    testWidgets('shows student identity and existing progress plan', (
      tester,
    ) async {
      final harness = await _Harness.create();

      try {
        final student = await harness.createStudent();

        await harness.service.updateProgressPlan(
          UpdateStudentProgressPlanRequest(
            studentId: student.id,
            currentJuz: 5,
            dailyPlanText: 'نصف وجه يوميًا',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: StudentProfileScreen(
              service: harness.service,
              student: student,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('student_profile_screen')), findsOneWidget);

        expect(find.text('أحمد'), findsOneWidget);
        expect(find.text('محمد'), findsOneWidget);
        expect(find.text('+967 771234567'), findsOneWidget);
        expect(find.text('جزء عم'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('نصف وجه يوميًا'), findsOneWidget);
      } finally {
        await harness.close();
      }
    });

    testWidgets(
      'edit button updates student and returns to refreshed profile',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetDevicePixelRatio);

        tester.view.physicalSize = const Size(800, 900);
        addTearDown(tester.view.resetPhysicalSize);

        final harness = await _Harness.create();

        try {
          final student = await harness.createStudent();

          await tester.pumpWidget(
            MaterialApp(
              home: StudentProfileScreen(
                service: harness.service,
                student: student,
              ),
            ),
          );

          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('edit_student_button')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('student_form_screen')), findsOneWidget);

          await tester.enterText(
            find.byKey(const Key('student_name_field')),
            'أحمد المعدل',
          );

          final submit = find.byKey(const Key('submit_student_button'));

          await tester.dragUntilVisible(
            submit,
            find.byType(SingleChildScrollView),
            const Offset(0, -250),
          );
          await tester.pumpAndSettle();
          await tester.tap(submit);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('student_profile_screen')),
            findsOneWidget,
          );

          expect(find.text('أحمد المعدل'), findsOneWidget);

          final students = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(students.single.studentName, 'أحمد المعدل');
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets('tapping student card opens student profile from active list', (
      tester,
    ) async {
      final harness = await _Harness.create();

      try {
        final student = await harness.createStudent();

        final runtimeContext = StudentRuntimeContext(
          halaqahId: harness.halaqahId,
          service: harness.service,
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

        await tester.tap(find.byKey(ValueKey<String>('student_${student.id}')));

        await tester.pumpAndSettle();

        expect(find.byKey(const Key('student_profile_screen')), findsOneWidget);

        expect(find.text('أحمد'), findsOneWidget);
      } finally {
        await harness.close();
      }
    });
  });
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

    final now = DateTime.utc(2026, 9, 14);

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
      clock: const SystemClock(),
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
        note: 'ملاحظة الطالب',
      ),
    );
  }

  Future<void> close() => database.close();
}
