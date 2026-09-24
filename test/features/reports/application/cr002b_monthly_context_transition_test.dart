import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/monthly_support_report_projection_builder.dart';
import 'package:qurani/features/reports/application/package8_support_report_approval_reloaders.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  const builder = MonthlySupportReportProjectionBuilder();

  group('CR-P8-REPORTS-002B monthly transition policy', () {
    test(
      'multiple support organizations become General with halaqah center',
      () {
        final projection = builder.build(
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
          approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
            _snapshot(
              reportId: 1,
              weekDate: DateTime(2026, 9, 5),
              organizationName: 'الجهة أ',
              context: SupportReportContext.support,
            ),
            _snapshot(
              reportId: 2,
              weekDate: DateTime(2026, 9, 12),
              organizationName: 'الجهة ب',
              context: SupportReportContext.support,
            ),
          ],
          centerName: '  مركز النور  ',
        );

        expect(projection.header.reportContext, SupportReportContext.general);
        expect(projection.header.organizationName, 'مركز النور');

        final student = projection.students.single;

        expect(student.supportStudentNumber, isNull);
        expect(student.monthlyGoalQuarterFaces, isNull);
        expect(student.goalCompleted, isNull);
      },
    );

    test(
      'mixed General and Support weeks become General with halaqah center',
      () {
        final projection = builder.build(
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
          approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
            _snapshot(
              reportId: 3,
              weekDate: DateTime(2026, 9, 5),
              organizationName: 'الجهة',
              context: SupportReportContext.support,
            ),
            _snapshot(
              reportId: 4,
              weekDate: DateTime(2026, 9, 12),
              organizationName: 'هوية عامة تاريخية',
              context: SupportReportContext.general,
            ),
          ],
          centerName: 'المركز المعتمد',
        );

        expect(projection.header.reportContext, SupportReportContext.general);
        expect(projection.header.organizationName, 'المركز المعتمد');

        final student = projection.students.single;

        expect(student.supportStudentNumber, isNull);
        expect(student.monthlyGoalQuarterFaces, isNull);
        expect(student.goalCompleted, isNull);
      },
    );

    test('one support organization remains Support', () {
      final projection = builder.build(
        period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
        approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
          _snapshot(
            reportId: 5,
            weekDate: DateTime(2026, 9, 5),
            organizationName: 'الجهة الواحدة',
            context: SupportReportContext.support,
          ),
          _snapshot(
            reportId: 6,
            weekDate: DateTime(2026, 9, 12),
            organizationName: 'الجهة الواحدة',
            context: SupportReportContext.support,
          ),
        ],
        centerName: 'المركز',
      );

      expect(projection.header.reportContext, SupportReportContext.support);
      expect(projection.header.organizationName, 'الجهة الواحدة');

      final student = projection.students.single;

      expect(student.supportStudentNumber, 'SUP-001');
      expect(
        student.monthlyGoalQuarterFaces,
        SupportReportPolicy.monthlyGoalQuarterFaces,
      );
    });

    test(
      'transition refuses to invent center identity when none is supplied',
      () {
        expect(
          () => builder.build(
            period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
            approvedWeeklySnapshots: <ApprovedWeeklySupportReportSnapshot>[
              _snapshot(
                reportId: 7,
                weekDate: DateTime(2026, 9, 5),
                organizationName: 'الجهة أ',
                context: SupportReportContext.support,
              ),
              _snapshot(
                reportId: 8,
                weekDate: DateTime(2026, 9, 12),
                organizationName: 'الجهة ب',
                context: SupportReportContext.support,
              ),
            ],
          ),
          throwsStateError,
        );
      },
    );

    test('approval reloader reloads canonical center identity', () async {
      final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));

      var loadedHalaqahId = -1;

      final reloader = ProductionMonthlySupportReportApprovalCandidateReloader(
        weeklyRepository: _FakeApprovedWeeklyReportsForMonthRepository(
          <ApprovedWeeklySupportReportSnapshot>[
            _snapshot(
              reportId: 9,
              weekDate: DateTime(2026, 9, 5),
              organizationName: 'الجهة أ',
              context: SupportReportContext.support,
            ),
            _snapshot(
              reportId: 10,
              weekDate: DateTime(2026, 9, 12),
              organizationName: 'الجهة ب',
              context: SupportReportContext.support,
            ),
          ],
        ),
        generalCenterNameLoader: (halaqahId) async {
          loadedHalaqahId = halaqahId;
          return ' مركز النور ';
        },
      );

      final candidate = await reloader.reload(halaqahId: 1, period: period);

      expect(loadedHalaqahId, 1);
      expect(
        candidate.projection.header.reportContext,
        SupportReportContext.general,
      );
      expect(candidate.projection.header.organizationName, 'مركز النور');
      expect(candidate.sourceFingerprint, hasLength(64));
      expect(candidate.warningsConfirmed, isFalse);
    });
  });
}

ApprovedWeeklySupportReportSnapshot _snapshot({
  required int reportId,
  required DateTime weekDate,
  required String organizationName,
  required SupportReportContext context,
}) {
  final period = WeeklySupportReportPeriod.forDate(weekDate);
  final support = context == SupportReportContext.support;

  return ApprovedWeeklySupportReportSnapshot(
    reportId: reportId,
    halaqahId: 1,
    period: period,
    header: SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'الحلقة',
      organizationName: organizationName,
      reportContext: context,
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    sourceFingerprint: 'weekly-$reportId',
    approvedAtUtc: DateTime.utc(2026, 9, reportId.clamp(1, 28), 12),
    students: <ApprovedWeeklySupportReportStudentSnapshot>[
      ApprovedWeeklySupportReportStudentSnapshot(
        snapshotRowId: reportId * 100,
        sourceStudentId: 1,
        supportStudentNumber: support ? 'SUP-001' : null,
        studentName: 'أحمد',
        currentJuz: 3,
        dailyPlanText: 'وجه',
        monthlyGoalQuarterFaces: support
            ? SupportReportPolicy.monthlyGoalQuarterFaces
            : null,
        note: null,
        displayOrder: 1,
      ),
    ],
    days: <ApprovedWeeklySupportReportDaySnapshot>[
      ApprovedWeeklySupportReportDaySnapshot(
        snapshotRowId: reportId * 10,
        localDate: period.weekStart,
        dayKind: SupportReportDayKind.normal,
        entries: <ApprovedWeeklySupportReportDayEntrySnapshot>[
          ApprovedWeeklySupportReportDayEntrySnapshot(
            snapshotRowId: reportId * 1000,
            sourceStudentId: 1,
            attendanceStatus: SupportReportAttendanceStatus.present,
            achievedQuarterFaces: 4,
            range: null,
            note: null,
            entryOrder: 1,
          ),
        ],
      ),
    ],
  );
}

final class _FakeApprovedWeeklyReportsForMonthRepository
    implements ApprovedWeeklySupportReportsForMonthRepository {
  _FakeApprovedWeeklyReportsForMonthRepository(this.snapshots);

  final List<ApprovedWeeklySupportReportSnapshot> snapshots;

  @override
  Future<List<ApprovedWeeklySupportReportSnapshot>>
  findApprovedIntersectingMonth({
    required int halaqahId,
    required MonthlySupportReportPeriod period,
  }) async {
    return snapshots;
  }
}
