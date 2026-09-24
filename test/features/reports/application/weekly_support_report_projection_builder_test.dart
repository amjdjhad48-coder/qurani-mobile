import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/weekly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  const builder = WeeklySupportReportProjectionBuilder(
    localDateResolver: _PlusThreeLocalDateResolver(),
  );

  group('WeeklySupportReportProjectionBuilder', () {
    test('builds Saturday-Wednesday live projection from source truth', () {
      final projection = builder.build(_source());

      expect(
        projection.days.map((day) => day.dayKind).toList(),
        <SupportReportDayKind>[
          SupportReportDayKind.notApplicable,
          SupportReportDayKind.normal,
          SupportReportDayKind.holiday,
          SupportReportDayKind.missing,
          SupportReportDayKind.normal,
        ],
      );

      expect(projection.header.organizationName, 'الجهة أ');

      expect(
        projection.students.map((student) => student.sourceStudentId),
        <int>[1, 2],
      );

      expect(projection.studentById(1).note, 'ملاحظة الطالب');

      expect(projection.achievedQuarterFacesForStudent(1), 6);

      expect(projection.achievedQuarterFacesForStudent(2), 3);
    });

    test('uses inclusive historical student activity boundaries', () {
      final projection = builder.build(
        _source(
          students: <SupportReportStudentSource>[
            _student(
              id: 1,
              order: 1,
              activeFrom: '2026-09-01',
              activeTo: '2026-09-13',
            ),
            _student(id: 2, order: 2, activeFrom: '2026-09-16'),
          ],
        ),
      );

      final sunday = projection.dayForDate(DateTime(2026, 9, 13));

      expect(sunday.entries.map((entry) => entry.sourceStudentId), contains(1));

      final wednesday = projection.dayForDate(DateTime(2026, 9, 16));

      expect(
        wednesday.entries.map((entry) => entry.sourceStudentId),
        contains(2),
      );
    });

    test(
      'creates transient profile and attendance warnings only where applicable',
      () {
        final projection = builder.build(
          _source(
            students: <SupportReportStudentSource>[
              _student(
                id: 1,
                order: 1,
                activeFrom: '2026-09-01',
                supportNumber: null,
                currentJuz: null,
              ),
            ],
            attendance: const <SupportReportAttendanceSource>[
              SupportReportAttendanceSource(
                id: 1,
                dayId: 13,
                studentId: 1,
                status: 'present',
              ),
              SupportReportAttendanceSource(
                id: 2,
                dayId: 16,
                studentId: 1,
                status: 'absent',
              ),
            ],
          ),
        );

        expect(projection.hasWarnings, isTrue);

        final items = projection.missingItemsForStudent(1);

        expect(
          items
              .map((item) => item.field)
              .where(
                (field) => field == ReportMissingField.supportStudentNumber,
              ),
          hasLength(1),
        );

        expect(
          items
              .map((item) => item.field)
              .where((field) => field == ReportMissingField.currentJuz),
          hasLength(1),
        );

        final attendanceWarnings = items
            .where((item) => item.field == ReportMissingField.attendanceStatus)
            .toList();

        expect(attendanceWarnings, hasLength(1));
        expect(attendanceWarnings.single.localDate, DateTime(2026, 9, 15));

        expect(
          items.any((item) => item.localDate == DateTime(2026, 9, 12)),
          isFalse,
        );

        expect(
          items.any((item) => item.localDate == DateTime(2026, 9, 14)),
          isFalse,
        );
      },
    );

    test('preserves multiple new-memorization entries for one student/day', () {
      final projection = builder.build(_source());

      final sunday = projection.dayForDate(DateTime(2026, 9, 13));

      final studentEntry = sunday.entries.firstWhere(
        (entry) => entry.sourceStudentId == 1,
      );

      expect(studentEntry.newMemorizationEntries, hasLength(2));

      expect(
        studentEntry.newMemorizationEntries
            .map((entry) => entry.achievedQuarterFaces)
            .toList(),
        <int>[4, 2],
      );
    });

    test(
      'allows same organization reactivation and marks support gap not applicable',
      () {
        final projection = builder.build(
          _source(
            supportPeriods: <SupportReportSupportPeriodSource>[
              SupportReportSupportPeriodSource(
                id: 1,
                organizationName: 'الجهة أ',
                startedAtUtc: _UtcDates.sep11At21,
                endedAtUtc: _UtcDates.sep12At21,
              ),
              SupportReportSupportPeriodSource(
                id: 2,
                organizationName: 'الجهة أ',
                startedAtUtc: _UtcDates.sep14At21,
                endedAtUtc: null,
              ),
            ],
          ),
        );

        expect(
          projection.dayForDate(DateTime(2026, 9, 14)).dayKind,
          SupportReportDayKind.notApplicable,
        );

        expect(projection.header.organizationName, 'الجهة أ');
      },
    );

    test(
      'falls back to general when support organization changes in one official week',
      () {
        final source = _source(
          supportPeriods: <SupportReportSupportPeriodSource>[
            SupportReportSupportPeriodSource(
              id: 1,
              organizationName: 'الجهة أ',
              startedAtUtc: _UtcDates.sep11At21,
              endedAtUtc: _UtcDates.sep12At21,
            ),
            SupportReportSupportPeriodSource(
              id: 2,
              organizationName: 'الجهة ب',
              startedAtUtc: _UtcDates.sep13At21,
              endedAtUtc: null,
            ),
          ],
        );
        final projection = builder.build(source);

        expect(projection.header.reportContext, SupportReportContext.general);
        expect(
          projection.header.organizationName,
          source.halaqah.centerName.trim(),
        );
        expect(projection.students, isNotEmpty);
        expect(
          projection.students.every(
            (student) =>
                student.supportStudentNumber == null &&
                student.monthlyGoalQuarterFaces == null,
          ),
          isTrue,
        );
        expect(
          projection.missingItems.where(
            (item) => item.field == ReportMissingField.supportStudentNumber,
          ),
          isEmpty,
        );
      },
    );

    test(
      'builds a general weekly report when no support period intersects the week',
      () {
        expect(
          () => builder.build(
            _source(
              supportPeriods: <SupportReportSupportPeriodSource>[
                SupportReportSupportPeriodSource(
                  id: 1,
                  organizationName: 'الجهة أ',
                  startedAtUtc: _UtcDates.sep01At00,
                  endedAtUtc: _UtcDates.sep05At00,
                ),
              ],
            ),
          ),
          returnsNormally,
        );
      },
    );
  });
}

WeeklySupportReportSource _source({
  List<SupportReportSupportPeriodSource>? supportPeriods,
  List<SupportReportStudentSource>? students,
  List<SupportReportDaySource>? days,
  List<SupportReportAttendanceSource>? attendance,
  List<SupportReportNewMemorizationSource>? recitations,
}) {
  return WeeklySupportReportSource(
    period: WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14)),
    halaqah: const SupportReportHalaqahSource(
      id: 1,
      teacherName: 'المعلم',
      halaqahName: 'حلقة النور',
      centerName: 'المركز',
    ),
    supportPeriods:
        supportPeriods ??
        <SupportReportSupportPeriodSource>[
          SupportReportSupportPeriodSource(
            id: 1,
            organizationName: 'الجهة أ',
            startedAtUtc: _UtcDates.sep12At21,
            endedAtUtc: null,
          ),
        ],
    students:
        students ??
        <SupportReportStudentSource>[
          _student(id: 1, order: 1, activeFrom: '2026-09-01'),
          _student(id: 2, order: 2, activeFrom: '2026-09-16'),
        ],
    days:
        days ??
        const <SupportReportDaySource>[
          SupportReportDaySource(
            id: 13,
            dayDate: '2026-09-13',
            status: 'closed',
          ),
          SupportReportDaySource(
            id: 14,
            dayDate: '2026-09-14',
            status: 'holiday',
          ),
          SupportReportDaySource(id: 16, dayDate: '2026-09-16', status: 'open'),
        ],
    attendance:
        attendance ??
        const <SupportReportAttendanceSource>[
          SupportReportAttendanceSource(
            id: 1,
            dayId: 13,
            studentId: 1,
            status: 'present',
          ),
          SupportReportAttendanceSource(
            id: 2,
            dayId: 16,
            studentId: 1,
            status: 'absent',
          ),
          SupportReportAttendanceSource(
            id: 3,
            dayId: 16,
            studentId: 2,
            status: 'present',
          ),
        ],
    newMemorization:
        recitations ??
        const <SupportReportNewMemorizationSource>[
          SupportReportNewMemorizationSource(
            id: 1,
            dayId: 13,
            studentId: 1,
            startSurah: 2,
            startAyah: 1,
            endSurah: 2,
            endAyah: 5,
            facesQuarterAchieved: 4,
            note: 'الأولى',
          ),
          SupportReportNewMemorizationSource(
            id: 2,
            dayId: 13,
            studentId: 1,
            startSurah: 2,
            startAyah: 6,
            endSurah: 2,
            endAyah: 10,
            facesQuarterAchieved: 2,
            note: 'الثانية',
          ),
          SupportReportNewMemorizationSource(
            id: 3,
            dayId: 16,
            studentId: 2,
            startSurah: 3,
            startAyah: 1,
            endSurah: 3,
            endAyah: 6,
            facesQuarterAchieved: 3,
            note: null,
          ),
        ],
  );
}

SupportReportStudentSource _student({
  required int id,
  required int order,
  required String activeFrom,
  String? activeTo,
  String? supportNumber = 'SUP',
  int? currentJuz = 5,
}) {
  return SupportReportStudentSource(
    id: id,
    studentName: 'طالب $id',
    supportStudentNumber: supportNumber == null ? null : '$supportNumber-$id',
    note: id == 1 ? 'ملاحظة الطالب' : null,
    displayOrder: order,
    currentJuz: currentJuz,
    dailyPlanText: 'نصف وجه',
    activityPeriods: <SupportReportStudentActivityPeriodSource>[
      SupportReportStudentActivityPeriodSource(
        id: id,
        activeFromDate: activeFrom,
        activeToDate: activeTo,
      ),
    ],
  );
}

final class _PlusThreeLocalDateResolver
    implements SupportReportLocalDateResolver {
  const _PlusThreeLocalDateResolver();

  @override
  DateTime localDateFromUtc(DateTime utc) {
    final shifted = utc.toUtc().add(const Duration(hours: 3));

    return DateTime(shifted.year, shifted.month, shifted.day);
  }
}

abstract final class _UtcDates {
  static final sep01At00 = DateTime.utc(2026, 9, 1);

  static final sep05At00 = DateTime.utc(2026, 9, 5);

  static final sep11At21 = DateTime.utc(2026, 9, 11, 21);

  static final sep12At21 = DateTime.utc(2026, 9, 12, 21);

  static final sep13At21 = DateTime.utc(2026, 9, 13, 21);

  static final sep14At21 = DateTime.utc(2026, 9, 14, 21);
}
