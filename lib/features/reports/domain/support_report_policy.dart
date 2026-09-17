enum ReportMissingField { supportStudentNumber, currentJuz, attendanceStatus }

final class ReportMissingItem {
  const ReportMissingItem({
    required this.studentId,
    required this.studentName,
    required this.field,
    this.localDate,
  });

  final int studentId;
  final String studentName;
  final ReportMissingField field;
  final DateTime? localDate;
}

final class SupportReportPolicy {
  const SupportReportPolicy._();

  static const int policyVersion = 1;
  static const int templateVersion = 1;

  static const int officialWeekdayCount = 5;

  static const int monthlyGoalFaces = 20;
  static const int monthlyGoalQuarterFaces = 80;

  static const Set<ReportMissingField> requiredStudentProfileFields =
      <ReportMissingField>{
        ReportMissingField.supportStudentNumber,
        ReportMissingField.currentJuz,
      };

  static bool isOfficialWeekday(DateTime localDate) {
    return switch (localDate.weekday) {
      DateTime.saturday ||
      DateTime.sunday ||
      DateTime.monday ||
      DateTime.tuesday ||
      DateTime.wednesday => true,
      DateTime.thursday || DateTime.friday => false,
      _ => false,
    };
  }

  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime weekStartFor(DateTime localDate) {
    final normalized = dateOnly(localDate);

    final daysSinceSaturday = (normalized.weekday + 1) % 7;

    return normalized.subtract(Duration(days: daysSinceSaturday));
  }

  static List<DateTime> officialWeekDatesFor(DateTime localDate) {
    final saturday = weekStartFor(localDate);

    return List<DateTime>.unmodifiable(
      List<DateTime>.generate(
        officialWeekdayCount,
        (index) => saturday.add(Duration(days: index)),
      ),
    );
  }

  static DateTime monthStartFor(DateTime localDate) {
    final normalized = dateOnly(localDate);
    return DateTime(normalized.year, normalized.month);
  }

  static DateTime monthEndFor(DateTime localDate) {
    final normalized = dateOnly(localDate);
    return DateTime(normalized.year, normalized.month + 1, 0);
  }

  static bool hasCompletedMonthlyGoal(int achievedQuarterFaces) {
    return achievedQuarterFaces >= monthlyGoalQuarterFaces;
  }
}
