import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/data/drift_support_report_source_repository.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  group('DriftSupportReportSourceRepository', () {
    test(
      'reads bounded weekly source with historical students and support periods',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final seed = await _seed(database);

          final repository = DriftSupportReportSourceRepository(database);

          final source = await repository.readWeeklySource(
            halaqahId: seed.halaqahId,
            period: WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14)),
          );

          expect(source.halaqah.id, seed.halaqahId);
          expect(source.halaqah.teacherName, 'المعلم');
          expect(source.halaqah.halaqahName, 'حلقة النور');

          expect(
            source.supportPeriods
                .map((period) => period.organizationName)
                .toList(),
            <String>['الجهة القديمة', 'الجهة الحالية'],
          );

          expect(source.students.map((student) => student.id), <int>[
            seed.activeStudentId,
            seed.archivedStudentId,
            seed.wednesdayStudentId,
          ]);

          final active = source.students.firstWhere(
            (student) => student.id == seed.activeStudentId,
          );

          expect(active.supportStudentNumber, 'SUP-1');
          expect(active.currentJuz, 5);
          expect(active.dailyPlanText, 'نصف وجه');
          expect(active.activityPeriods, hasLength(1));

          final archived = source.students.firstWhere(
            (student) => student.id == seed.archivedStudentId,
          );

          expect(archived.activityPeriods.single.activeToDate, '2026-09-12');

          final wednesday = source.students.firstWhere(
            (student) => student.id == seed.wednesdayStudentId,
          );

          expect(wednesday.activityPeriods.single.activeFromDate, '2026-09-16');

          expect(
            source.students.any(
              (student) => student.id == seed.afterWeekStudentId,
            ),
            isFalse,
          );

          expect(
            source.students.any(
              (student) => student.id == seed.otherHalaqahStudentId,
            ),
            isFalse,
          );
        } finally {
          await database.close();
        }
      },
    );

    test('reads only official report days and their attendance', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seed(database);

        final source = await DriftSupportReportSourceRepository(database)
            .readWeeklySource(
              halaqahId: seed.halaqahId,
              period: WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14)),
            );

        expect(source.days.map((day) => day.dayDate).toList(), <String>[
          '2026-09-12',
          '2026-09-13',
          '2026-09-16',
        ]);

        expect(source.days.map((day) => day.status).toList(), <String>[
          'closed',
          'holiday',
          'open',
        ]);

        expect(source.attendance, hasLength(3));

        expect(
          source.attendance.map((record) => record.status).toSet(),
          <String>{'present', 'absent'},
        );

        expect(source.days.any((day) => day.dayDate == '2026-09-17'), isFalse);
      } finally {
        await database.close();
      }
    });

    test(
      'returns new memorization only and preserves multiple events',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        try {
          final seed = await _seed(database);

          final source = await DriftSupportReportSourceRepository(database)
              .readWeeklySource(
                halaqahId: seed.halaqahId,
                period: WeeklySupportReportPeriod.forDate(
                  DateTime(2026, 9, 14),
                ),
              );

          expect(source.newMemorization, hasLength(4));

          final firstStudentEntries = source.newMemorization
              .where((entry) => entry.studentId == seed.activeStudentId)
              .toList();

          expect(firstStudentEntries, hasLength(2));

          expect(
            firstStudentEntries
                .map((entry) => entry.facesQuarterAchieved)
                .toList(),
            <int>[4, 2],
          );

          expect(
            source.newMemorization
                .map((entry) => entry.facesQuarterAchieved)
                .contains(20),
            isFalse,
          );
        } finally {
          await database.close();
        }
      },
    );

    test('live source read does not create any report snapshot rows', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        final seed = await _seed(database);

        await DriftSupportReportSourceRepository(database).readWeeklySource(
          halaqahId: seed.halaqahId,
          period: WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14)),
        );

        expect(
          await database.select(database.supportWeeklyReports).get(),
          isEmpty,
        );

        expect(
          await database.select(database.supportWeeklyReportStudents).get(),
          isEmpty,
        );

        expect(
          await database.select(database.supportWeeklyReportDays).get(),
          isEmpty,
        );

        expect(
          await database.select(database.supportWeeklyReportDayEntries).get(),
          isEmpty,
        );

        expect(
          await database.select(database.supportMonthlyReports).get(),
          isEmpty,
        );

        expect(
          await database.select(database.supportMonthlyReportStudents).get(),
          isEmpty,
        );
      } finally {
        await database.close();
      }
    });

    test('missing halaqah fails explicitly', () async {
      final database = AppDatabase(NativeDatabase.memory());

      try {
        await expectLater(
          DriftSupportReportSourceRepository(database).readWeeklySource(
            halaqahId: 999,
            period: WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14)),
          ),
          throwsStateError,
        );
      } finally {
        await database.close();
      }
    });
  });
}

Future<_Seed> _seed(AppDatabase database) async {
  final halaqahId = await _insertHalaqah(
    database,
    teacher: 'المعلم',
    name: 'حلقة النور',
  );

  final otherHalaqahId = await _insertHalaqah(
    database,
    teacher: 'معلم آخر',
    name: 'حلقة أخرى',
  );

  await database
      .into(database.supportProgramPeriods)
      .insert(
        SupportProgramPeriodsCompanion.insert(
          halaqahId: halaqahId,
          organizationName: 'الجهة القديمة',
          startedAtUtc: DateTime.utc(2026, 8, 1),
          endedAtUtc: Value<DateTime?>(DateTime.utc(2026, 8, 31, 20)),
        ),
      );

  await database
      .into(database.supportProgramPeriods)
      .insert(
        SupportProgramPeriodsCompanion.insert(
          halaqahId: halaqahId,
          organizationName: 'الجهة الحالية',
          startedAtUtc: DateTime.utc(2026, 9, 1),
        ),
      );

  final activeStudentId = await _insertStudent(
    database,
    halaqahId: halaqahId,
    name: 'أحمد',
    supportNumber: 'SUP-1',
    displayOrder: 1,
    activeFrom: '2026-09-01',
    currentJuz: 5,
    dailyPlanText: 'نصف وجه',
  );

  final archivedStudentId = await _insertStudent(
    database,
    halaqahId: halaqahId,
    name: 'خالد',
    supportNumber: 'SUP-2',
    displayOrder: 2,
    activeFrom: '2026-09-01',
    activeTo: '2026-09-12',
    isActive: false,
  );

  final wednesdayStudentId = await _insertStudent(
    database,
    halaqahId: halaqahId,
    name: 'سعيد',
    supportNumber: 'SUP-3',
    displayOrder: 3,
    activeFrom: '2026-09-16',
    currentJuz: 2,
  );

  final afterWeekStudentId = await _insertStudent(
    database,
    halaqahId: halaqahId,
    name: 'بعد الأسبوع',
    supportNumber: 'SUP-4',
    displayOrder: 4,
    activeFrom: '2026-09-17',
  );

  final otherHalaqahStudentId = await _insertStudent(
    database,
    halaqahId: otherHalaqahId,
    name: 'طالب خارجي',
    supportNumber: 'OTHER-1',
    displayOrder: 1,
    activeFrom: '2026-09-01',
  );

  final saturdayDayId = await _insertDay(
    database,
    halaqahId: halaqahId,
    date: '2026-09-12',
    status: 'closed',
  );

  await _insertDay(
    database,
    halaqahId: halaqahId,
    date: '2026-09-13',
    status: 'holiday',
  );

  final wednesdayDayId = await _insertDay(
    database,
    halaqahId: halaqahId,
    date: '2026-09-16',
    status: 'open',
  );

  final thursdayDayId = await _insertDay(
    database,
    halaqahId: halaqahId,
    date: '2026-09-17',
    status: 'closed',
  );

  final otherDayId = await _insertDay(
    database,
    halaqahId: otherHalaqahId,
    date: '2026-09-12',
    status: 'closed',
  );

  await _insertAttendance(
    database,
    dayId: saturdayDayId,
    studentId: activeStudentId,
    status: 'present',
  );

  await _insertAttendance(
    database,
    dayId: saturdayDayId,
    studentId: archivedStudentId,
    status: 'absent',
  );

  await _insertAttendance(
    database,
    dayId: wednesdayDayId,
    studentId: wednesdayStudentId,
    status: 'present',
  );

  await _insertAttendance(
    database,
    dayId: thursdayDayId,
    studentId: activeStudentId,
    status: 'present',
  );

  await _insertAttendance(
    database,
    dayId: otherDayId,
    studentId: otherHalaqahStudentId,
    status: 'present',
  );

  await _insertRecitation(
    database,
    dayId: saturdayDayId,
    studentId: activeStudentId,
    type: 'new_memorization',
    faces: 4,
  );

  await _insertRecitation(
    database,
    dayId: saturdayDayId,
    studentId: activeStudentId,
    type: 'new_memorization',
    faces: 2,
  );

  await _insertRecitation(
    database,
    dayId: saturdayDayId,
    studentId: activeStudentId,
    type: 'revision',
    faces: 20,
  );

  await _insertRecitation(
    database,
    dayId: saturdayDayId,
    studentId: archivedStudentId,
    type: 'new_memorization',
    faces: 1,
  );

  await _insertRecitation(
    database,
    dayId: wednesdayDayId,
    studentId: wednesdayStudentId,
    type: 'new_memorization',
    faces: 3,
  );

  await _insertRecitation(
    database,
    dayId: thursdayDayId,
    studentId: activeStudentId,
    type: 'new_memorization',
    faces: 16,
  );

  await _insertRecitation(
    database,
    dayId: otherDayId,
    studentId: otherHalaqahStudentId,
    type: 'new_memorization',
    faces: 8,
  );

  return _Seed(
    halaqahId: halaqahId,
    activeStudentId: activeStudentId,
    archivedStudentId: archivedStudentId,
    wednesdayStudentId: wednesdayStudentId,
    afterWeekStudentId: afterWeekStudentId,
    otherHalaqahStudentId: otherHalaqahStudentId,
  );
}

Future<int> _insertHalaqah(
  AppDatabase database, {
  required String teacher,
  required String name,
}) {
  final now = DateTime.utc(2026, 9, 1, 8);

  return database
      .into(database.halaqahs)
      .insert(
        HalaqahsCompanion.insert(
          teacherName: teacher,
          halaqahName: name,
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
  required String supportNumber,
  required int displayOrder,
  required String activeFrom,
  String? activeTo,
  bool isActive = true,
  int? currentJuz,
  String? dailyPlanText,
}) async {
  final studentId = await database
      .into(database.students)
      .insert(
        StudentsCompanion.insert(
          halaqahId: halaqahId,
          studentName: name,
          fatherName: 'الأب',
          ageYears: 12,
          guardianCountryCode: '+967',
          guardianNationalNumber:
              '77${displayOrder.toString().padLeft(7, '0')}',
          previousMemorizationText: 'حفظ سابق',
          supportStudentNumber: Value<String?>(supportNumber),
          displayOrder: displayOrder,
          isActive: Value<bool>(isActive),
          archivedAtUtc: Value<DateTime?>(
            isActive ? null : DateTime.utc(2026, 9, 12, 12),
          ),
        ),
      );

  await database
      .into(database.studentActivityPeriods)
      .insert(
        StudentActivityPeriodsCompanion.insert(
          studentId: studentId,
          activeFromDate: activeFrom,
          activeToDate: Value<String?>(activeTo),
        ),
      );

  if (currentJuz != null || dailyPlanText != null) {
    await database
        .into(database.studentProgressPlans)
        .insert(
          StudentProgressPlansCompanion.insert(
            studentId: Value<int>(studentId),
            currentJuz: Value<int?>(currentJuz),
            dailyPlanText: Value<String?>(dailyPlanText),
          ),
        );
  }

  return studentId;
}

Future<int> _insertDay(
  AppDatabase database, {
  required int halaqahId,
  required String date,
  required String status,
}) {
  return database
      .into(database.halaqahDays)
      .insert(
        HalaqahDaysCompanion.insert(
          halaqahId: halaqahId,
          dayDate: date,
          status: status,
        ),
      );
}

Future<void> _insertAttendance(
  AppDatabase database, {
  required int dayId,
  required int studentId,
  required String status,
}) {
  return database
      .into(database.attendanceRecords)
      .insert(
        AttendanceRecordsCompanion.insert(
          dayId: dayId,
          studentId: studentId,
          status: status,
        ),
      )
      .then((_) {});
}

Future<void> _insertRecitation(
  AppDatabase database, {
  required int dayId,
  required int studentId,
  required String type,
  required int faces,
}) {
  return database
      .into(database.recitations)
      .insert(
        RecitationsCompanion.insert(
          dayId: dayId,
          studentId: studentId,
          type: type,
          startSurah: 2,
          startAyah: 1,
          endSurah: 2,
          endAyah: 5,
          facesQuarterAchieved: faces,
          evaluation: 'excellent',
          errorCount: const Value<int>(0),
          note: const Value<String?>('ملاحظة'),
        ),
      )
      .then((_) {});
}

final class _Seed {
  const _Seed({
    required this.halaqahId,
    required this.activeStudentId,
    required this.archivedStudentId,
    required this.wednesdayStudentId,
    required this.afterWeekStudentId,
    required this.otherHalaqahStudentId,
  });

  final int halaqahId;
  final int activeStudentId;
  final int archivedStudentId;
  final int wednesdayStudentId;
  final int afterWeekStudentId;
  final int otherHalaqahStudentId;
}
