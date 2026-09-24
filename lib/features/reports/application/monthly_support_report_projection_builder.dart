import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

final class MonthlySupportReportProjectionBuilder {
  const MonthlySupportReportProjectionBuilder();

  MonthlySupportReportProjection build({
    required MonthlySupportReportPeriod period,
    required Iterable<ApprovedWeeklySupportReportSnapshot>
    approvedWeeklySnapshots,
    String? centerName,
  }) {
    final snapshots = approvedWeeklySnapshots
        .where(
          (snapshot) =>
              snapshot.days.any((day) => period.containsDate(day.localDate)),
        )
        .toList(growable: false);

    if (snapshots.isEmpty) {
      throw StateError(
        'Cannot build a monthly support report without '
        'approved weekly snapshots contributing actual dates.',
      );
    }

    final reportIds = <int>{};
    final halaqahIds = <int>{};
    final organizationNames = <String>{};
    final reportContexts = <SupportReportContext>{};
    final policyVersions = <int>{};
    final templateVersions = <int>{};

    for (final snapshot in snapshots) {
      if (!reportIds.add(snapshot.reportId)) {
        throw StateError(
          'Duplicate approved weekly report input ${snapshot.reportId}.',
        );
      }

      halaqahIds.add(snapshot.halaqahId);
      organizationNames.add(snapshot.header.organizationName.trim());
      reportContexts.add(snapshot.header.reportContext);
      policyVersions.add(snapshot.header.policyVersion);
      templateVersions.add(snapshot.header.templateVersion);
    }

    if (halaqahIds.length != 1) {
      throw StateError('Monthly report inputs must belong to one halaqah.');
    }

    final normalizedCenterName = centerName?.trim();

    final canonicalCenterName =
        normalizedCenterName == null || normalizedCenterName.isEmpty
        ? null
        : normalizedCenterName;

    if (organizationNames.any((name) => name.isEmpty)) {
      throw StateError(
        'Monthly report inputs must expose non-empty reporting identities.',
      );
    }

    final allSupportContext =
        reportContexts.length == 1 &&
        reportContexts.single == SupportReportContext.support;

    final hasSupportContext =
        allSupportContext && organizationNames.length == 1;

    final reportContext = hasSupportContext
        ? SupportReportContext.support
        : SupportReportContext.general;

    late final String reportingOrganizationName;

    if (hasSupportContext) {
      reportingOrganizationName = organizationNames.single;
    } else {
      final canReuseGeneralSnapshotName =
          reportContexts.length == 1 &&
          reportContexts.single == SupportReportContext.general &&
          organizationNames.length == 1;

      reportingOrganizationName =
          canonicalCenterName ??
          (canReuseGeneralSnapshotName ? organizationNames.single : '');

      if (reportingOrganizationName.isEmpty) {
        throw StateError(
          'Monthly general report requires the canonical halaqah center '
          'when weekly contexts or support organizations transition.',
        );
      }
    }

    if (policyVersions.length != 1 ||
        policyVersions.single != SupportReportPolicy.policyVersion) {
      throw StateError(
        'Monthly report cannot combine unsupported policy versions.',
      );
    }

    if (templateVersions.length != 1 ||
        templateVersions.single != SupportReportPolicy.templateVersion) {
      throw StateError(
        'Monthly report cannot combine unsupported template versions.',
      );
    }

    snapshots.sort((left, right) {
      final dateCompare = _latestContributingDate(
        left,
        period,
      ).compareTo(_latestContributingDate(right, period));

      if (dateCompare != 0) {
        return dateCompare;
      }

      return left.reportId.compareTo(right.reportId);
    });

    final latestSnapshot = snapshots.last;

    final dayProjections = <MonthlySupportReportDayProjection>[];

    final seenDates = <String>{};

    final accumulators = <int, _StudentAccumulator>{};

    for (final snapshot in snapshots) {
      final studentsById = <int, ApprovedWeeklySupportReportStudentSnapshot>{};

      for (final student in snapshot.students) {
        if (studentsById.containsKey(student.sourceStudentId)) {
          throw StateError(
            'Approved weekly snapshot ${snapshot.reportId} '
            'contains duplicate students.',
          );
        }

        studentsById[student.sourceStudentId] = student;
      }

      final contributingDays =
          snapshot.days
              .where((day) => period.containsDate(day.localDate))
              .toList(growable: false)
            ..sort((left, right) => left.localDate.compareTo(right.localDate));

      for (final day in contributingDays) {
        final dateText = _dateText(day.localDate);

        if (!seenDates.add(dateText)) {
          throw StateError(
            'More than one approved weekly snapshot '
            'contributes $dateText.',
          );
        }

        if ((day.dayKind == SupportReportDayKind.holiday ||
                day.dayKind == SupportReportDayKind.notApplicable) &&
            day.entries.isNotEmpty) {
          throw StateError(
            'Holiday or not-applicable monthly source day '
            'must not contain student entries.',
          );
        }

        final monthlyEntries = <MonthlySupportReportDayEntryProjection>[];

        final entriesByStudent =
            <int, List<ApprovedWeeklySupportReportDayEntrySnapshot>>{};

        for (final entry in day.entries) {
          final student = studentsById[entry.sourceStudentId];

          if (student == null) {
            throw StateError(
              'Approved weekly day entry references '
              'a student outside its weekly snapshot.',
            );
          }

          entriesByStudent
              .putIfAbsent(
                entry.sourceStudentId,
                () => <ApprovedWeeklySupportReportDayEntrySnapshot>[],
              )
              .add(entry);

          monthlyEntries.add(
            MonthlySupportReportDayEntryProjection(
              sourceStudentId: entry.sourceStudentId,
              attendanceStatus: entry.attendanceStatus,
              achievedQuarterFaces: entry.achievedQuarterFaces,
              range: entry.range,
              note: entry.note,
              entryOrder: entry.entryOrder,
            ),
          );
        }

        for (final studentEntries in entriesByStudent.entries) {
          final studentId = studentEntries.key;

          final student = studentsById[studentId]!;

          final accumulator = accumulators.putIfAbsent(
            studentId,
            () => _StudentAccumulator(sourceStudentId: studentId),
          );

          accumulator.considerProfile(
            student: student,
            localDate: day.localDate,
            reportId: snapshot.reportId,
          );

          final attendanceStatuses = studentEntries.value
              .map((entry) => entry.attendanceStatus)
              .whereType<SupportReportAttendanceStatus>()
              .toList(growable: false);

          if (attendanceStatuses.length > 1) {
            throw StateError(
              'A student has more than one attendance '
              'snapshot on $dateText.',
            );
          }

          final attendanceStatus = attendanceStatuses.isEmpty
              ? null
              : attendanceStatuses.single;

          if (attendanceStatus == SupportReportAttendanceStatus.absent ||
              attendanceStatus == SupportReportAttendanceStatus.excusedAbsent) {
            accumulator.absenceDays++;
          }

          if (attendanceStatus == null &&
              (day.dayKind == SupportReportDayKind.normal ||
                  day.dayKind == SupportReportDayKind.missing)) {
            accumulator.missingAttendanceDates.add(
              SupportReportPolicy.dateOnly(day.localDate),
            );
          }

          for (final entry in studentEntries.value) {
            accumulator.achievedQuarterFaces += entry.achievedQuarterFaces;
          }
        }

        monthlyEntries.sort((left, right) {
          final studentCompare = left.sourceStudentId.compareTo(
            right.sourceStudentId,
          );

          if (studentCompare != 0) {
            return studentCompare;
          }

          return left.entryOrder.compareTo(right.entryOrder);
        });

        dayProjections.add(
          MonthlySupportReportDayProjection(
            sourceWeeklyReportId: snapshot.reportId,
            localDate: SupportReportPolicy.dateOnly(day.localDate),
            dayKind: day.dayKind,
            entries: monthlyEntries,
          ),
        );
      }
    }

    dayProjections.sort(
      (left, right) => left.localDate.compareTo(right.localDate),
    );

    final students = <MonthlySupportReportStudentProjection>[];

    final missingItems = <ReportMissingItem>[];

    for (final accumulator in accumulators.values) {
      final profile = accumulator.latestProfile;

      if (profile == null) {
        throw StateError(
          'Monthly student has no approved weekly '
          'profile snapshot.',
        );
      }

      if (hasSupportContext &&
          profile.monthlyGoalQuarterFaces !=
              SupportReportPolicy.monthlyGoalQuarterFaces) {
        throw StateError(
          'Approved support weekly snapshot uses an '
          'unsupported monthly goal.',
        );
      }

      final monthlyGoal = hasSupportContext
          ? SupportReportPolicy.monthlyGoalQuarterFaces
          : null;

      final goalCompleted = hasSupportContext
          ? SupportReportPolicy.hasCompletedMonthlyGoal(
              accumulator.achievedQuarterFaces,
            )
          : null;

      students.add(
        MonthlySupportReportStudentProjection(
          sourceStudentId: profile.sourceStudentId,
          supportStudentNumber: hasSupportContext
              ? profile.supportStudentNumber
              : null,
          studentName: profile.studentName,
          currentJuz: profile.currentJuz,
          dailyPlanText: profile.dailyPlanText,
          monthlyGoalQuarterFaces: monthlyGoal,
          achievedQuarterFaces: accumulator.achievedQuarterFaces,
          absenceDays: accumulator.absenceDays,
          goalCompleted: goalCompleted,
          note: profile.note,
          displayOrder: profile.displayOrder,
        ),
      );

      if (hasSupportContext && profile.supportStudentNumber == null) {
        missingItems.add(
          ReportMissingItem(
            studentId: profile.sourceStudentId,
            studentName: profile.studentName,
            field: ReportMissingField.supportStudentNumber,
          ),
        );
      }

      if (profile.currentJuz == null) {
        missingItems.add(
          ReportMissingItem(
            studentId: profile.sourceStudentId,
            studentName: profile.studentName,
            field: ReportMissingField.currentJuz,
          ),
        );
      }

      for (final date in accumulator.missingAttendanceDates) {
        missingItems.add(
          ReportMissingItem(
            studentId: profile.sourceStudentId,
            studentName: profile.studentName,
            field: ReportMissingField.attendanceStatus,
            localDate: date,
          ),
        );
      }
    }

    students.sort((left, right) {
      final displayCompare = left.displayOrder.compareTo(right.displayOrder);

      if (displayCompare != 0) {
        return displayCompare;
      }

      return left.sourceStudentId.compareTo(right.sourceStudentId);
    });

    missingItems.sort((left, right) {
      final studentCompare = left.studentId.compareTo(right.studentId);

      if (studentCompare != 0) {
        return studentCompare;
      }

      final fieldCompare = left.field.name.compareTo(right.field.name);

      if (fieldCompare != 0) {
        return fieldCompare;
      }

      return _nullableDateText(
        left.localDate,
      ).compareTo(_nullableDateText(right.localDate));
    });

    final weeklyInputs = snapshots
        .map(
          (snapshot) => MonthlySupportReportWeeklyInputIdentity(
            reportId: snapshot.reportId,
            period: snapshot.period,
            sourceFingerprint: snapshot.sourceFingerprint,
            approvedAtUtc: snapshot.approvedAtUtc,
          ),
        )
        .toList(growable: false);

    return MonthlySupportReportProjection(
      halaqahId: halaqahIds.single,
      period: period,
      header: SupportReportHeaderSnapshot(
        teacherName: latestSnapshot.header.teacherName,
        halaqahName: latestSnapshot.header.halaqahName,
        organizationName: reportingOrganizationName,
        reportContext: reportContext,
        policyVersion: latestSnapshot.header.policyVersion,
        templateVersion: latestSnapshot.header.templateVersion,
      ),
      students: students,
      days: dayProjections,
      weeklyInputs: weeklyInputs,
      missingItems: missingItems,
    );
  }
}

final class _StudentAccumulator {
  _StudentAccumulator({required this.sourceStudentId});

  final int sourceStudentId;

  ApprovedWeeklySupportReportStudentSnapshot? latestProfile;

  DateTime? latestProfileDate;
  int latestProfileReportId = -1;

  int achievedQuarterFaces = 0;
  int absenceDays = 0;

  final List<DateTime> missingAttendanceDates = <DateTime>[];

  void considerProfile({
    required ApprovedWeeklySupportReportStudentSnapshot student,
    required DateTime localDate,
    required int reportId,
  }) {
    final normalized = SupportReportPolicy.dateOnly(localDate);

    final previousDate = latestProfileDate;

    final shouldReplace =
        previousDate == null ||
        normalized.isAfter(previousDate) ||
        (normalized == previousDate && reportId > latestProfileReportId);

    if (!shouldReplace) {
      return;
    }

    latestProfile = student;
    latestProfileDate = normalized;
    latestProfileReportId = reportId;
  }
}

DateTime _latestContributingDate(
  ApprovedWeeklySupportReportSnapshot snapshot,
  MonthlySupportReportPeriod period,
) {
  final dates = snapshot.days
      .where((day) => period.containsDate(day.localDate))
      .map((day) => SupportReportPolicy.dateOnly(day.localDate))
      .toList(growable: false);

  if (dates.isEmpty) {
    throw StateError(
      'Weekly snapshot does not contribute an '
      'actual date to the requested month.',
    );
  }

  dates.sort();

  return dates.last;
}

String _dateText(DateTime value) {
  final normalized = SupportReportPolicy.dateOnly(value);

  return '${normalized.year.toString().padLeft(4, '0')}-'
      '${normalized.month.toString().padLeft(2, '0')}-'
      '${normalized.day.toString().padLeft(2, '0')}';
}

String _nullableDateText(DateTime? value) {
  return value == null ? '' : _dateText(value);
}
