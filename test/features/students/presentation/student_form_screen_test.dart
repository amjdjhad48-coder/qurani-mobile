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
import 'package:qurani/features/students/presentation/student_form_screen.dart';

void main() {
  group('StudentFormScreen', () {
    testWidgets(
      'creates student with the approved core fields when support is disabled',
      (tester) async {
        final harness = await _Harness.create(supportStatus: 'disabled');

        try {
          await tester.pumpWidget(
            MaterialApp(
              home: StudentFormScreen(
                service: harness.service,
                halaqahId: harness.halaqahId,
                supportStatus: 'disabled',
              ),
            ),
          );

          expect(
            find.byKey(const Key('support_student_number_field')),
            findsNothing,
          );

          await _fillCoreStudentFields(tester);

          await tester.ensureVisible(
            find.byKey(const Key('submit_student_button')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('submit_student_button')));
          await tester.pumpAndSettle();

          final students = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(students, hasLength(1));

          final student = students.single;

          expect(student.studentName, 'أحمد');
          expect(student.fatherName, 'محمد');
          expect(student.ageYears, 10);
          expect(student.guardianCountryCode, '+967');
          expect(student.guardianNationalNumber, '771234567');
          expect(student.previousMemorizationText, 'جزء عم');
          expect(student.note, 'ملاحظة');
          expect(student.supportStudentNumber, isNull);
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets('pending support shows support number but keeps it optional', (
      tester,
    ) async {
      final harness = await _Harness.create(
        supportStatus: 'pending_activation',
      );

      try {
        await tester.pumpWidget(
          MaterialApp(
            home: StudentFormScreen(
              service: harness.service,
              halaqahId: harness.halaqahId,
              supportStatus: 'pending_activation',
            ),
          ),
        );

        expect(
          find.byKey(const Key('support_student_number_field')),
          findsOneWidget,
        );

        await _fillCoreStudentFields(tester);

        await tester.ensureVisible(
          find.byKey(const Key('submit_student_button')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('submit_student_button')));
        await tester.pumpAndSettle();

        final students = await harness.service.search(
          halaqahId: harness.halaqahId,
        );

        expect(students, hasLength(1));
        expect(students.single.supportStudentNumber, isNull);
      } finally {
        await harness.close();
      }
    });

    testWidgets(
      'enabled support requires support student number before submit',
      (tester) async {
        final harness = await _Harness.create(supportStatus: 'enabled');

        try {
          await tester.pumpWidget(
            MaterialApp(
              home: StudentFormScreen(
                service: harness.service,
                halaqahId: harness.halaqahId,
                supportStatus: 'enabled',
              ),
            ),
          );

          await _fillCoreStudentFields(tester);

          await tester.ensureVisible(
            find.byKey(const Key('submit_student_button')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('submit_student_button')));
          await tester.pumpAndSettle();

          expect(
            find.text('رقم الجهة الداعمة مطلوب للطالب النشط بعد تفعيل الدعم.'),
            findsOneWidget,
          );

          var students = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(students, isEmpty);

          await tester.enterText(
            find.byKey(const Key('support_student_number_field')),
            'SUP-101',
          );

          await tester.ensureVisible(
            find.byKey(const Key('submit_student_button')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('submit_student_button')));
          await tester.pumpAndSettle();

          students = await harness.service.search(halaqahId: harness.halaqahId);

          expect(students, hasLength(1));
          expect(students.single.supportStudentNumber, 'SUP-101');
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets(
      'edit preloads existing student and saves through StudentService',
      (tester) async {
        final harness = await _Harness.create(
          supportStatus: 'pending_activation',
        );

        try {
          final original = await harness.service.create(
            CreateStudentRequest(
              halaqahId: harness.halaqahId,
              studentName: 'أحمد',
              fatherName: 'محمد',
              ageYears: 10,
              guardianCountry: GuardianPhoneCountry.yemen,
              guardianPhoneInput: '771234567',
              previousMemorizationText: 'جزء عم',
              note: 'قديم',
              supportStudentNumber: 'SUP-10',
            ),
          );

          await tester.pumpWidget(
            MaterialApp(
              home: StudentFormScreen(
                service: harness.service,
                halaqahId: harness.halaqahId,
                supportStatus: 'pending_activation',
                student: original,
              ),
            ),
          );

          final nameField = tester.widget<TextFormField>(
            find.byKey(const Key('student_name_field')),
          );

          final supportField = tester.widget<TextFormField>(
            find.byKey(const Key('support_student_number_field')),
          );

          expect(nameField.controller!.text, 'أحمد');
          expect(supportField.controller!.text, 'SUP-10');
          expect(find.text('تعديل الطالب'), findsOneWidget);

          await tester.enterText(
            find.byKey(const Key('student_name_field')),
            'أحمد المعدل',
          );

          await tester.enterText(find.byKey(const Key('note_field')), 'محدث');

          await tester.ensureVisible(
            find.byKey(const Key('submit_student_button')),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('submit_student_button')));
          await tester.pumpAndSettle();

          final students = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(students, hasLength(1));
          expect(students.single.id, original.id);
          expect(students.single.studentName, 'أحمد المعدل');
          expect(students.single.note, 'محدث');
          expect(students.single.supportStudentNumber, 'SUP-10');
        } finally {
          await harness.close();
        }
      },
    );
  });
}

Future<void> _fillCoreStudentFields(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('student_name_field')), ' أحمد ');

  await tester.enterText(find.byKey(const Key('father_name_field')), ' محمد ');

  await tester.enterText(find.byKey(const Key('age_field')), '10');

  await tester.enterText(
    find.byKey(const Key('guardian_phone_field')),
    '0771234567',
  );

  await tester.enterText(
    find.byKey(const Key('previous_memorization_field')),
    ' جزء عم ',
  );

  await tester.enterText(find.byKey(const Key('note_field')), ' ملاحظة ');
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

  static Future<_Harness> create({required String supportStatus}) async {
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
            status: supportStatus,
            organizationName: Value<String?>(
              supportStatus == 'disabled' ? null : 'الجهة الداعمة',
            ),
            createdAtUtc: now,
            updatedAtUtc: now,
          ),
        );

    return _Harness(
      database: database,
      halaqahId: halaqahId,
      service: StudentService(
        repository: DriftStudentRepository(database),
        phoneNumberPolicy: const PhoneNumberPolicy(),
        clock: const SystemClock(),
      ),
    );
  }

  Future<void> close() => database.close();
}
