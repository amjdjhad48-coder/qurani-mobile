import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';

void main() {
  group('Student search', () {
    test(
      'blank search returns active students in persisted display order',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, 'A');

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الثاني',
            displayOrder: 2,
            supportNumber: 'SUP-2',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الأول',
            displayOrder: 1,
            supportNumber: 'SUP-1',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'مؤرشف',
            displayOrder: 3,
            isActive: false,
          );

          final results = await _service(database).search(halaqahId: halaqahId);

          expect(
            results.map((student) => student.studentName).toList(),
            <String>['الأول', 'الثاني'],
          );
        } finally {
          await database.close();
        }
      },
    );

    test('search finds active student by partial name', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database, 'A');

        await _insertStudent(
          database,
          halaqahId: halaqahId,
          name: 'محمد أحمد',
          displayOrder: 1,
          supportNumber: 'SUP-10',
        );

        await _insertStudent(
          database,
          halaqahId: halaqahId,
          name: 'خالد علي',
          displayOrder: 2,
          supportNumber: 'SUP-20',
        );

        final results = await _service(
          database,
        ).search(halaqahId: halaqahId, query: '  أحمد  ');

        expect(results, hasLength(1));
        expect(results.single.studentName, 'محمد أحمد');
      } finally {
        await database.close();
      }
    });

    test('search finds student by support organization number', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database, 'A');

        await _insertStudent(
          database,
          halaqahId: halaqahId,
          name: 'طالب أول',
          displayOrder: 1,
          supportNumber: 'ORG-100',
        );

        await _insertStudent(
          database,
          halaqahId: halaqahId,
          name: 'طالب ثان',
          displayOrder: 2,
          supportNumber: 'ORG-7755',
        );

        final results = await _service(
          database,
        ).search(halaqahId: halaqahId, query: '7755');

        expect(results, hasLength(1));
        expect(results.single.studentName, 'طالب ثان');
        expect(results.single.supportStudentNumber, 'ORG-7755');
      } finally {
        await database.close();
      }
    });

    test(
      'archived students are excluded by default and available when requested',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, 'A');

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'طالب مؤرشف',
            displayOrder: 1,
            supportNumber: 'ARC-1',
            isActive: false,
          );

          final normalResults = await _service(
            database,
          ).search(halaqahId: halaqahId, query: 'طالب مؤرشف');

          expect(normalResults, isEmpty);

          final archivedResults = await _service(database).search(
            halaqahId: halaqahId,
            query: 'طالب مؤرشف',
            includeArchived: true,
          );

          expect(archivedResults, hasLength(1));
          expect(archivedResults.single.isActive, isFalse);
        } finally {
          await database.close();
        }
      },
    );

    test('search is isolated to the requested halaqah', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final firstHalaqah = await _insertHalaqah(database, 'A');
        final secondHalaqah = await _insertHalaqah(database, 'B');

        await _insertStudent(
          database,
          halaqahId: firstHalaqah,
          name: 'طالب مشترك',
          displayOrder: 1,
          supportNumber: 'A-1',
        );

        await _insertStudent(
          database,
          halaqahId: secondHalaqah,
          name: 'طالب مشترك',
          displayOrder: 1,
          supportNumber: 'B-1',
        );

        final results = await _service(
          database,
        ).search(halaqahId: firstHalaqah, query: 'طالب مشترك');

        expect(results, hasLength(1));
        expect(results.single.halaqahId, firstHalaqah);
        expect(results.single.supportStudentNumber, 'A-1');
      } finally {
        await database.close();
      }
    });
  });
}

StudentService _service(AppDatabase database) {
  return StudentService(
    repository: DriftStudentRepository(database),
    phoneNumberPolicy: const PhoneNumberPolicy(),
    clock: const SystemClock(),
  );
}

Future<int> _insertHalaqah(AppDatabase database, String suffix) {
  final now = DateTime.utc(2026, 9, 13);

  return database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: 'معلم $suffix',
          halaqahName: 'حلقة $suffix',
          centerName: 'مركز $suffix',
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
  bool isActive = true,
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
          isActive: Value<bool>(isActive),
          archivedAtUtc: Value<DateTime?>(
            isActive ? null : DateTime.utc(2026, 9, 12),
          ),
        ),
      );
}
