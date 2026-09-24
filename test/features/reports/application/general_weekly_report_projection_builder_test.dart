import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/weekly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  test('builds a general weekly report without a support program', () {
    final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

    final source = WeeklySupportReportSource(
      period: period,
      halaqah: const SupportReportHalaqahSource(
        id: 1,
        teacherName: 'المعلم',
        halaqahName: 'حلقة النور',
        centerName: 'مركز النور',
      ),
      supportPeriods: const <SupportReportSupportPeriodSource>[],
      students: <SupportReportStudentSource>[
        SupportReportStudentSource(
          id: 1,
          studentName: 'أحمد',
          supportStudentNumber: null,
          note: null,
          displayOrder: 1,
          currentJuz: 1,
          dailyPlanText: null,
          activityPeriods: const <SupportReportStudentActivityPeriodSource>[
            SupportReportStudentActivityPeriodSource(
              id: 1,
              activeFromDate: '2026-09-01',
              activeToDate: null,
            ),
          ],
        ),
      ],
      days: const <SupportReportDaySource>[
        SupportReportDaySource(id: 10, dayDate: '2026-09-12', status: 'closed'),
        SupportReportDaySource(id: 11, dayDate: '2026-09-13', status: 'closed'),
        SupportReportDaySource(id: 12, dayDate: '2026-09-14', status: 'closed'),
        SupportReportDaySource(id: 13, dayDate: '2026-09-15', status: 'closed'),
        SupportReportDaySource(id: 14, dayDate: '2026-09-16', status: 'closed'),
      ],
      attendance: const <SupportReportAttendanceSource>[
        SupportReportAttendanceSource(
          id: 20,
          dayId: 10,
          studentId: 1,
          status: 'present',
        ),
        SupportReportAttendanceSource(
          id: 21,
          dayId: 11,
          studentId: 1,
          status: 'present',
        ),
        SupportReportAttendanceSource(
          id: 22,
          dayId: 12,
          studentId: 1,
          status: 'present',
        ),
        SupportReportAttendanceSource(
          id: 23,
          dayId: 13,
          studentId: 1,
          status: 'present',
        ),
        SupportReportAttendanceSource(
          id: 24,
          dayId: 14,
          studentId: 1,
          status: 'present',
        ),
      ],
      newMemorization: const <SupportReportNewMemorizationSource>[],
    );

    final projection = const WeeklySupportReportProjectionBuilder().build(
      source,
    );

    expect(projection.header.teacherName, 'المعلم');
    expect(projection.header.halaqahName, 'حلقة النور');

    expect(projection.header.organizationName, 'مركز النور');
    expect(projection.header.reportContext, SupportReportContext.general);

    expect(projection.students, hasLength(1));

    expect(projection.students.single.supportStudentNumber, isNull);
    expect(projection.students.single.monthlyGoalQuarterFaces, isNull);

    expect(
      projection.days.every(
        (day) => day.dayKind == SupportReportDayKind.normal,
      ),
      isTrue,
    );

    expect(
      projection.missingItems.any(
        (item) => item.field == ReportMissingField.supportStudentNumber,
      ),
      isFalse,
    );
  });
}
