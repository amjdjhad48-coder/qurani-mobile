import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';
import 'package:qurani/features/students/domain/student.dart';

void main() {
  group('Student progress plan', () {
    test('student without progress plan returns null', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final studentId = await _insertStudent(database);

        final result = await _service(database).getProgressPlan(studentId);

        expect(result, isNull);
      } finally {
        await database.close();
      }
    });

    test('saves current juz and trimmed daily plan', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final studentId = await _insertStudent(database);

        final saved = await _service(database).updateProgressPlan(
          UpdateStudentProgressPlanRequest(
            studentId: studentId,
            currentJuz: 7,
            dailyPlanText: '  نصف صفحة يوميًا  ',
          ),
        );

        expect(saved.studentId, studentId);
        expect(saved.currentJuz, 7);
        expect(saved.dailyPlanText, 'نصف صفحة يوميًا');

        final stored = await database
            .select(database.studentProgressPlans)
            .getSingle();

        expect(stored.currentJuz, 7);
        expect(stored.dailyPlanText, 'نصف صفحة يوميًا');
      } finally {
        await database.close();
      }
    });

    test('supports current juz without daily plan', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final studentId = await _insertStudent(database);

        final saved = await _service(database).updateProgressPlan(
          UpdateStudentProgressPlanRequest(
            studentId: studentId,
            currentJuz: 30,
          ),
        );

        expect(saved.currentJuz, 30);
        expect(saved.dailyPlanText, isNull);
      } finally {
        await database.close();
      }
    });

    test('supports daily plan without current juz', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final studentId = await _insertStudent(database);

        final saved = await _service(database).updateProgressPlan(
          UpdateStudentProgressPlanRequest(
            studentId: studentId,
            dailyPlanText: 'وجه يوميًا',
          ),
        );

        expect(saved.currentJuz, isNull);
        expect(saved.dailyPlanText, 'وجه يوميًا');
      } finally {
        await database.close();
      }
    });

    test('empty optional daily plan is stored as null', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final studentId = await _insertStudent(database);

        final saved = await _service(database).updateProgressPlan(
          UpdateStudentProgressPlanRequest(
            studentId: studentId,
            currentJuz: 1,
            dailyPlanText: '   ',
          ),
        );

        expect(saved.currentJuz, 1);
        expect(saved.dailyPlanText, isNull);
      } finally {
        await database.close();
      }
    });

    test(
      'update replaces same student progress row instead of duplicating',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final studentId = await _insertStudent(database);
          final service = _service(database);

          await service.updateProgressPlan(
            UpdateStudentProgressPlanRequest(
              studentId: studentId,
              currentJuz: 4,
              dailyPlanText: 'خطة أولى',
            ),
          );

          final updated = await service.updateProgressPlan(
            UpdateStudentProgressPlanRequest(
              studentId: studentId,
              currentJuz: 5,
              dailyPlanText: 'خطة ثانية',
            ),
          );

          expect(updated.currentJuz, 5);
          expect(updated.dailyPlanText, 'خطة ثانية');

          final rows = await database
              .select(database.studentProgressPlans)
              .get();

          expect(rows, hasLength(1));
          expect(rows.single.studentId, studentId);
          expect(rows.single.currentJuz, 5);
        } finally {
          await database.close();
        }
      },
    );

    test('rejects current juz below 1 before database write', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final studentId = await _insertStudent(database);

        await expectLater(
          _service(database).updateProgressPlan(
            UpdateStudentProgressPlanRequest(
              studentId: studentId,
              currentJuz: 0,
            ),
          ),
          throwsArgumentError,
        );

        expect(
          await database.select(database.studentProgressPlans).get(),
          isEmpty,
        );
      } finally {
        await database.close();
      }
    });

    test('rejects current juz above 30 before database write', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final studentId = await _insertStudent(database);

        await expectLater(
          _service(database).updateProgressPlan(
            UpdateStudentProgressPlanRequest(
              studentId: studentId,
              currentJuz: 31,
            ),
          ),
          throwsArgumentError,
        );

        expect(
          await database.select(database.studentProgressPlans).get(),
          isEmpty,
        );
      } finally {
        await database.close();
      }
    });

    test('rejects progress update for unknown student', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await expectLater(
          _service(database).updateProgressPlan(
            const UpdateStudentProgressPlanRequest(
              studentId: 999,
              currentJuz: 10,
            ),
          ),
          throwsStateError,
        );

        expect(
          await database.select(database.studentProgressPlans).get(),
          isEmpty,
        );
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

Future<int> _insertStudent(AppDatabase database) async {
  final now = DateTime.utc(2026, 9, 13);

  final halaqahId = await database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: 'معلم',
          halaqahName: 'حلقة',
          centerName: 'مركز',
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
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

  return database
      .into(database.students)
      .insert(
        StudentsCompanion.insert(
          halaqahId: halaqahId,
          studentName: 'طالب',
          fatherName: 'الأب',
          ageYears: 10,
          guardianCountryCode: '+967',
          guardianNationalNumber: '771234567',
          previousMemorizationText: 'حفظ سابق',
          displayOrder: 1,
        ),
      );
}
