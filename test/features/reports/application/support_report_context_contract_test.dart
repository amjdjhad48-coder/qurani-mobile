import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/weekly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  test('legacy report header defaults to support context', () {
    const header = SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'الحلقة',
      organizationName: 'الجهة',
      policyVersion: 1,
      templateVersion: 1,
    );

    expect(header.reportContext, SupportReportContext.support);
    expect(header.reportContext.storageValue, 'support');
  });

  test('weekly builder marks no-support report as general', () {
    final source = WeeklySupportReportSource(
      period: WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14)),
      halaqah: const SupportReportHalaqahSource(
        id: 1,
        teacherName: 'المعلم',
        halaqahName: 'حلقة النور',
        centerName: 'مركز النور',
      ),
      supportPeriods: const <SupportReportSupportPeriodSource>[],
      students: const <SupportReportStudentSource>[],
      days: const <SupportReportDaySource>[],
      attendance: const <SupportReportAttendanceSource>[],
      newMemorization: const <SupportReportNewMemorizationSource>[],
    );

    final projection = const WeeklySupportReportProjectionBuilder().build(
      source,
    );

    expect(projection.header.reportContext, SupportReportContext.general);
    expect(projection.header.reportContext.storageValue, 'general');
    expect(projection.header.organizationName, 'مركز النور');
  });

  test('weekly builder marks active support report as support', () {
    final source = WeeklySupportReportSource(
      period: WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14)),
      halaqah: const SupportReportHalaqahSource(
        id: 1,
        teacherName: 'المعلم',
        halaqahName: 'حلقة النور',
        centerName: 'مركز النور',
      ),
      supportPeriods: <SupportReportSupportPeriodSource>[
        SupportReportSupportPeriodSource(
          id: 1,
          organizationName: 'الجهة الداعمة',
          startedAtUtc: DateTime.utc(2026, 9, 1),
          endedAtUtc: null,
        ),
      ],
      students: const <SupportReportStudentSource>[],
      days: const <SupportReportDaySource>[],
      attendance: const <SupportReportAttendanceSource>[],
      newMemorization: const <SupportReportNewMemorizationSource>[],
    );

    final projection = const WeeklySupportReportProjectionBuilder().build(
      source,
    );

    expect(projection.header.reportContext, SupportReportContext.support);
    expect(projection.header.reportContext.storageValue, 'support');
    expect(projection.header.organizationName, 'الجهة الداعمة');
  });

  test('storage parser rejects unknown report context', () {
    expect(
      () => SupportReportContext.fromStorage('unknown'),
      throwsFormatException,
    );
  });
}
