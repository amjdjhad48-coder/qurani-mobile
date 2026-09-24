import 'package:qurani/features/reports/domain/support_report_policy.dart';

enum SupportReportDayKind {
  normal('normal'),
  holiday('holiday'),
  missing('missing'),
  notApplicable('not_applicable');

  const SupportReportDayKind(this.storageValue);

  final String storageValue;

  static SupportReportDayKind fromStorage(String value) {
    return switch (value) {
      'normal' => SupportReportDayKind.normal,
      'holiday' => SupportReportDayKind.holiday,
      'missing' => SupportReportDayKind.missing,
      'not_applicable' => SupportReportDayKind.notApplicable,
      _ => throw StateError('Unsupported support report day kind: $value'),
    };
  }
}

final class WeeklySupportReportPeriod {
  WeeklySupportReportPeriod.forDate(DateTime localDate)
    : weekStart = SupportReportPolicy.weekStartFor(localDate),
      weekEnd = SupportReportPolicy.weekStartFor(
        localDate,
      ).add(const Duration(days: 4));

  final DateTime weekStart;
  final DateTime weekEnd;

  List<DateTime> get officialDates =>
      SupportReportPolicy.officialWeekDatesFor(weekStart);

  bool containsOfficialDate(DateTime localDate) {
    final normalized = SupportReportPolicy.dateOnly(localDate);

    return !normalized.isBefore(weekStart) && !normalized.isAfter(weekEnd);
  }
}

final class MonthlySupportReportPeriod {
  MonthlySupportReportPeriod.forDate(DateTime localDate)
    : monthStart = SupportReportPolicy.monthStartFor(localDate),
      monthEnd = SupportReportPolicy.monthEndFor(localDate);

  final DateTime monthStart;
  final DateTime monthEnd;

  int get year => monthStart.year;

  int get month => monthStart.month;

  bool containsDate(DateTime localDate) {
    final normalized = SupportReportPolicy.dateOnly(localDate);

    return !normalized.isBefore(monthStart) && !normalized.isAfter(monthEnd);
  }
}

enum SupportReportContext {
  general('general'),
  support('support');

  const SupportReportContext(this.storageValue);

  final String storageValue;

  static SupportReportContext fromStorage(String value) {
    return switch (value) {
      'general' => SupportReportContext.general,
      'support' => SupportReportContext.support,
      _ => throw FormatException('Unsupported support report context: $value'),
    };
  }
}

final class SupportReportHeaderSnapshot {
  const SupportReportHeaderSnapshot({
    required this.teacherName,
    required this.halaqahName,
    required this.organizationName,
    this.reportContext = SupportReportContext.support,
    required this.policyVersion,
    required this.templateVersion,
  });

  final String teacherName;
  final String halaqahName;
  final String organizationName;
  final SupportReportContext reportContext;
  final int policyVersion;
  final int templateVersion;
}
