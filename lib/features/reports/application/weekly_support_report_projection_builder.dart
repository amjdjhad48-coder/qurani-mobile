import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_source.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

abstract interface class SupportReportLocalDateResolver {
  DateTime localDateFromUtc(DateTime utc);
}

final class SystemSupportReportLocalDateResolver
    implements SupportReportLocalDateResolver {
  const SystemSupportReportLocalDateResolver();

  @override
  DateTime localDateFromUtc(DateTime utc) {
    return SupportReportPolicy.dateOnly(utc.toLocal());
  }
}

final class WeeklySupportReportProjectionBuilder {
  const WeeklySupportReportProjectionBuilder({
    this.localDateResolver = const SystemSupportReportLocalDateResolver(),
  });

  final SupportReportLocalDateResolver localDateResolver;

  WeeklySupportReportProjection build(WeeklySupportReportSource source) {
    final officialDates = source.period.officialDates;

    final reportSupportPeriods = source.supportPeriods
        .where(
          (period) => officialDates.any(
            (date) => _supportPeriodContainsDate(period, date),
          ),
        )
        .toList(growable: false);

    final organizationNames = reportSupportPeriods
        .map((period) => period.organizationName.trim())
        .toSet();

    // CR-P8-REPORTS-002:
    // Zero support organizations => General.
    // One distinct support organization => Support, including historical gaps.
    // More than one distinct organization => General transition period.
    final hasSupportContext = organizationNames.length == 1;

    final reportingOrganizationName = hasSupportContext
        ? organizationNames.single
        : source.halaqah.centerName.trim();

    if (reportingOrganizationName.isEmpty) {
      throw StateError(
        'Cannot build a general weekly report without a '
        'halaqah center or mosque name.',
      );
    }

    final students =
        source.students
            .where(
              (student) => officialDates.any(
                (date) =>
                    _studentActiveOnDate(student, date) &&
                    (!hasSupportContext ||
                        _supportActiveOnDate(reportSupportPeriods, date)),
              ),
            )
            .toList(growable: false)
          ..sort((left, right) {
            final orderCompare = left.displayOrder.compareTo(
              right.displayOrder,
            );

            if (orderCompare != 0) {
              return orderCompare;
            }

            return left.id.compareTo(right.id);
          });

    final projectionStudents = students
        .map(
          (student) => WeeklySupportReportStudentProjection(
            sourceStudentId: student.id,
            supportStudentNumber: hasSupportContext
                ? student.supportStudentNumber
                : null,
            studentName: student.studentName,
            currentJuz: student.currentJuz,
            dailyPlanText: student.dailyPlanText,
            note: student.note,
            monthlyGoalQuarterFaces: hasSupportContext
                ? SupportReportPolicy.monthlyGoalQuarterFaces
                : null,
            displayOrder: student.displayOrder,
          ),
        )
        .toList(growable: false);

    final missingItems = <ReportMissingItem>[];

    for (final student in students) {
      if (hasSupportContext && student.supportStudentNumber == null) {
        missingItems.add(
          ReportMissingItem(
            studentId: student.id,
            studentName: student.studentName,
            field: ReportMissingField.supportStudentNumber,
          ),
        );
      }

      if (student.currentJuz == null) {
        missingItems.add(
          ReportMissingItem(
            studentId: student.id,
            studentName: student.studentName,
            field: ReportMissingField.currentJuz,
          ),
        );
      }
    }

    final daysByDate = <String, SupportReportDaySource>{};

    for (final day in source.days) {
      if (daysByDate.containsKey(day.dayDate)) {
        throw StateError('Duplicate report source day ${day.dayDate}.');
      }

      daysByDate[day.dayDate] = day;
    }

    final attendanceByDayStudent = <String, SupportReportAttendanceSource>{};

    for (final attendance in source.attendance) {
      final key = _dayStudentKey(attendance.dayId, attendance.studentId);

      if (attendanceByDayStudent.containsKey(key)) {
        throw StateError('Duplicate attendance source for day/student $key.');
      }

      attendanceByDayStudent[key] = attendance;
    }

    final recitationsByDayStudent =
        <String, List<SupportReportNewMemorizationSource>>{};

    for (final recitation in source.newMemorization) {
      recitationsByDayStudent
          .putIfAbsent(
            _dayStudentKey(recitation.dayId, recitation.studentId),
            () => <SupportReportNewMemorizationSource>[],
          )
          .add(recitation);
    }

    final projectionDays = <WeeklySupportReportDayProjection>[];

    for (final localDate in officialDates) {
      if (hasSupportContext &&
          !_supportActiveOnDate(reportSupportPeriods, localDate)) {
        projectionDays.add(
          WeeklySupportReportDayProjection(
            localDate: localDate,
            dayKind: SupportReportDayKind.notApplicable,
          ),
        );

        continue;
      }

      final daySource = daysByDate[_localDateText(localDate)];

      final dayKind = switch (daySource?.status) {
        null => SupportReportDayKind.missing,
        'holiday' => SupportReportDayKind.holiday,
        'open' || 'closed' => SupportReportDayKind.normal,
        final unsupported => throw StateError(
          'Unsupported halaqah day status in report '
          'source: $unsupported',
        ),
      };

      if (dayKind == SupportReportDayKind.holiday) {
        projectionDays.add(
          WeeklySupportReportDayProjection(
            localDate: localDate,
            dayKind: dayKind,
          ),
        );

        continue;
      }

      final dayEntries = <WeeklySupportReportDayEntryProjection>[];

      for (final student in students) {
        if (!_studentActiveOnDate(student, localDate)) {
          continue;
        }

        SupportReportAttendanceStatus? attendanceStatus;

        var recitationSources = const <SupportReportNewMemorizationSource>[];

        if (daySource != null) {
          final key = _dayStudentKey(daySource.id, student.id);

          final attendance = attendanceByDayStudent[key];

          if (attendance != null) {
            attendanceStatus = SupportReportAttendanceStatus.fromStorage(
              attendance.status,
            );
          }

          recitationSources =
              recitationsByDayStudent[key] ??
              const <SupportReportNewMemorizationSource>[];
        }

        if (attendanceStatus == null) {
          missingItems.add(
            ReportMissingItem(
              studentId: student.id,
              studentName: student.studentName,
              field: ReportMissingField.attendanceStatus,
              localDate: localDate,
            ),
          );
        }

        dayEntries.add(
          WeeklySupportReportDayEntryProjection(
            sourceStudentId: student.id,
            attendanceStatus: attendanceStatus,
            newMemorizationEntries: recitationSources
                .map(
                  (recitation) => WeeklySupportReportRecitationProjection(
                    achievedQuarterFaces: recitation.facesQuarterAchieved,
                    range: SupportReportQuranRange(
                      startSurah: recitation.startSurah,
                      startAyah: recitation.startAyah,
                      endSurah: recitation.endSurah,
                      endAyah: recitation.endAyah,
                    ),
                    note: recitation.note,
                  ),
                )
                .toList(growable: false),
          ),
        );
      }

      projectionDays.add(
        WeeklySupportReportDayProjection(
          localDate: localDate,
          dayKind: dayKind,
          entries: dayEntries,
        ),
      );
    }

    return WeeklySupportReportProjection(
      period: source.period,
      header: SupportReportHeaderSnapshot(
        teacherName: source.halaqah.teacherName,
        halaqahName: source.halaqah.halaqahName,
        organizationName: reportingOrganizationName,
        reportContext: hasSupportContext
            ? SupportReportContext.support
            : SupportReportContext.general,
        policyVersion: SupportReportPolicy.policyVersion,
        templateVersion: SupportReportPolicy.templateVersion,
      ),
      students: projectionStudents,
      days: projectionDays,
      missingItems: missingItems,
    );
  }

  bool _supportActiveOnDate(
    List<SupportReportSupportPeriodSource> periods,
    DateTime localDate,
  ) {
    return periods.any(
      (period) => _supportPeriodContainsDate(period, localDate),
    );
  }

  bool _supportPeriodContainsDate(
    SupportReportSupportPeriodSource period,
    DateTime localDate,
  ) {
    final date = SupportReportPolicy.dateOnly(localDate);

    final startDate = localDateResolver.localDateFromUtc(period.startedAtUtc);

    final endUtc = period.endedAtUtc;

    final endDate = endUtc == null
        ? null
        : localDateResolver.localDateFromUtc(endUtc);

    return !date.isBefore(startDate) &&
        (endDate == null || !date.isAfter(endDate));
  }

  bool _studentActiveOnDate(
    SupportReportStudentSource student,
    DateTime localDate,
  ) {
    final dateText = _localDateText(localDate);

    return student.activityPeriods.any(
      (period) =>
          period.activeFromDate.compareTo(dateText) <= 0 &&
          (period.activeToDate == null ||
              period.activeToDate!.compareTo(dateText) >= 0),
    );
  }
}

String _dayStudentKey(int dayId, int studentId) {
  return '$dayId:$studentId';
}

String _localDateText(DateTime value) {
  final date = SupportReportPolicy.dateOnly(value);

  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
