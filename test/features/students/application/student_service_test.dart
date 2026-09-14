import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/student_service.dart';
import 'package:qurani/features/students/data/drift_student_repository.dart';
import 'package:qurani/features/students/domain/phone_number_policy.dart';
import 'package:qurani/features/students/domain/student.dart';

void main() {
  group('StudentService + DriftStudentRepository', () {
    test('create normalizes phone and opens initial activity period', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqahWithSupport(
          database,
          status: 'disabled',
        );

        final service = _service(database);

        final student = await service.create(
          CreateStudentRequest(
            halaqahId: halaqahId,
            studentName: '  محمد أحمد  ',
            fatherName: '  أحمد  ',
            ageYears: 12,
            guardianCountry: GuardianPhoneCountry.yemen,
            guardianPhoneInput: '٠٧٧١٢٣٤٥٦٧',
            previousMemorizationText: '  جزء عم  ',
            note: '  ملاحظة  ',
          ),
        );

        expect(student.studentName, 'محمد أحمد');
        expect(student.fatherName, 'أحمد');
        expect(student.guardianCountryCode, '+967');
        expect(student.guardianNationalNumber, '771234567');
        expect(student.previousMemorizationText, 'جزء عم');
        expect(student.note, 'ملاحظة');
        expect(student.isActive, isTrue);
        expect(student.archivedAtUtc, isNull);

        final periods = await (database.select(
          database.studentActivityPeriods,
        )..where((table) => table.studentId.equals(student.id))).get();

        expect(periods, hasLength(1));
        expect(periods.single.activeFromDate, '2026-09-13');
        expect(periods.single.activeToDate, isNull);
      } finally {
        await database.close();
      }
    });

    test('new students receive persistent increasing display order', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqahWithSupport(
          database,
          status: 'disabled',
        );

        final service = _service(database);

        final first = await service.create(
          _createRequest(halaqahId: halaqahId, suffix: '1'),
        );

        final second = await service.create(
          CreateStudentRequest(
            halaqahId: halaqahId,
            studentName: 'طالب2',
            fatherName: 'أب2',
            ageYears: 11,
            guardianCountry: GuardianPhoneCountry.saudiArabia,
            guardianPhoneInput: '0551234567',
            previousMemorizationText: 'حفظ سابق',
          ),
        );

        expect(second.displayOrder, first.displayOrder + 1);
        expect(second.guardianCountryCode, '+966');
        expect(second.guardianNationalNumber, '551234567');
      } finally {
        await database.close();
      }
    });

    test(
      'edit changes student data without changing activity history or order',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'disabled',
          );

          final service = _service(database);

          final created = await service.create(
            _createRequest(halaqahId: halaqahId, suffix: '1'),
          );

          final edited = await service.edit(
            EditStudentRequest(
              studentId: created.id,
              studentName: 'الاسم الجديد',
              fatherName: 'الأب الجديد',
              ageYears: 13,
              guardianCountry: GuardianPhoneCountry.saudiArabia,
              guardianPhoneInput: '+966551234567',
              previousMemorizationText: 'جزآن',
              note: '   ',
            ),
          );

          expect(edited.studentName, 'الاسم الجديد');
          expect(edited.fatherName, 'الأب الجديد');
          expect(edited.ageYears, 13);
          expect(edited.guardianCountryCode, '+966');
          expect(edited.guardianNationalNumber, '551234567');
          expect(edited.previousMemorizationText, 'جزآن');
          expect(edited.note, isNull);
          expect(edited.displayOrder, created.displayOrder);

          final periods = await (database.select(
            database.studentActivityPeriods,
          )..where((table) => table.studentId.equals(created.id))).get();

          expect(periods, hasLength(1));
          expect(periods.single.activeToDate, isNull);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'enabled support requires a support number for active student',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'enabled',
          );

          final service = _service(database);

          await expectLater(
            service.create(_createRequest(halaqahId: halaqahId, suffix: '1')),
            throwsArgumentError,
          );

          expect(await database.select(database.students).get(), isEmpty);
        } finally {
          await database.close();
        }
      },
    );

    test('enabled support accepts and trims issued support number', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final halaqahId = await _insertHalaqahWithSupport(
          database,
          status: 'enabled',
        );

        final service = _service(database);

        final student = await service.create(
          CreateStudentRequest(
            halaqahId: halaqahId,
            studentName: 'طالب',
            fatherName: 'أب',
            ageYears: 10,
            guardianCountry: GuardianPhoneCountry.yemen,
            guardianPhoneInput: '771234567',
            previousMemorizationText: 'حفظ سابق',
            supportStudentNumber: '  SUP-100  ',
          ),
        );

        expect(student.supportStudentNumber, 'SUP-100');
      } finally {
        await database.close();
      }
    });

    test(
      'pending activation allows active student without support number',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'pending_activation',
          );

          final student = await _service(
            database,
          ).create(_createRequest(halaqahId: halaqahId, suffix: '1'));

          expect(student.isActive, isTrue);
          expect(student.supportStudentNumber, isNull);
        } finally {
          await database.close();
        }
      },
    );

    test('edit rejects unknown student id', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await expectLater(
          _service(database).edit(
            const EditStudentRequest(
              studentId: 999,
              studentName: 'طالب',
              fatherName: 'أب',
              ageYears: 10,
              guardianCountry: GuardianPhoneCountry.yemen,
              guardianPhoneInput: '771234567',
              previousMemorizationText: 'حفظ سابق',
            ),
          ),
          throwsStateError,
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
    clock: _FixedClock(DateTime.utc(2026, 9, 13, 12), DateTime(2026, 9, 13)),
  );
}

CreateStudentRequest _createRequest({
  required int halaqahId,
  required String suffix,
}) {
  return CreateStudentRequest(
    halaqahId: halaqahId,
    studentName: 'طالب$suffix',
    fatherName: 'أب$suffix',
    ageYears: 10,
    guardianCountry: GuardianPhoneCountry.yemen,
    guardianPhoneInput: '771234567',
    previousMemorizationText: 'حفظ سابق',
  );
}

Future<int> _insertHalaqahWithSupport(
  AppDatabase database, {
  required String status,
}) async {
  final now = DateTime.utc(2026, 9, 13, 12);

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
          status: status,
          organizationName: status == 'disabled'
              ? const Value<String?>(null)
              : const Value<String?>('الجهة'),
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

  return halaqahId;
}

final class _FixedClock implements Clock {
  const _FixedClock(this._nowUtc, this._todayLocal);

  final DateTime _nowUtc;
  final DateTime _todayLocal;

  @override
  DateTime nowUtc() => _nowUtc;

  @override
  DateTime todayLocal() => _todayLocal;
}
