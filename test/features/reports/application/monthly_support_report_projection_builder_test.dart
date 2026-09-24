import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/monthly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  const builder = MonthlySupportReportProjectionBuilder();

  group('MonthlySupportReportProjectionBuilder', () {
    test(
      'splits cross-month week by actual date and aggregates goal and absence',
      () {
        final first = _snapshot(
          reportId: 1,
          weekDate: DateTime(2026, 8, 29),
          teacherName: 'المعلم الأول',
          currentJuz: 2,
          dailyPlanText: 'نصف وجه',
          note: 'قديم',
          entriesByDate: <String, List<_EntrySpec>>{
            '2026-08-29': <_EntrySpec>[
              const _EntrySpec(
                status: SupportReportAttendanceStatus.absent,
                achievedQuarterFaces: 40,
              ),
            ],
            '2026-08-30': <_EntrySpec>[
              const _EntrySpec(
                status: SupportReportAttendanceStatus.present,
                achievedQuarterFaces: 40,
              ),
            ],
            '2026-08-31': <_EntrySpec>[
              const _EntrySpec(
                status: SupportReportAttendanceStatus.present,
                achievedQuarterFaces: 20,
              ),
            ],
            '2026-09-01': <_EntrySpec>[
              const _EntrySpec(
                status: SupportReportAttendanceStatus.absent,
                achievedQuarterFaces: 4,
              ),
              const _EntrySpec(status: null, achievedQuarterFaces: 8),
            ],
            '2026-09-02': <_EntrySpec>[
              const _EntrySpec(
                status: SupportReportAttendanceStatus.present,
                achievedQuarterFaces: 0,
              ),
            ],
          },
        );

        final second = _snapshot(
          reportId: 2,
          weekDate: DateTime(2026, 9, 5),
          teacherName: 'المعلم الثاني',
          currentJuz: 3,
          dailyPlanText: 'وجه',
          note: 'أحدث',
          entriesByDate: <String, List<_EntrySpec>>{
            '2026-09-05': <_EntrySpec>[
              const _EntrySpec(
                status: SupportReportAttendanceStatus.excusedAbsent,
                achievedQuarterFaces: 68,
              ),
            ],
          },
        );

        final projection = builder.build(
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
          approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
            first,
            second,
          ],
        );

        expect(
          projection.days.map((day) => _dateText(day.localDate)).toList(),
          <String>[
            '2026-09-01',
            '2026-09-02',
            '2026-09-05',
            '2026-09-06',
            '2026-09-07',
            '2026-09-08',
            '2026-09-09',
          ],
        );

        final student = projection.studentById(1);

        expect(student.achievedQuarterFaces, 80);

        expect(student.absenceDays, 2);

        expect(student.goalCompleted, isTrue);

        expect(student.monthlyGoalQuarterFaces, 80);

        expect(student.currentJuz, 3);

        expect(student.dailyPlanText, 'وجه');

        expect(student.note, 'أحدث');

        expect(projection.header.teacherName, 'المعلم الثاني');

        expect(
          projection.weeklyInputs.map((input) => input.reportId).toList(),
          <int>[1, 2],
        );

        expect(projection.hasWarnings, isFalse);
      },
    );

    test(
      'derives monthly missing warnings from approved weekly snapshot content',
      () {
        final snapshot = _snapshot(
          reportId: 3,
          weekDate: DateTime(2026, 9, 12),
          supportStudentNumber: null,
          currentJuz: null,
          entriesByDate: <String, List<_EntrySpec>>{
            '2026-09-15': <_EntrySpec>[
              const _EntrySpec(status: null, achievedQuarterFaces: 0),
            ],
          },
        );

        final projection = builder.build(
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
          approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
            snapshot,
          ],
        );

        final items = projection.missingItemsForStudent(1);

        expect(
          items.where(
            (item) => item.field == ReportMissingField.supportStudentNumber,
          ),
          hasLength(1),
        );

        expect(
          items.where((item) => item.field == ReportMissingField.currentJuz),
          hasLength(1),
        );

        final attendanceItems = items
            .where((item) => item.field == ReportMissingField.attendanceStatus)
            .toList();

        expect(attendanceItems, hasLength(1));

        expect(attendanceItems.single.localDate, DateTime(2026, 9, 15));
      },
    );

    test('builds general monthly without sponsor-only policy fields', () {
      final snapshot = _snapshot(
        reportId: 8,
        weekDate: DateTime(2026, 9, 12),
        organizationName: 'مركز النور',
        supportStudentNumber: null,
        reportContext: SupportReportContext.general,
        entriesByDate: <String, List<_EntrySpec>>{
          '2026-09-14': <_EntrySpec>[
            const _EntrySpec(
              status: SupportReportAttendanceStatus.present,
              achievedQuarterFaces: 8,
            ),
          ],
        },
      );

      final projection = builder.build(
        period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
        approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
          snapshot,
        ],
      );

      final student = projection.students.single;

      expect(projection.header.reportContext, SupportReportContext.general);
      expect(projection.header.organizationName, 'مركز النور');
      expect(student.supportStudentNumber, isNull);
      expect(student.monthlyGoalQuarterFaces, isNull);
      expect(student.goalCompleted, isNull);
      expect(student.achievedQuarterFaces, 8);

      expect(
        projection.missingItems.where(
          (item) => item.field == ReportMissingField.supportStudentNumber,
        ),
        isEmpty,
      );
    });

    test('rejects mixed general and support weekly contexts', () {
      final support = _snapshot(
        reportId: 9,
        weekDate: DateTime(2026, 9, 5),
        organizationName: 'هوية تقرير واحدة',
        reportContext: SupportReportContext.support,
      );

      final general = _snapshot(
        reportId: 10,
        weekDate: DateTime(2026, 9, 12),
        organizationName: 'هوية تقرير واحدة',
        reportContext: SupportReportContext.general,
        supportStudentNumber: null,
      );

      expect(
        () => builder.build(
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
          approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
            support,
            general,
          ],
        ),
        throwsStateError,
      );
    });

    test(
      'rejects multiple support organizations in one monthly projection',
      () {
        final first = _snapshot(
          reportId: 4,
          weekDate: DateTime(2026, 9, 5),
          organizationName: 'الجهة أ',
        );

        final second = _snapshot(
          reportId: 5,
          weekDate: DateTime(2026, 9, 12),
          organizationName: 'الجهة ب',
        );

        expect(
          () => builder.build(
            period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
            approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
              first,
              second,
            ],
          ),
          throwsStateError,
        );
      },
    );

    test('rejects mixed or unsupported policy versions', () {
      final first = _snapshot(reportId: 6, weekDate: DateTime(2026, 9, 5));

      final second = _snapshot(
        reportId: 7,
        weekDate: DateTime(2026, 9, 12),
        policyVersion: 2,
      );

      expect(
        () => builder.build(
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
          approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
            first,
            second,
          ],
        ),
        throwsStateError,
      );
    });

    test('rejects a month with no approved weekly snapshot input', () {
      expect(
        () => builder.build(
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
          approvedWeeklySnapshots:
              const <ApprovedWeeklySupportReportSnapshot>[],
        ),
        throwsStateError,
      );
    });
  });
}

ApprovedWeeklySupportReportSnapshot _snapshot({
  required int reportId,
  required DateTime weekDate,
  String teacherName = 'المعلم',
  String organizationName = 'الجهة',
  SupportReportContext reportContext = SupportReportContext.support,
  String? supportStudentNumber = 'SUP-001',
  int? currentJuz = 2,
  String? dailyPlanText = 'نصف وجه',
  String? note,
  int policyVersion = SupportReportPolicy.policyVersion,
  int templateVersion = SupportReportPolicy.templateVersion,
  Map<String, List<_EntrySpec>> entriesByDate =
      const <String, List<_EntrySpec>>{},
}) {
  final period = WeeklySupportReportPeriod.forDate(weekDate);

  final student = ApprovedWeeklySupportReportStudentSnapshot(
    snapshotRowId: reportId * 100,
    sourceStudentId: 1,
    supportStudentNumber: supportStudentNumber,
    studentName: 'أحمد',
    currentJuz: currentJuz,
    dailyPlanText: dailyPlanText,
    monthlyGoalQuarterFaces: SupportReportPolicy.monthlyGoalQuarterFaces,
    note: note,
    displayOrder: 1,
  );

  final days = <ApprovedWeeklySupportReportDaySnapshot>[];

  var dayIndex = 0;
  var entryRowId = reportId * 1000;

  for (final date in period.officialDates) {
    dayIndex++;

    final specs =
        entriesByDate[_dateText(date)] ??
        const <_EntrySpec>[
          _EntrySpec(
            status: SupportReportAttendanceStatus.present,
            achievedQuarterFaces: 0,
          ),
        ];

    final entries = <ApprovedWeeklySupportReportDayEntrySnapshot>[];

    for (var index = 0; index < specs.length; index++) {
      final spec = specs[index];
      entryRowId++;

      entries.add(
        ApprovedWeeklySupportReportDayEntrySnapshot(
          snapshotRowId: entryRowId,
          sourceStudentId: 1,
          attendanceStatus: spec.status,
          achievedQuarterFaces: spec.achievedQuarterFaces,
          range: spec.achievedQuarterFaces > 0
              ? SupportReportQuranRange(
                  startSurah: 2,
                  startAyah: 1 + index * 5,
                  endSurah: 2,
                  endAyah: 5 + index * 5,
                )
              : null,
          note: spec.achievedQuarterFaces > 0 ? 'حفظ' : null,
          entryOrder: index + 1,
        ),
      );
    }

    days.add(
      ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: reportId * 10 + dayIndex,
        localDate: date,
        dayKind: SupportReportDayKind.normal,
        entries: entries,
      ),
    );
  }

  return ApprovedWeeklySupportReportSnapshot(
    reportId: reportId,
    halaqahId: 1,
    period: period,
    header: SupportReportHeaderSnapshot(
      teacherName: teacherName,
      halaqahName: 'الحلقة',
      organizationName: organizationName,
      reportContext: reportContext,
      policyVersion: policyVersion,
      templateVersion: templateVersion,
    ),
    sourceFingerprint: 'weekly-$reportId',
    approvedAtUtc: DateTime.utc(2026, 9, reportId.clamp(1, 28), 12),
    students: <ApprovedWeeklySupportReportStudentSnapshot>[student],
    days: days,
  );
}

final class _EntrySpec {
  const _EntrySpec({required this.status, required this.achievedQuarterFaces});

  final SupportReportAttendanceStatus? status;
  final int achievedQuarterFaces;
}

String _dateText(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
