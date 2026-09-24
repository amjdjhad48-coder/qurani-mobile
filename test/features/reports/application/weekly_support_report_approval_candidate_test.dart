import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  const service = WeeklySupportReportApprovalCandidateService();

  group('SupportReportSourceFingerprint', () {
    test('is deterministic for identical live projection', () async {
      final first = await service.buildCandidate(projection: _projection());

      final second = await service.buildCandidate(projection: _projection());

      expect(first.sourceFingerprint, second.sourceFingerprint);

      expect(first.sourceFingerprint, hasLength(64));
    });

    test('changes when source-backed attendance changes', () async {
      final present = await service.buildCandidate(
        projection: _projection(
          attendance: SupportReportAttendanceStatus.present,
        ),
      );

      final absent = await service.buildCandidate(
        projection: _projection(
          attendance: SupportReportAttendanceStatus.absent,
        ),
      );

      expect(present.sourceFingerprint, isNot(absent.sourceFingerprint));
    });

    test('changes when new memorization changes', () async {
      final first = await service.buildCandidate(
        projection: _projection(achievedQuarterFaces: 4),
      );

      final second = await service.buildCandidate(
        projection: _projection(achievedQuarterFaces: 8),
      );

      expect(first.sourceFingerprint, isNot(second.sourceFingerprint));
    });
  });

  group('weekly approval candidate', () {
    test(
      'requires explicit warning confirmation before approval can proceed',
      () async {
        final candidate = await service.buildCandidate(
          projection: _projection(withWarning: true),
        );

        expect(candidate.hasWarnings, isTrue);
        expect(candidate.warningsConfirmed, isFalse);
        expect(candidate.warningsAccepted, isFalse);

        final decision = await service.evaluateForApproval(
          candidate: candidate,
          artifactGate: const _SatisfiedGate(),
        );

        expect(decision.artifactGateResult.isSatisfied, isTrue);

        expect(decision.canCommitApproval, isFalse);
      },
    );

    test(
      'explicit warning confirmation allows gate evaluation to proceed',
      () async {
        final candidate = await service.buildCandidate(
          projection: _projection(withWarning: true),
          warningsConfirmed: true,
        );

        expect(candidate.warningsAccepted, isTrue);

        final decision = await service.evaluateForApproval(
          candidate: candidate,
          artifactGate: const _SatisfiedGate(),
        );

        expect(decision.canCommitApproval, isTrue);
      },
    );

    test(
      'candidate without warnings does not require override confirmation',
      () async {
        final candidate = await service.buildCandidate(
          projection: _projection(),
        );

        expect(candidate.hasWarnings, isFalse);
        expect(candidate.warningsAccepted, isTrue);

        final decision = await service.evaluateForApproval(
          candidate: candidate,
          artifactGate: const _SatisfiedGate(),
        );

        expect(decision.canCommitApproval, isTrue);
      },
    );
  });

  test(
    'weekly source fingerprint changes when report context changes',
    () async {
      final support = await service.buildCandidate(
        projection: _projection(reportContext: SupportReportContext.support),
      );

      final general = await service.buildCandidate(
        projection: _projection(reportContext: SupportReportContext.general),
      );

      expect(general.sourceFingerprint, isNot(support.sourceFingerprint));
    },
  );

  group('PrimaryReportArtifactGate', () {
    test(
      'Package 7 production gate keeps final approval unavailable before Package 8',
      () async {
        final candidate = await service.buildCandidate(
          projection: _projection(),
        );

        final decision = await service.evaluateForApproval(
          candidate: candidate,
          artifactGate: const Package7PrimaryReportArtifactGate(),
        );

        expect(
          decision.artifactGateResult.status,
          PrimaryReportArtifactGateStatus.unavailable,
        );

        expect(decision.artifactGateResult.isSatisfied, isFalse);

        expect(decision.canCommitApproval, isFalse);
      },
    );

    test('gate request carries report identity versions', () async {
      final candidate = await service.buildCandidate(projection: _projection());

      final request = candidate.artifactRequest;

      expect(request.kind, SupportReportArtifactKind.weekly);

      expect(request.policyVersion, SupportReportPolicy.policyVersion);

      expect(request.templateVersion, SupportReportPolicy.templateVersion);

      expect(request.sourceFingerprint, candidate.sourceFingerprint);
    });
  });
}

WeeklySupportReportProjection _projection({
  SupportReportAttendanceStatus attendance =
      SupportReportAttendanceStatus.present,
  int achievedQuarterFaces = 4,
  bool withWarning = false,
  SupportReportContext reportContext = SupportReportContext.support,
}) {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

  final student = WeeklySupportReportStudentProjection(
    sourceStudentId: 7,
    supportStudentNumber: 'SUP-007',
    studentName: 'أحمد',
    currentJuz: 2,
    dailyPlanText: 'نصف وجه',
    note: 'ملاحظة الطالب',
    monthlyGoalQuarterFaces: reportContext == SupportReportContext.support
        ? SupportReportPolicy.monthlyGoalQuarterFaces
        : null,
    displayOrder: 1,
  );

  final days = <WeeklySupportReportDayProjection>[];

  for (final date in period.officialDates) {
    days.add(
      WeeklySupportReportDayProjection(
        localDate: date,
        dayKind: SupportReportDayKind.normal,
        entries: <WeeklySupportReportDayEntryProjection>[
          WeeklySupportReportDayEntryProjection(
            sourceStudentId: 7,
            attendanceStatus: attendance,
            newMemorizationEntries: date == period.weekStart
                ? <WeeklySupportReportRecitationProjection>[
                    WeeklySupportReportRecitationProjection(
                      achievedQuarterFaces: achievedQuarterFaces,
                      range: const SupportReportQuranRange(
                        startSurah: 2,
                        startAyah: 1,
                        endSurah: 2,
                        endAyah: 5,
                      ),
                      note: 'حفظ جديد',
                    ),
                  ]
                : const <WeeklySupportReportRecitationProjection>[],
          ),
        ],
      ),
    );
  }

  return WeeklySupportReportProjection(
    period: period,
    header: SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'حلقة النور',
      organizationName: 'الجهة',
      reportContext: reportContext,
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: <WeeklySupportReportStudentProjection>[student],
    days: days,
    missingItems: withWarning
        ? <ReportMissingItem>[
            ReportMissingItem(
              studentId: 7,
              studentName: 'أحمد',
              field: ReportMissingField.attendanceStatus,
              localDate: DateTime(2026, 9, 15),
            ),
          ]
        : const <ReportMissingItem>[],
  );
}

final class _SatisfiedGate implements PrimaryReportArtifactGate {
  const _SatisfiedGate();

  @override
  Future<PrimaryReportArtifactGateResult> verify(
    PrimaryReportArtifactRequest request,
  ) async {
    return const PrimaryReportArtifactGateResult.satisfied(
      artifactHash:
          '0123456789abcdef0123456789abcdef'
          '0123456789abcdef0123456789abcdef',
    );
  }
}
