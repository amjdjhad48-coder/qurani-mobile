import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';

void main() {
  group('SupportReportDayKind', () {
    test('uses the approved storage vocabulary', () {
      expect(SupportReportDayKind.normal.storageValue, 'normal');
      expect(SupportReportDayKind.holiday.storageValue, 'holiday');
      expect(SupportReportDayKind.missing.storageValue, 'missing');
      expect(SupportReportDayKind.notApplicable.storageValue, 'not_applicable');
    });

    test('round trips every supported storage value', () {
      for (final kind in SupportReportDayKind.values) {
        expect(SupportReportDayKind.fromStorage(kind.storageValue), kind);
      }
    });

    test('rejects unsupported storage values', () {
      expect(
        () => SupportReportDayKind.fromStorage('closed'),
        throwsStateError,
      );
    });
  });

  group('WeeklySupportReportPeriod', () {
    test('normalizes any date in the week to Saturday through Wednesday', () {
      final period = WeeklySupportReportPeriod.forDate(
        DateTime(2026, 9, 18, 23, 45),
      );

      expect(period.weekStart, DateTime(2026, 9, 12));
      expect(period.weekEnd, DateTime(2026, 9, 16));

      expect(period.officialDates, <DateTime>[
        DateTime(2026, 9, 12),
        DateTime(2026, 9, 13),
        DateTime(2026, 9, 14),
        DateTime(2026, 9, 15),
        DateTime(2026, 9, 16),
      ]);
    });

    test('contains only official dates of that report week', () {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

      expect(period.containsOfficialDate(DateTime(2026, 9, 12, 20)), isTrue);
      expect(period.containsOfficialDate(DateTime(2026, 9, 16, 20)), isTrue);
      expect(period.containsOfficialDate(DateTime(2026, 9, 17)), isFalse);
      expect(period.containsOfficialDate(DateTime(2026, 9, 18)), isFalse);
    });
  });

  group('MonthlySupportReportPeriod', () {
    test('uses Gregorian calendar month boundaries', () {
      final period = MonthlySupportReportPeriod.forDate(
        DateTime(2028, 2, 14, 12),
      );

      expect(period.year, 2028);
      expect(period.month, 2);
      expect(period.monthStart, DateTime(2028, 2, 1));
      expect(period.monthEnd, DateTime(2028, 2, 29));

      expect(period.containsDate(DateTime(2028, 2, 1, 23)), isTrue);
      expect(period.containsDate(DateTime(2028, 2, 29, 23)), isTrue);
      expect(period.containsDate(DateTime(2028, 3, 1)), isFalse);
    });
  });

  group('SupportReportHeaderSnapshot', () {
    test('captures historical report identity and versions', () {
      const snapshot = SupportReportHeaderSnapshot(
        teacherName: 'المعلم',
        halaqahName: 'حلقة النور',
        organizationName: 'الجهة الداعمة',
        policyVersion: SupportReportPolicy.policyVersion,
        templateVersion: SupportReportPolicy.templateVersion,
      );

      expect(snapshot.teacherName, 'المعلم');
      expect(snapshot.halaqahName, 'حلقة النور');
      expect(snapshot.organizationName, 'الجهة الداعمة');
      expect(snapshot.policyVersion, SupportReportPolicy.policyVersion);
      expect(snapshot.templateVersion, SupportReportPolicy.templateVersion);
    });
  });
}
