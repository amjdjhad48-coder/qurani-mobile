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
  group('StudentProfileScreen lifecycle', () {
    testWidgets('shows current activity period history', (tester) async {
      _configureView(tester);

      final harness = await _Harness.create();

      try {
        final student = await harness.createStudent();

        await _pumpProfile(tester, harness: harness, student: student);

        expect(
          find.byKey(const Key('student_activity_history')),
          findsOneWidget,
        );

        expect(find.text('من 2026-09-14 إلى حتى الآن'), findsOneWidget);
      } finally {
        await harness.close();
      }
    });

    testWidgets(
      'archive requires confirmation, closes activity period, and updates profile',
      (tester) async {
        _configureView(tester);

        final harness = await _Harness.create();

        try {
          final student = await harness.createStudent();

          await _pumpProfile(tester, harness: harness, student: student);

          final archiveButton = find.byKey(const Key('archive_student_button'));

          await tester.ensureVisible(archiveButton);
          await tester.pumpAndSettle();

          await tester.tap(archiveButton);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('archive_student_dialog')),
            findsOneWidget,
          );

          await tester.tap(
            find.byKey(const Key('cancel_archive_student_button')),
          );
          await tester.pumpAndSettle();

          var activeStudents = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(activeStudents, hasLength(1));

          await tester.tap(archiveButton);
          await tester.pumpAndSettle();

          await tester.tap(
            find.byKey(const Key('confirm_archive_student_button')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('reactivate_student_button')),
            findsOneWidget,
          );

          expect(find.text('مؤرشف'), findsOneWidget);

          activeStudents = await harness.service.search(
            halaqahId: harness.halaqahId,
          );

          expect(activeStudents, isEmpty);

          final periods = await harness.service.activityPeriodsForStudent(
            student.id,
          );

          expect(periods, hasLength(1));
          expect(periods.single.isOpen, isFalse);
          expect(periods.single.activeToDate, '2026-09-14');

          expect(find.text('من 2026-09-14 إلى 2026-09-14'), findsOneWidget);
        } finally {
          await harness.close();
        }
      },
    );

    testWidgets('same-day reactivation reopens the existing activity period', (
      tester,
    ) async {
      _configureView(tester);

      final harness = await _Harness.create();

      try {
        final created = await harness.createStudent();
        final archived = await harness.service.archive(created.id);

        final before = await harness.service.activityPeriodsForStudent(
          created.id,
        );

        expect(before, hasLength(1));
        expect(before.single.isOpen, isFalse);

        await _pumpProfile(tester, harness: harness, student: archived);

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

        expect(find.byKey(const Key('archive_student_button')), findsOneWidget);

        expect(find.text('نشط'), findsOneWidget);

        final activeStudents = await harness.service.search(
          halaqahId: harness.halaqahId,
        );

        expect(activeStudents, hasLength(1));

        final after = await harness.service.activityPeriodsForStudent(
          created.id,
        );

        expect(after, hasLength(1));
        expect(after.single.id, before.single.id);
        expect(after.single.isOpen, isTrue);

        expect(find.text('من 2026-09-14 إلى حتى الآن'), findsOneWidget);
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
        note: 'ملاحظة الطالب',
      ),
    );
  }

  Future<void> close() => database.close();
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
