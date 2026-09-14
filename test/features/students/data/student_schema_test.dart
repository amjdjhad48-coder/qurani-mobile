import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';

void main() {
  group('Package 3 student schema', () {
    test('persists required student identity fields', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);

        final studentId = await database
            .into(database.students)
            .insert(
              StudentsCompanion.insert(
                halaqahId: halaqahId,
                studentName: 'محمد أحمد',
                fatherName: 'أحمد',
                ageYears: 12,
                guardianCountryCode: '+967',
                guardianNationalNumber: '771234567',
                previousMemorizationText: 'جزء عم',
                note: const Value<String?>('ملاحظة'),
                supportStudentNumber: const Value<String?>('SUP-001'),
                displayOrder: 1,
              ),
            );

        final student = await (database.select(
          database.students,
        )..where((table) => table.id.equals(studentId))).getSingle();

        expect(student.studentName, 'محمد أحمد');
        expect(student.fatherName, 'أحمد');
        expect(student.ageYears, 12);
        expect(student.guardianCountryCode, '+967');
        expect(student.guardianNationalNumber, '771234567');
        expect(student.previousMemorizationText, 'جزء عم');
        expect(student.note, 'ملاحظة');
        expect(student.supportStudentNumber, 'SUP-001');
        expect(student.displayOrder, 1);
        expect(student.isActive, isTrue);
        expect(student.archivedAtUtc, isNull);
      } finally {
        await database.close();
      }
    });

    test(
      'requires non-empty core text fields and approved country codes',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database);

          await expectLater(
            database
                .into(database.students)
                .insert(
                  StudentsCompanion.insert(
                    halaqahId: halaqahId,
                    studentName: '',
                    fatherName: 'أب',
                    ageYears: 10,
                    guardianCountryCode: '+967',
                    guardianNationalNumber: '771234567',
                    previousMemorizationText: 'لا شيء',
                    displayOrder: 1,
                  ),
                ),
            throwsA(anything),
          );

          await expectLater(
            database
                .into(database.students)
                .insert(
                  StudentsCompanion.insert(
                    halaqahId: halaqahId,
                    studentName: 'طالب',
                    fatherName: '',
                    ageYears: 10,
                    guardianCountryCode: '+967',
                    guardianNationalNumber: '771234567',
                    previousMemorizationText: 'لا شيء',
                    displayOrder: 2,
                  ),
                ),
            throwsA(anything),
          );

          await expectLater(
            database
                .into(database.students)
                .insert(
                  StudentsCompanion.insert(
                    halaqahId: halaqahId,
                    studentName: 'طالب',
                    fatherName: 'أب',
                    ageYears: 10,
                    guardianCountryCode: '+971',
                    guardianNationalNumber: '501234567',
                    previousMemorizationText: 'لا شيء',
                    displayOrder: 3,
                  ),
                ),
            throwsA(anything),
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'support student number is unique inside the halaqah when present',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database);

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            suffix: '1',
            displayOrder: 1,
            supportStudentNumber: 'SUP-100',
          );

          await expectLater(
            _insertStudent(
              database,
              halaqahId: halaqahId,
              suffix: '2',
              displayOrder: 2,
              supportStudentNumber: 'SUP-100',
            ),
            throwsA(anything),
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            suffix: '3',
            displayOrder: 3,
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            suffix: '4',
            displayOrder: 4,
          );
        } finally {
          await database.close();
        }
      },
    );

    test('progress current juz accepts only 1 through 30 or null', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);

        final student1 = await _insertStudent(
          database,
          halaqahId: halaqahId,
          suffix: '1',
          displayOrder: 1,
        );

        await database
            .into(database.studentProgressPlans)
            .insert(
              StudentProgressPlansCompanion.insert(
                studentId: Value<int>(student1),
                currentJuz: const Value<int?>(1),
                dailyPlanText: const Value<String?>('وجه واحد حسب القدرة'),
              ),
            );

        final student2 = await _insertStudent(
          database,
          halaqahId: halaqahId,
          suffix: '2',
          displayOrder: 2,
        );

        await database
            .into(database.studentProgressPlans)
            .insert(
              StudentProgressPlansCompanion.insert(
                studentId: Value<int>(student2),
                currentJuz: const Value<int?>(30),
              ),
            );

        final student3 = await _insertStudent(
          database,
          halaqahId: halaqahId,
          suffix: '3',
          displayOrder: 3,
        );

        await expectLater(
          database
              .into(database.studentProgressPlans)
              .insert(
                StudentProgressPlansCompanion.insert(
                  studentId: Value<int>(student3),
                  currentJuz: const Value<int?>(0),
                ),
              ),
          throwsA(anything),
        );

        final student4 = await _insertStudent(
          database,
          halaqahId: halaqahId,
          suffix: '4',
          displayOrder: 4,
        );

        await expectLater(
          database
              .into(database.studentProgressPlans)
              .insert(
                StudentProgressPlansCompanion.insert(
                  studentId: Value<int>(student4),
                  currentJuz: const Value<int?>(31),
                ),
              ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });

    test('activity period end cannot be before its start', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqah(database);

        final student1 = await _insertStudent(
          database,
          halaqahId: halaqahId,
          suffix: '1',
          displayOrder: 1,
        );

        await database
            .into(database.studentActivityPeriods)
            .insert(
              StudentActivityPeriodsCompanion.insert(
                studentId: student1,
                activeFromDate: '2026-09-01',
                activeToDate: const Value<String?>('2026-09-01'),
              ),
            );

        final student2 = await _insertStudent(
          database,
          halaqahId: halaqahId,
          suffix: '2',
          displayOrder: 2,
        );

        await expectLater(
          database
              .into(database.studentActivityPeriods)
              .insert(
                StudentActivityPeriodsCompanion.insert(
                  studentId: student2,
                  activeFromDate: '2026-09-10',
                  activeToDate: const Value<String?>('2026-09-09'),
                ),
              ),
          throwsA(anything),
        );
      } finally {
        await database.close();
      }
    });
  });
}

Future<int> _insertHalaqah(AppDatabase database, {String suffix = ''}) {
  final now = DateTime.utc(2026, 9, 6, 18);

  return database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: 'معلم$suffix',
          halaqahName: 'حلقة$suffix',
          centerName: 'مركز$suffix',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
}

Future<int> _insertStudent(
  AppDatabase database, {
  required int halaqahId,
  required String suffix,
  required int displayOrder,
  String? supportStudentNumber,
}) {
  final base = StudentsCompanion.insert(
    halaqahId: halaqahId,
    studentName: 'طالب$suffix',
    fatherName: 'أب$suffix',
    ageYears: 10,
    guardianCountryCode: '+967',
    guardianNationalNumber: '77123456$suffix',
    previousMemorizationText: 'حفظ سابق',
    supportStudentNumber: supportStudentNumber == null
        ? const Value<String?>.absent()
        : Value<String?>(supportStudentNumber),
    displayOrder: displayOrder,
  );

  return database.into(database.students).insert(base);
}
