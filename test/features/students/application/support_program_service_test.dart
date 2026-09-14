import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/core/shared/clock.dart';
import 'package:qurani/features/students/application/support_program_service.dart';
import 'package:qurani/features/students/data/drift_support_program_repository.dart';

void main() {
  group('SupportProgramService + DriftSupportProgramRepository', () {
    test(
      'activation check reports only active students missing support number',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'pending_activation',
            organizationName: 'الجهة',
          );

          final missingId = await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 1,
            name: 'طالب ناقص',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 2,
            name: 'طالب مكتمل',
            supportStudentNumber: 'SUP-2',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 3,
            name: 'طالب مؤرشف',
            isActive: false,
          );

          final check = await _service(database).checkActivation(halaqahId);

          expect(check.canActivate, isFalse);
          expect(check.missingStudentNumbers, hasLength(1));
          expect(check.missingStudentNumbers.single.studentId, missingId);
          expect(check.missingStudentNumbers.single.studentName, 'طالب ناقص');
        } finally {
          await database.close();
        }
      },
    );

    test(
      'activation requires explicit confirmation before any write',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'pending_activation',
            organizationName: 'الجهة',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 1,
            name: 'طالب',
            supportStudentNumber: 'SUP-1',
          );

          await expectLater(
            _service(database).activate(halaqahId: halaqahId, confirmed: false),
            throwsArgumentError,
          );

          final settings = await database
              .select(database.supportProgramSettings)
              .getSingle();

          expect(settings.status, 'pending_activation');
          expect(
            await database.select(database.supportProgramPeriods).get(),
            isEmpty,
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'activation rejects missing active student support numbers atomically',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'pending_activation',
            organizationName: 'الجهة',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 1,
            name: 'طالب ناقص',
          );

          await expectLater(
            _service(database).activate(halaqahId: halaqahId, confirmed: true),
            throwsStateError,
          );

          final settings = await database
              .select(database.supportProgramSettings)
              .getSingle();

          expect(settings.status, 'pending_activation');
          expect(
            await database.select(database.supportProgramPeriods).get(),
            isEmpty,
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'successful activation enables support and opens one historical period',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'pending_activation',
            organizationName: 'الجهة أ',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 1,
            name: 'طالب',
            supportStudentNumber: 'SUP-1',
          );

          final clock = _MutableClock(DateTime.utc(2026, 9, 13, 12));
          final service = _service(database, clock: clock);

          final check = await service.checkActivation(halaqahId);
          expect(check.canActivate, isTrue);

          final state = await service.activate(
            halaqahId: halaqahId,
            confirmed: true,
          );

          expect(state.status, 'enabled');
          expect(state.organizationName, 'الجهة أ');

          final settings = await database
              .select(database.supportProgramSettings)
              .getSingle();

          expect(settings.status, 'enabled');

          final periods = await database
              .select(database.supportProgramPeriods)
              .get();

          expect(periods, hasLength(1));
          expect(periods.single.organizationName, 'الجهة أ');
          expect(periods.single.startedAtUtc, DateTime.utc(2026, 9, 13, 12));
          expect(periods.single.endedAtUtc, isNull);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'disabled support can begin a new pending activation with trimmed name',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'disabled',
          );

          final state = await _service(database).beginActivation(
            halaqahId: halaqahId,
            organizationName: '  الجهة الجديدة  ',
          );

          expect(state.status, 'pending_activation');
          expect(state.organizationName, 'الجهة الجديدة');

          final settings = await database
              .select(database.supportProgramSettings)
              .getSingle();

          expect(settings.status, 'pending_activation');
          expect(settings.organizationName, 'الجهة الجديدة');
          expect(
            await database.select(database.supportProgramPeriods).get(),
            isEmpty,
          );
        } finally {
          await database.close();
        }
      },
    );

    test(
      'disable closes the open period and clears current organization',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'pending_activation',
            organizationName: 'الجهة',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 1,
            name: 'طالب',
            supportStudentNumber: 'SUP-1',
          );

          final clock = _MutableClock(DateTime.utc(2026, 9, 13, 12));
          final service = _service(database, clock: clock);

          await service.activate(halaqahId: halaqahId, confirmed: true);

          clock.now = DateTime.utc(2026, 9, 14, 9);

          final disabled = await service.disable(halaqahId);

          expect(disabled.status, 'disabled');
          expect(disabled.organizationName, isNull);

          final settings = await database
              .select(database.supportProgramSettings)
              .getSingle();

          expect(settings.status, 'disabled');
          expect(settings.organizationName, isNull);

          final period = await database
              .select(database.supportProgramPeriods)
              .getSingle();

          expect(period.endedAtUtc, DateTime.utc(2026, 9, 14, 9));
        } finally {
          await database.close();
        }
      },
    );

    test(
      'reactivation creates a new period and preserves old organization history',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'disabled',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 1,
            name: 'طالب',
            supportStudentNumber: 'SUP-1',
          );

          final clock = _MutableClock(DateTime.utc(2026, 9, 1, 8));
          final service = _service(database, clock: clock);

          await service.beginActivation(
            halaqahId: halaqahId,
            organizationName: 'الجهة أ',
          );

          clock.now = DateTime.utc(2026, 9, 1, 9);

          await service.activate(halaqahId: halaqahId, confirmed: true);

          clock.now = DateTime.utc(2026, 9, 10, 10);
          await service.disable(halaqahId);

          clock.now = DateTime.utc(2026, 9, 11, 8);

          await service.beginActivation(
            halaqahId: halaqahId,
            organizationName: 'الجهة ب',
          );

          clock.now = DateTime.utc(2026, 9, 11, 9);

          await service.activate(halaqahId: halaqahId, confirmed: true);

          final periods =
              await database.select(database.supportProgramPeriods).get()
                ..sort((left, right) => left.id.compareTo(right.id));

          expect(periods, hasLength(2));

          expect(periods.first.organizationName, 'الجهة أ');
          expect(periods.first.endedAtUtc, DateTime.utc(2026, 9, 10, 10));

          expect(periods.last.organizationName, 'الجهة ب');
          expect(periods.last.startedAtUtc, DateTime.utc(2026, 9, 11, 9));
          expect(periods.last.endedAtUtc, isNull);
        } finally {
          await database.close();
        }
      },
    );

    test(
      'already enabled support cannot open a duplicate support period',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final halaqahId = await _insertHalaqahWithSupport(
            database,
            status: 'pending_activation',
            organizationName: 'الجهة',
          );

          await _insertStudent(
            database,
            halaqahId: halaqahId,
            displayOrder: 1,
            name: 'طالب',
            supportStudentNumber: 'SUP-1',
          );

          final service = _service(database);

          await service.activate(halaqahId: halaqahId, confirmed: true);

          await expectLater(
            service.activate(halaqahId: halaqahId, confirmed: true),
            throwsStateError,
          );

          expect(
            await database.select(database.supportProgramPeriods).get(),
            hasLength(1),
          );
        } finally {
          await database.close();
        }
      },
    );
  });
}

SupportProgramService _service(AppDatabase database, {_MutableClock? clock}) {
  return SupportProgramService(
    DriftSupportProgramRepository(database),
    clock ?? _MutableClock(DateTime.utc(2026, 9, 13, 12)),
  );
}

Future<int> _insertHalaqahWithSupport(
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

Future<int> _insertStudent(
  AppDatabase database, {
  required int halaqahId,
  required int displayOrder,
  required String name,
  String? supportStudentNumber,
  bool isActive = true,
}) async {
  final studentId = await database
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
          supportStudentNumber: Value<String?>(supportStudentNumber),
          displayOrder: displayOrder,
          isActive: Value<bool>(isActive),
          archivedAtUtc: Value<DateTime?>(
            isActive ? null : DateTime.utc(2026, 9, 10),
          ),
        ),
      );

  await database
      .into(database.studentActivityPeriods)
      .insert(
        StudentActivityPeriodsCompanion.insert(
          studentId: studentId,
          activeFromDate: '2026-09-01',
          activeToDate: Value<String?>(isActive ? null : '2026-09-10'),
        ),
      );

  return studentId;
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
