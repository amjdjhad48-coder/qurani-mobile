import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';

void main() {
  group('Student ordering', () {
    test(
      'reorder persists contiguous active display order transactionally',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, 'A');

          final first = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الأول',
            displayOrder: 1,
          );

          final second = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الثاني',
            displayOrder: 2,
          );

          final third = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الثالث',
            displayOrder: 3,
          );

          final reordered = await _service(database).reorderActiveStudents(
            halaqahId: halaqahId,
            orderedStudentIds: <int>[third, first, second],
          );

          expect(reordered.map((student) => student.id).toList(), <int>[
            third,
            first,
            second,
          ]);

          expect(
            reordered.map((student) => student.displayOrder).toList(),
            <int>[1, 2, 3],
          );

          final searchResults = await _service(
            database,
          ).search(halaqahId: halaqahId);

          expect(searchResults.map((student) => student.id).toList(), <int>[
            third,
            first,
            second,
          ]);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'reorder rejects duplicate ids without changing stored order',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, 'A');

          final first = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الأول',
            displayOrder: 1,
          );

          final second = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الثاني',
            displayOrder: 2,
          );

          await expectLater(
            _service(database).reorderActiveStudents(
              halaqahId: halaqahId,
              orderedStudentIds: <int>[first, first],
            ),
            throwsArgumentError,
          );

          final stored = await _service(database).search(halaqahId: halaqahId);

          expect(stored.map((student) => student.id).toList(), <int>[
            first,
            second,
          ]);

          expect(stored.map((student) => student.displayOrder).toList(), <int>[
            1,
            2,
          ]);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'reorder rejects missing active student without partial write',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, 'A');

          final first = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الأول',
            displayOrder: 1,
          );

          final second = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الثاني',
            displayOrder: 2,
          );

          final third = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الثالث',
            displayOrder: 3,
          );

          await expectLater(
            _service(database).reorderActiveStudents(
              halaqahId: halaqahId,
              orderedStudentIds: <int>[third, first],
            ),
            throwsArgumentError,
          );

          final stored = await _service(database).search(halaqahId: halaqahId);

          expect(stored.map((student) => student.id).toList(), <int>[
            first,
            second,
            third,
          ]);
        } finally {
          await database.close();
        }
      },
    );

    test('reorder rejects student from another halaqah', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final firstHalaqah = await _insertHalaqah(database, 'A');
        final secondHalaqah = await _insertHalaqah(database, 'B');

        final first = await _insertStudent(
          database,
          halaqahId: firstHalaqah,
          name: 'الأول',
          displayOrder: 1,
        );

        final second = await _insertStudent(
          database,
          halaqahId: firstHalaqah,
          name: 'الثاني',
          displayOrder: 2,
        );

        final foreign = await _insertStudent(
          database,
          halaqahId: secondHalaqah,
          name: 'أجنبي',
          displayOrder: 1,
        );

        await expectLater(
          _service(database).reorderActiveStudents(
            halaqahId: firstHalaqah,
            orderedStudentIds: <int>[foreign, first],
          ),
          throwsArgumentError,
        );

        final stored = await _service(database).search(halaqahId: firstHalaqah);

        expect(stored.map((student) => student.id).toList(), <int>[
          first,
          second,
        ]);
      } finally {
        await database.close();
      }
    });

    test(
      'archived student is not part of active drag order and keeps its value',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, 'A');

          final first = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الأول',
            displayOrder: 1,
          );

          final archived = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'مؤرشف',
            displayOrder: 50,
            isActive: false,
          );

          final second = await _insertStudent(
            database,
            halaqahId: halaqahId,
            name: 'الثاني',
            displayOrder: 2,
          );

          await _service(database).reorderActiveStudents(
            halaqahId: halaqahId,
            orderedStudentIds: <int>[second, first],
          );

          final archivedRow = await (database.select(
            database.students,
          )..where((table) => table.id.equals(archived))).getSingle();

          expect(archivedRow.isActive, isFalse);
          expect(archivedRow.displayOrder, 50);

          final active = await _service(database).search(halaqahId: halaqahId);

          expect(active.map((student) => student.id).toList(), <int>[
            second,
            first,
          ]);
        } finally {
          await database.close();
        }
      },
    );
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
          displayOrder: displayOrder,
          isActive: Value<bool>(isActive),
          archivedAtUtc: Value<DateTime?>(
            isActive ? null : DateTime.utc(2026, 9, 12),
          ),
        ),
      );
}
