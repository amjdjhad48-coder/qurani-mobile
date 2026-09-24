import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/drift_monthly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('MonthlySupportReportApprovalService', () {
    test(
      'successful monthly approval writes approved aggregate snapshot',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        addTearDown(database.close);

        await _seed(database);

        final repository = DriftMonthlySupportReportSnapshotRepository(
          database,
        );

        final approvalService = MonthlySupportReportApprovalService(
          repository: repository,
        );

        const candidateService = MonthlySupportReportApprovalCandidateService();

        final candidate = await candidateService.buildCandidate(
          projection: _projection(achievedQuarterFaces: 80, absenceDays: 2),
        );

        final gate = _SatisfiedArtifactGate();

        final outcome = await approvalService.approve(
          halaqahId: 1,
          candidate: candidate,
          artifactGate: gate,
          approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
        );

        expect(outcome.isApproved, isTrue);
        expect(gate.calls, 1);
        expect(gate.lastRequest?.kind, SupportReportArtifactKind.monthly);

        final snapshot = outcome.snapshot!;

        expect(snapshot.sourceFingerprint, candidate.sourceFingerprint);

        expect(snapshot.period.monthStart, DateTime(2026, 9, 1));

        expect(snapshot.students, hasLength(1));

        expect(snapshot.students.single.achievedQuarterFaces, 80);

        expect(snapshot.students.single.absenceDays, 2);

        expect(snapshot.students.single.goalCompleted, isTrue);

        expect(snapshot.days, hasLength(1));
        final snapshotDay = snapshot.days.single;
        expect(snapshotDay.sourceWeeklyReportId, 101);
        expect(snapshotDay.localDate, DateTime(2026, 9, 5));
        expect(snapshotDay.dayKind, SupportReportDayKind.normal);
        expect(snapshotDay.entries, hasLength(1));

        final snapshotEntry = snapshotDay.entries.single;
        expect(snapshotEntry.sourceStudentId, 1);
        expect(
          snapshotEntry.attendanceStatus,
          SupportReportAttendanceStatus.present,
        );
        expect(snapshotEntry.achievedQuarterFaces, 80);
        expect(snapshotEntry.range?.startSurah, 2);
        expect(snapshotEntry.range?.startAyah, 1);
        expect(snapshotEntry.range?.endSurah, 2);
        expect(snapshotEntry.range?.endAyah, 5);
        expect(snapshotEntry.note, 'حفظ');

        final monthlyRows = await database
            .select(database.supportMonthlyReports)
            .get();

        final studentRows = await database
            .select(database.supportMonthlyReportStudents)
            .get();
        final dayRows = await database
            .select(database.supportMonthlyReportDays)
            .get();
        final entryRows = await database
            .select(database.supportMonthlyReportDayEntries)
            .get();

        expect(monthlyRows, hasLength(1));
        expect(studentRows, hasLength(1));
        expect(dayRows, hasLength(1));
        expect(entryRows, hasLength(1));
        expect(monthlyRows.single.status, 'approved');
      },
    );

    test(
      'Package 7 production artifact gate prevents monthly snapshot write',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        addTearDown(database.close);

        await _seed(database);

        final repository = DriftMonthlySupportReportSnapshotRepository(
          database,
        );

        final service = MonthlySupportReportApprovalService(
          repository: repository,
        );

        const candidateService = MonthlySupportReportApprovalCandidateService();

        final candidate = await candidateService.buildCandidate(
          projection: _projection(),
        );

        final outcome = await service.approve(
          halaqahId: 1,
          candidate: candidate,
          artifactGate: const Package7PrimaryReportArtifactGate(),
          approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
        );

        expect(
          outcome.status,
          MonthlySupportReportApprovalOutcomeStatus.primaryArtifactNotSatisfied,
        );

        final rows = await database
            .select(database.supportMonthlyReports)
            .get();

        expect(rows, isEmpty);
      },
    );

    test(
      'unconfirmed monthly warnings stop before artifact gate and write nothing',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        addTearDown(database.close);

        await _seed(database);

        final repository = DriftMonthlySupportReportSnapshotRepository(
          database,
        );

        final service = MonthlySupportReportApprovalService(
          repository: repository,
        );

        const candidateService = MonthlySupportReportApprovalCandidateService();

        final candidate = await candidateService.buildCandidate(
          projection: _projection(withWarning: true),
        );

        final gate = _SatisfiedArtifactGate();

        final outcome = await service.approve(
          halaqahId: 1,
          candidate: candidate,
          artifactGate: gate,
          approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
        );

        expect(
          outcome.status,
          MonthlySupportReportApprovalOutcomeStatus.warningsNotConfirmed,
        );

        expect(gate.calls, 0);

        final rows = await database
            .select(database.supportMonthlyReports)
            .get();

        expect(rows, isEmpty);
      },
    );

    test(
      'monthly source change marks approved snapshot stale until reapproval',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        addTearDown(database.close);

        await _seed(database);

        final repository = DriftMonthlySupportReportSnapshotRepository(
          database,
        );

        final service = MonthlySupportReportApprovalService(
          repository: repository,
        );

        const candidateService = MonthlySupportReportApprovalCandidateService();

        final firstCandidate = await candidateService.buildCandidate(
          projection: _projection(achievedQuarterFaces: 40),
        );

        await service.approve(
          halaqahId: 1,
          candidate: firstCandidate,
          artifactGate: _SatisfiedArtifactGate(),
          approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
        );

        final changedCandidate = await candidateService.buildCandidate(
          projection: _projection(achievedQuarterFaces: 44),
        );

        final stale = await service.compareWithApproved(
          halaqahId: 1,
          candidate: changedCandidate,
        );

        expect(stale.freshness, MonthlySupportReportSnapshotFreshness.stale);

        await service.approve(
          halaqahId: 1,
          candidate: changedCandidate,
          artifactGate: _SatisfiedArtifactGate(),
          approvedAtUtc: DateTime.utc(2026, 10, 2, 10),
        );

        final current = await service.compareWithApproved(
          halaqahId: 1,
          candidate: changedCandidate,
        );

        expect(
          current.freshness,
          MonthlySupportReportSnapshotFreshness.current,
        );
      },
    );

    test(
      'failed monthly reapproval rolls back and preserves previous approved snapshot',
      () async {
        final database = AppDatabase(NativeDatabase.memory());

        addTearDown(database.close);

        await _seed(database);

        final repository = DriftMonthlySupportReportSnapshotRepository(
          database,
        );

        final service = MonthlySupportReportApprovalService(
          repository: repository,
        );

        const candidateService = MonthlySupportReportApprovalCandidateService();

        final firstCandidate = await candidateService.buildCandidate(
          projection: _projection(),
        );

        await service.approve(
          halaqahId: 1,
          candidate: firstCandidate,
          artifactGate: _SatisfiedArtifactGate(),
          approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
        );

        final invalidCandidate = await candidateService.buildCandidate(
          projection: _projection(sourceStudentId: 999),
        );

        await expectLater(
          service.approve(
            halaqahId: 1,
            candidate: invalidCandidate,
            artifactGate: _SatisfiedArtifactGate(),
            approvedAtUtc: DateTime.utc(2026, 10, 2, 10),
          ),
          throwsA(anything),
        );

        final preserved = await repository.findApproved(
          halaqahId: 1,
          period: MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15)),
        );

        expect(preserved, isNotNull);

        expect(preserved!.sourceFingerprint, firstCandidate.sourceFingerprint);

        expect(preserved.students.single.sourceStudentId, 1);

        final reports = await database
            .select(database.supportMonthlyReports)
            .get();

        expect(reports, hasLength(1));
      },
    );
  });
}

Future<void> _seed(AppDatabase database) async {
  await database.customStatement(
    "INSERT INTO halaqahs "
    "(id, teacher_name, halaqah_name, center_name, "
    "created_at_utc, updated_at_utc) "
    "VALUES ("
    "1, 'المعلم', 'الحلقة', 'المركز', "
    "'2026-09-01T10:00:00.000Z', "
    "'2026-09-01T10:00:00.000Z'"
    ");",
  );

  await database.customStatement(
    "INSERT INTO students "
    "(id, halaqah_id, student_name, father_name, age_years, "
    "guardian_country_code, guardian_national_number, "
    "previous_memorization_text, support_student_number, "
    "display_order, is_active) "
    "VALUES ("
    "1, 1, 'أحمد', 'محمد', 12, '+967', "
    "'771234567', 'حفظ سابق', 'SUP-001', 1, 1"
    ");",
  );
}

MonthlySupportReportProjection _projection({
  int sourceStudentId = 1,
  int achievedQuarterFaces = 8,
  int absenceDays = 0,
  bool withWarning = false,
}) {
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));

  final weeklyPeriod = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 5));

  return MonthlySupportReportProjection(
    halaqahId: 1,
    period: period,
    header: const SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'الحلقة',
      organizationName: 'الجهة',
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: <MonthlySupportReportStudentProjection>[
      MonthlySupportReportStudentProjection(
        sourceStudentId: sourceStudentId,
        supportStudentNumber: withWarning ? null : 'SUP-001',
        studentName: 'أحمد',
        currentJuz: 2,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: SupportReportPolicy.monthlyGoalQuarterFaces,
        achievedQuarterFaces: achievedQuarterFaces,
        absenceDays: absenceDays,
        goalCompleted: SupportReportPolicy.hasCompletedMonthlyGoal(
          achievedQuarterFaces,
        ),
        note: 'ملاحظة شهرية',
        displayOrder: 1,
      ),
    ],
    days: <MonthlySupportReportDayProjection>[
      MonthlySupportReportDayProjection(
        sourceWeeklyReportId: 101,
        localDate: DateTime(2026, 9, 5),
        dayKind: SupportReportDayKind.normal,
        entries: <MonthlySupportReportDayEntryProjection>[
          MonthlySupportReportDayEntryProjection(
            sourceStudentId: sourceStudentId,
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
            ReportMissingItem(
              studentId: sourceStudentId,
              studentName: 'أحمد',
              field: ReportMissingField.supportStudentNumber,
            ),
          ]
        : const <ReportMissingItem>[],
  );
}

final class _SatisfiedArtifactGate implements PrimaryReportArtifactGate {
  int calls = 0;
  PrimaryReportArtifactRequest? lastRequest;

  @override
  Future<PrimaryReportArtifactGateResult> verify(
    PrimaryReportArtifactRequest request,
  ) async {
    calls++;
    lastRequest = request;

    return const PrimaryReportArtifactGateResult.satisfied(
      artifactHash: 'test-only-verified-excel-hash',
    );
  }
}
