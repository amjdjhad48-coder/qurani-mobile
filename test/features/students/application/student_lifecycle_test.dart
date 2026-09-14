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
  group('Student archive/reactivate lifecycle', () {
    test(
      'archive keeps student record and closes the open activity period',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, status: 'disabled');

          final clock = _MutableClock(DateTime.utc(2026, 9, 13, 12));

          final service = _service(database, clock);

          final created = await service.create(_request(halaqahId));

          final archived = await service.archive(created.id);

          expect(archived.id, created.id);
          expect(archived.isActive, isFalse);
          expect(archived.archivedAtUtc, DateTime.utc(2026, 9, 13, 12));

          final periods = await database
              .select(database.studentActivityPeriods)
              .get();

          expect(periods, hasLength(1));
          expect(periods.single.activeFromDate, '2026-09-13');
          expect(periods.single.activeToDate, '2026-09-13');
        } finally {
          await database.close();
        }
      },
    );

    test(
      'same-day reactivation reopens the same period instead of overlapping',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, status: 'disabled');

          final clock = _MutableClock(DateTime.utc(2026, 9, 13, 8));

          final service = _service(database, clock);

          final created = await service.create(_request(halaqahId));

          clock.now = DateTime.utc(2026, 9, 13, 10);
          await service.archive(created.id);

          clock.now = DateTime.utc(2026, 9, 13, 15);
          final reactivated = await service.reactivate(created.id);

          expect(reactivated.isActive, isTrue);
          expect(reactivated.archivedAtUtc, isNull);

          final periods = await database
              .select(database.studentActivityPeriods)
              .get();

          expect(periods, hasLength(1));
          expect(periods.single.activeFromDate, '2026-09-13');
          expect(periods.single.activeToDate, isNull);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'later reactivation opens a new period and preserves history',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, status: 'disabled');

          final clock = _MutableClock(DateTime.utc(2026, 9, 10, 8));

          final service = _service(database, clock);

          final created = await service.create(_request(halaqahId));

          clock.now = DateTime.utc(2026, 9, 11, 10);
          await service.archive(created.id);

          clock.now = DateTime.utc(2026, 9, 13, 9);
          final reactivated = await service.reactivate(created.id);

          expect(reactivated.isActive, isTrue);

          final periods =
              await database.select(database.studentActivityPeriods).get()
                ..sort((left, right) => left.id.compareTo(right.id));

          expect(periods, hasLength(2));

          expect(periods.first.activeFromDate, '2026-09-10');
          expect(periods.first.activeToDate, '2026-09-11');

          expect(periods.last.activeFromDate, '2026-09-13');
          expect(periods.last.activeToDate, isNull);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'enabled support blocks reactivation when support number is missing',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(
            database,
            status: 'enabled',
            organizationName: 'الجهة',
          );

          await database
              .into(database.supportProgramPeriods)
              .insert(
                SupportProgramPeriodsCompanion.insert(
                  halaqahId: halaqahId,
                  organizationName: 'الجهة',
                  startedAtUtc: DateTime.utc(2026, 9, 1),
                ),
              );

          final studentId = await database
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
                  isActive: const Value<bool>(false),
                  archivedAtUtc: Value<DateTime?>(DateTime.utc(2026, 9, 12)),
                ),
              );

          await database
              .into(database.studentActivityPeriods)
              .insert(
                StudentActivityPeriodsCompanion.insert(
                  studentId: studentId,
                  activeFromDate: '2026-09-01',
                  activeToDate: const Value<String?>('2026-09-12'),
                ),
              );

          final service = _service(
            database,
            _MutableClock(DateTime.utc(2026, 9, 13)),
          );

          await expectLater(service.reactivate(studentId), throwsArgumentError);

          final stored = await (database.select(
            database.students,
          )..where((table) => table.id.equals(studentId))).getSingle();

          expect(stored.isActive, isFalse);

          final periods = await database
              .select(database.studentActivityPeriods)
              .get();

          expect(periods, hasLength(1));
          expect(periods.single.activeToDate, '2026-09-12');
        } finally {
          await database.close();
        }
      },
    );

    test(
      'reactivation refuses inconsistent history with an existing open period',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqah(database, status: 'disabled');

          final studentId = await database
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
                  isActive: const Value<bool>(false),
                  archivedAtUtc: Value<DateTime?>(DateTime.utc(2026, 9, 12)),
                ),
              );

          await database
              .into(database.studentActivityPeriods)
              .insert(
                StudentActivityPeriodsCompanion.insert(
                  studentId: studentId,
                  activeFromDate: '2026-09-01',
                ),
              );

          await expectLater(
            _service(
              database,
              _MutableClock(DateTime.utc(2026, 9, 13)),
            ).reactivate(studentId),
            throwsStateError,
          );
        } finally {
          await database.close();
        }
      },
    );
  });
}

StudentService _service(AppDatabase database, _MutableClock clock) {
  return StudentService(
    repository: DriftStudentRepository(database),
    phoneNumberPolicy: const PhoneNumberPolicy(),
    clock: clock,
  );
}

CreateStudentRequest _request(int halaqahId) {
  return CreateStudentRequest(
    halaqahId: halaqahId,
    studentName: 'طالب',
    fatherName: 'الأب',
    ageYears: 10,
    guardianCountry: GuardianPhoneCountry.yemen,
    guardianPhoneInput: '771234567',
    previousMemorizationText: 'حفظ سابق',
  );
}

Future<int> _insertHalaqah(
  AppDatabase database, {
  required String status,
  String? organizationName,
}) async {
  final now = DateTime.utc(2026, 9, 1);

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
          organizationName: Value<String?>(organizationName),
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

  return halaqahId;
}

final class _MutableClock implements Clock {
  _MutableClock(this.now);

  DateTime now;

  @override
  DateTime nowUtc() => now;

  @override
  DateTime todayLocal() {
    return DateTime(now.year, now.month, now.day);
  }
}
