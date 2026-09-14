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
import 'package:qurani/features/students/presentation/students_list_screen.dart';

void main() {
  group('Students add flow', () {
    testWidgets(
      'add button opens form, saves student, and refreshes active list',
      (tester) async {
        final harness = await _Harness.create(supportStatus: 'disabled');

        try {
          await _pumpList(tester, harness);

          expect(find.byKey(const Key('add_student_button')), findsOneWidget);

          await tester.tap(find.byKey(const Key('add_student_button')));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('student_form_screen')), findsOneWidget);

          await tester.enterText(
            find.byKey(const Key('student_name_field')),
            'أحمد',
          );

          await tester.enterText(
            find.byKey(const Key('father_name_field')),
            'محمد',
          );

          await tester.enterText(find.byKey(const Key('age_field')), '10');

          await tester.enterText(
            find.byKey(const Key('guardian_phone_field')),
            '0771234567',
          );

          await tester.enterText(
            find.byKey(const Key('previous_memorization_field')),
            'جزء عم',
          );

          final submit = find.byKey(const Key('submit_student_button'));

          await tester.ensureVisible(submit);
          await tester.pumpAndSettle();
          await tester.tap(submit);
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('students_list_screen')), findsOneWidget);

          expect(find.text('أحمد'), findsOneWidget);

          final students = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(students, hasLength(1));
          expect(students.single.studentName, 'أحمد');
          expect(students.single.fatherName, 'محمد');
          expect(students.single.guardianCountryCode, '+967');
          expect(students.single.guardianNationalNumber, '771234567');
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets('add flow reads enabled support status before opening form', (
      tester,
    ) async {
      final harness = await _Harness.create(supportStatus: 'enabled');

      try {
        await _pumpList(tester, harness);

        await tester.tap(find.byKey(const Key('add_student_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('student_form_screen')), findsOneWidget);

        expect(
          find.byKey(const Key('support_student_number_field')),
          findsOneWidget,
        );
      } finally {
        await harness.close();
      }
    });
  });
}

Future<void> _pumpList(WidgetTester tester, _Harness harness) async {
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

    final service = StudentService(
      repository: DriftStudentRepository(database),
      phoneNumberPolicy: const PhoneNumberPolicy(),
      clock: const SystemClock(),
    );

    return _Harness(database: database, halaqahId: halaqahId, service: service);
  }

  Future<void> close() => database.close();
}
