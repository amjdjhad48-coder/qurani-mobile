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
import 'package:qurani/features/students/presentation/archived_students_screen.dart';
import 'package:qurani/features/students/presentation/students_list_screen.dart';

void main() {
  group('ArchivedStudentsScreen', () {
    testWidgets('shows archived students only and searches them by name', (
      tester,
    ) async {
      _configureView(tester);

      final harness = await _Harness.create();

      try {
        await harness.createStudent(name: 'علي النشط');

        final archivedCandidate = await harness.createStudent(
          name: 'أحمد المؤرشف',
        );

        await harness.service.archive(archivedCandidate.id);

        await tester.pumpWidget(
          MaterialApp(
            home: ArchivedStudentsScreen(
              service: harness.service,
              halaqahId: harness.halaqahId,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('archived_students_screen')),
          findsOneWidget,
        );

        expect(find.text('أحمد المؤرشف'), findsOneWidget);

        expect(find.text('علي النشط'), findsNothing);

        await tester.enterText(
          find.byKey(const Key('archived_students_search_field')),
          'أحمد',
        );

        await tester.pumpAndSettle();

        expect(find.text('أحمد المؤرشف'), findsOneWidget);

        expect(find.byKey(const Key('archived_students_list')), findsOneWidget);
      } finally {
        await harness.close();
      }
    });

    testWidgets(
      'main list opens archive, profile reactivation removes student from archive and refreshes active list',
      (tester) async {
        _configureView(tester);

        final harness = await _Harness.create();

        try {
          await harness.createStudent(name: 'علي النشط');

          final archivedCandidate = await harness.createStudent(
            name: 'أحمد المؤرشف',
          );

          final archived = await harness.service.archive(archivedCandidate.id);

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

          expect(find.text('علي النشط'), findsOneWidget);

          expect(find.text('أحمد المؤرشف'), findsNothing);

          await tester.tap(find.byKey(const Key('archived_students_button')));

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('archived_students_screen')),
            findsOneWidget,
          );

          expect(find.text('أحمد المؤرشف'), findsOneWidget);

          await tester.tap(
            find.byKey(ValueKey<String>('archived_student_${archived.id}')),
          );

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('student_profile_screen')),
            findsOneWidget,
          );

          final reactivateButton = find.byKey(
            const Key('reactivate_student_button'),
          );

          await tester.ensureVisible(reactivateButton);
          await tester.pumpAndSettle();

          await tester.tap(reactivateButton);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('reactivate_student_dialog')),
            findsOneWidget,
          );

          await tester.tap(
            find.byKey(const Key('confirm_reactivate_student_button')),
          );

          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('archive_student_button')),
            findsOneWidget,
          );

          await tester.pageBack();
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('archived_students_screen')),
            findsOneWidget,
          );

          expect(find.text('أحمد المؤرشف'), findsNothing);

          expect(
            find.byKey(const Key('archived_students_empty_state')),
            findsOneWidget,
          );

          await tester.pageBack();
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('students_list_screen')), findsOneWidget);

          expect(find.text('علي النشط'), findsOneWidget);

          expect(find.text('أحمد المؤرشف'), findsOneWidget);

          final active = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(active, hasLength(2));
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

  Future<StudentRecord> createStudent({required String name}) {
    return service.create(
      CreateStudentRequest(
        halaqahId: halaqahId,
        studentName: name,
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
