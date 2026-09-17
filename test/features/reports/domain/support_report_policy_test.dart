import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';

void main() {
  group('SupportReportPolicy', () {
    test('defines fixed package 7 versions and monthly goal', () {
      expect(SupportReportPolicy.policyVersion, 1);
      expect(SupportReportPolicy.templateVersion, 1);
      expect(SupportReportPolicy.monthlyGoalFaces, 20);
      expect(SupportReportPolicy.monthlyGoalQuarterFaces, 80);
      expect(SupportReportPolicy.officialWeekdayCount, 5);
    });

    test('official report weekdays are Saturday through Wednesday only', () {
      expect(
        SupportReportPolicy.isOfficialWeekday(DateTime(2026, 9, 12)),
        isTrue,
      );
      expect(
        SupportReportPolicy.isOfficialWeekday(DateTime(2026, 9, 13)),
        isTrue,
      );
      expect(
        SupportReportPolicy.isOfficialWeekday(DateTime(2026, 9, 14)),
        isTrue,
      );
      expect(
        SupportReportPolicy.isOfficialWeekday(DateTime(2026, 9, 15)),
        isTrue,
      );
      expect(
        SupportReportPolicy.isOfficialWeekday(DateTime(2026, 9, 16)),
        isTrue,
      );
      expect(
        SupportReportPolicy.isOfficialWeekday(DateTime(2026, 9, 17)),
        isFalse,
      );
      expect(
        SupportReportPolicy.isOfficialWeekday(DateTime(2026, 9, 18)),
        isFalse,
      );
    });

    test('week start is the Saturday on or before the supplied date', () {
      expect(
        SupportReportPolicy.weekStartFor(DateTime(2026, 9, 12, 23, 30)),
        DateTime(2026, 9, 12),
      );
      expect(
        SupportReportPolicy.weekStartFor(DateTime(2026, 9, 16, 8)),
        DateTime(2026, 9, 12),
      );
      expect(
        SupportReportPolicy.weekStartFor(DateTime(2026, 9, 18, 8)),
        DateTime(2026, 9, 12),
      );
    });

    test('official week projection contains Saturday through Wednesday', () {
      final dates = SupportReportPolicy.officialWeekDatesFor(
        DateTime(2026, 9, 18),
      );

      expect(dates, <DateTime>[
        DateTime(2026, 9, 12),
        DateTime(2026, 9, 13),
        DateTime(2026, 9, 14),
        DateTime(2026, 9, 15),
        DateTime(2026, 9, 16),
      ]);
    });

    test('Gregorian month boundaries include leap-year February', () {
      expect(
        SupportReportPolicy.monthStartFor(DateTime(2028, 2, 20, 15)),
        DateTime(2028, 2),
      );
      expect(
        SupportReportPolicy.monthEndFor(DateTime(2028, 2, 20, 15)),
        DateTime(2028, 2, 29),
      );
    });

    test('monthly completion requires at least eighty quarter faces', () {
      expect(SupportReportPolicy.hasCompletedMonthlyGoal(0), isFalse);
      expect(SupportReportPolicy.hasCompletedMonthlyGoal(79), isFalse);
      expect(SupportReportPolicy.hasCompletedMonthlyGoal(80), isTrue);
      expect(SupportReportPolicy.hasCompletedMonthlyGoal(120), isTrue);
    });

    test('profile missing fields exclude optional daily plan', () {
      expect(
        SupportReportPolicy.requiredStudentProfileFields,
        <ReportMissingField>{
          ReportMissingField.supportStudentNumber,
          ReportMissingField.currentJuz,
        },
      );

      expect(
        SupportReportPolicy.requiredStudentProfileFields.contains(
          ReportMissingField.attendanceStatus,
        ),
        isFalse,
      );
    });

    test('ReportMissingItem carries student and optional day context', () {
      final item = ReportMissingItem(
        studentId: 7,
        studentName: 'أحمد',
        field: ReportMissingField.attendanceStatus,
        localDate: DateTime(2026, 9, 16),
      );

      expect(item.studentId, 7);
      expect(item.studentName, 'أحمد');
      expect(item.field, ReportMissingField.attendanceStatus);
      expect(item.localDate, DateTime(2026, 9, 16));
    });
  });
}
