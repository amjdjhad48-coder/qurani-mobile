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
  group('StudentsListScreen', () {
    testWidgets('shows active students only and searches by support number', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);

        await _insertStudent(
          database,
          halaqahId: halaqahId,
          name: 'علي',
          displayOrder: 1,
        );

        await _insertStudent(
          database,
          halaqahId: halaqahId,
          name: 'أحمد',
          displayOrder: 2,
          supportNumber: 'SUP-200',
        );

        await _insertStudent(
          database,
          halaqahId: halaqahId,
          name: 'طالب مؤرشف',
          displayOrder: 3,
          archived: true,
        );

        final runtimeContext = StudentRuntimeContext(
          halaqahId: halaqahId,
          service: StudentService(
            repository: DriftStudentRepository(database),
            phoneNumberPolicy: const PhoneNumberPolicy(),
            clock: const SystemClock(),
          ),
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

        expect(find.text('علي'), findsOneWidget);
        expect(find.text('أحمد'), findsOneWidget);
        expect(find.text('طالب مؤرشف'), findsNothing);
        expect(find.byKey(const Key('students_active_list')), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('students_search_field')),
          'SUP-200',
        );
        await tester.pumpAndSettle();

        expect(find.text('أحمد'), findsOneWidget);
        expect(find.text('علي'), findsNothing);
        expect(
          find.byKey(const Key('students_search_results')),
          findsOneWidget,
        );
      } finally {
        await database.close();
      }
    });

    testWidgets('preserves runtime change-PIN and explicit-lock controls', (
      tester,
    ) async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);

        var changePinCalls = 0;
        var lockCalls = 0;

        final runtimeContext = StudentRuntimeContext(
          halaqahId: halaqahId,
          service: StudentService(
            repository: DriftStudentRepository(database),
            phoneNumberPolicy: const PhoneNumberPolicy(),
            clock: const SystemClock(),
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              studentRuntimeContextProvider.overrideWith(
                (ref) async => runtimeContext,
              ),
            ],
            child: MaterialApp(
              home: StudentsListScreen(
                onChangePin: () {
                  changePinCalls += 1;
                },
                onLockNow: () {
                  lockCalls += 1;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('change_pin_button')));
        await tester.tap(find.byKey(const Key('lock_now_button')));

        expect(changePinCalls, 1);
        expect(lockCalls, 1);
      } finally {
        await database.close();
      }
    });
  });
}

Future<int> _insertHalaqah(AppDatabase database) {
  final now = DateTime.utc(2026, 9, 13);

  return database
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
}

Future<int> _insertStudent(
  AppDatabase database, {
  required int halaqahId,
  required String name,
  required int displayOrder,
  String? supportNumber,
  bool archived = false,
}) {
  return database
      .into(database.students)
      .insert(
        StudentsCompanion.insert(
          halaqahId: halaqahId,
          studentName: name,
          fatherName: 'الأب',
          ageYears: 10,
          guardianCountryCode: '+967',
          guardianNationalNumber: '771234567',
          previousMemorizationText: 'حفظ سابق',
          supportStudentNumber: Value<String?>(supportNumber),
          displayOrder: displayOrder,
          isActive: Value<bool>(!archived),
          archivedAtUtc: Value<DateTime?>(
            archived ? DateTime.utc(2026, 9, 13) : null,
          ),
        ),
      );
}
