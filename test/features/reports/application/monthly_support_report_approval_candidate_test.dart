import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('MonthlySupportReportApprovalCandidate', () {
    test(
      'monthly source fingerprint is deterministic for identical projection',
      () async {
        const fingerprint = MonthlySupportReportSourceFingerprint();

        final first = await fingerprint.forMonthlyProjection(_projection());

        final second = await fingerprint.forMonthlyProjection(_projection());

        expect(first, second);
        expect(first, hasLength(64));
      },
    );

    test(
      'monthly fingerprint changes when actual monthly day detail changes',
      () async {
        const fingerprint = MonthlySupportReportSourceFingerprint();

        final first = await fingerprint.forMonthlyProjection(
          _projection(achievedQuarterFaces: 8),
        );

        final second = await fingerprint.forMonthlyProjection(
          _projection(achievedQuarterFaces: 12),
        );

        expect(first, isNot(second));
      },
    );

    test(
      'monthly source fingerprint changes when report context changes',
      () async {
        const fingerprint = MonthlySupportReportSourceFingerprint();

        final support = await fingerprint.forMonthlyProjection(
          _projection(reportContext: SupportReportContext.support),
        );

        final general = await fingerprint.forMonthlyProjection(
          _projection(reportContext: SupportReportContext.general),
        );

        expect(general, isNot(support));
      },
    );

    test('monthly candidate requires explicit warning confirmation', () async {
      const service = MonthlySupportReportApprovalCandidateService();

      final candidate = await service.buildCandidate(
        projection: _projection(withWarning: true),
      );

      expect(candidate.hasWarnings, isTrue);
      expect(candidate.warningsAccepted, isFalse);

      final confirmed = await service.buildCandidate(
        projection: _projection(withWarning: true),
        warningsConfirmed: true,
      );

      expect(confirmed.warningsAccepted, isTrue);
    });

    test(
      'monthly artifact request carries monthly kind and report versions',
      () async {
        const service = MonthlySupportReportApprovalCandidateService();

        final candidate = await service.buildCandidate(
          projection: _projection(),
        );

        expect(
          candidate.artifactRequest.kind,
          SupportReportArtifactKind.monthly,
        );

        expect(
          candidate.artifactRequest.policyVersion,
          SupportReportPolicy.policyVersion,
        );

        expect(
          candidate.artifactRequest.templateVersion,
          SupportReportPolicy.templateVersion,
        );

        expect(
          candidate.artifactRequest.sourceFingerprint,
          candidate.sourceFingerprint,
        );
      },
    );

    test(
      'Package 7 production gate keeps monthly final approval unavailable',
      () async {
        const service = MonthlySupportReportApprovalCandidateService();

        final candidate = await service.buildCandidate(
          projection: _projection(),
        );

        final decision = await service.evaluateForApproval(
          candidate: candidate,
          artifactGate: const Package7PrimaryReportArtifactGate(),
        );

        expect(decision.canCommitApproval, isFalse);

        expect(
          decision.artifactGateResult.status,
          PrimaryReportArtifactGateStatus.unavailable,
        );
      },
    );

    test(
      'monthly candidate rejects a day outside its approved weekly inputs',
      () async {
        const service = MonthlySupportReportApprovalCandidateService();

        await expectLater(
          service.buildCandidate(
            projection: _projection(daySourceWeeklyReportId: 999),
          ),
          throwsStateError,
        );
      },
    );
  });
}

MonthlySupportReportProjection _projection({
  int achievedQuarterFaces = 8,
  bool withWarning = false,
  int daySourceWeeklyReportId = 101,
  SupportReportContext reportContext = SupportReportContext.support,
}) {
  final monthlyPeriod = MonthlySupportReportPeriod.forDate(
    DateTime(2026, 9, 15),
  );

  final weeklyPeriod = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 5));

  return MonthlySupportReportProjection(
    halaqahId: 1,
    period: monthlyPeriod,
    header: SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'الحلقة',
      organizationName: 'الجهة',
      reportContext: reportContext,
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: <MonthlySupportReportStudentProjection>[
      MonthlySupportReportStudentProjection(
        sourceStudentId: 1,
        supportStudentNumber: withWarning ? null : 'SUP-001',
        studentName: 'أحمد',
        currentJuz: 2,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: SupportReportPolicy.monthlyGoalQuarterFaces,
        achievedQuarterFaces: achievedQuarterFaces,
        absenceDays: 0,
        goalCompleted: SupportReportPolicy.hasCompletedMonthlyGoal(
          achievedQuarterFaces,
        ),
        note: 'ملاحظة',
        displayOrder: 1,
      ),
    ],
    days: <MonthlySupportReportDayProjection>[
      MonthlySupportReportDayProjection(
        sourceWeeklyReportId: daySourceWeeklyReportId,
        localDate: DateTime(2026, 9, 5),
        dayKind: SupportReportDayKind.normal,
        entries: <MonthlySupportReportDayEntryProjection>[
          MonthlySupportReportDayEntryProjection(
            sourceStudentId: 1,
            attendanceStatus: SupportReportAttendanceStatus.present,
            achievedQuarterFaces: achievedQuarterFaces,
            range: achievedQuarterFaces == 0
                ? null
                : const SupportReportQuranRange(
                    startSurah: 2,
                    startAyah: 1,
                    endSurah: 2,
                    endAyah: 5,
                  ),
            note: achievedQuarterFaces == 0 ? null : 'حفظ',
            entryOrder: 1,
          ),
        ],
      ),
    ],
    weeklyInputs: <MonthlySupportReportWeeklyInputIdentity>[
      MonthlySupportReportWeeklyInputIdentity(
        reportId: 101,
        period: weeklyPeriod,
        sourceFingerprint: 'approved-weekly-source',
        approvedAtUtc: DateTime.utc(2026, 9, 10, 12),
      ),
    ],
    missingItems: withWarning
        ? <ReportMissingItem>[
            const ReportMissingItem(
              studentId: 1,
              studentName: 'أحمد',
              field: ReportMissingField.supportStudentNumber,
            ),
          ]
        : const <ReportMissingItem>[],
  );
}
