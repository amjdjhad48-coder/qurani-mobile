import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/weekly_support_report_approval_service.dart';
import 'package:qurani/features/reports/data/drift_weekly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  const candidateService = WeeklySupportReportApprovalCandidateService();

  test(
    'successful approval writes approved snapshot and preserves recitation ordering',
    () async {
      final database = AppDatabase(NativeDatabase.memory());

      addTearDown(database.close);

      await _seedIdentity(database);

      final repository = DriftWeeklySupportReportSnapshotRepository(database);

      final service = WeeklySupportReportApprovalService(
        repository: repository,
      );

      final candidate = await candidateService.buildCandidate(
        projection: _projection(achievedQuarterFaces: <int>[4, 8]),
      );

      final gate = _SatisfiedGate();

      final result = await service.approve(
        halaqahId: 1,
        candidate: candidate,
        artifactGate: gate,
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );

      expect(result.isApproved, isTrue);
      expect(gate.callCount, 1);

      final snapshot = result.snapshot!;

      expect(snapshot.halaqahId, 1);
      expect(snapshot.sourceFingerprint, candidate.sourceFingerprint);
      expect(snapshot.approvedAtUtc, DateTime.utc(2026, 9, 17, 10));
      expect(snapshot.students, hasLength(1));
      expect(snapshot.days, hasLength(5));

      final firstDay = snapshot.days.first;

      expect(firstDay.entries, hasLength(2));

      expect(
        firstDay.entries[0].attendanceStatus,
        SupportReportAttendanceStatus.present,
      );

      expect(firstDay.entries[0].achievedQuarterFaces, 4);

      expect(firstDay.entries[0].entryOrder, 1);

      expect(firstDay.entries[1].attendanceStatus, isNull);

      expect(firstDay.entries[1].achievedQuarterFaces, 8);

      expect(firstDay.entries[1].entryOrder, 2);

      for (final day in snapshot.days.skip(1)) {
        expect(day.entries, hasLength(1));
        expect(
          day.entries.single.attendanceStatus,
          SupportReportAttendanceStatus.present,
        );
        expect(day.entries.single.achievedQuarterFaces, 0);
        expect(day.entries.single.range, isNull);
      }

      final reportCount = await database
          .customSelect(
            'SELECT COUNT(*) AS row_count '
            'FROM support_weekly_reports;',
          )
          .getSingle();

      final entryCount = await database
          .customSelect(
            'SELECT COUNT(*) AS row_count '
            'FROM support_weekly_report_day_entries;',
          )
          .getSingle();

      expect(reportCount.read<int>('row_count'), 1);

      expect(entryCount.read<int>('row_count'), 6);
    },
  );

  test('Package 7 production artifact gate prevents snapshot write', () async {
    final database = AppDatabase(NativeDatabase.memory());

    addTearDown(database.close);

    await _seedIdentity(database);

    final repository = DriftWeeklySupportReportSnapshotRepository(database);

    final service = WeeklySupportReportApprovalService(repository: repository);

    final candidate = await candidateService.buildCandidate(
      projection: _projection(),
    );

    final result = await service.approve(
      halaqahId: 1,
      candidate: candidate,
      artifactGate: const Package7PrimaryReportArtifactGate(),
      approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
    );

    expect(
      result.status,
      WeeklySupportReportApprovalOutcomeStatus.primaryArtifactNotSatisfied,
    );

    expect(result.isApproved, isFalse);

    final row = await database
        .customSelect(
          'SELECT COUNT(*) AS row_count '
          'FROM support_weekly_reports;',
        )
        .getSingle();

    expect(row.read<int>('row_count'), 0);
  });

  test(
    'unconfirmed warnings stop before artifact gate and write nothing',
    () async {
      final database = AppDatabase(NativeDatabase.memory());

      addTearDown(database.close);

      await _seedIdentity(database);

      final repository = DriftWeeklySupportReportSnapshotRepository(database);

      final service = WeeklySupportReportApprovalService(
        repository: repository,
      );

      final candidate = await candidateService.buildCandidate(
        projection: _projection(withWarning: true),
      );

      final gate = _SatisfiedGate();

      final result = await service.approve(
        halaqahId: 1,
        candidate: candidate,
        artifactGate: gate,
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );

      expect(
        result.status,
        WeeklySupportReportApprovalOutcomeStatus.warningsNotConfirmed,
      );

      expect(gate.callCount, 0);

      final row = await database
          .customSelect(
            'SELECT COUNT(*) AS row_count '
            'FROM support_weekly_reports;',
          )
          .getSingle();

      expect(row.read<int>('row_count'), 0);
    },
  );

  test(
    'source correction marks approved snapshot stale until successful reapproval',
    () async {
      final database = AppDatabase(NativeDatabase.memory());

      addTearDown(database.close);

      await _seedIdentity(database);

      final repository = DriftWeeklySupportReportSnapshotRepository(database);

      final service = WeeklySupportReportApprovalService(
        repository: repository,
      );

      final original = await candidateService.buildCandidate(
        projection: _projection(
          attendance: SupportReportAttendanceStatus.present,
          achievedQuarterFaces: <int>[4],
        ),
      );

      await service.approve(
        halaqahId: 1,
        candidate: original,
        artifactGate: _SatisfiedGate(),
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );

      final currentComparison = await service.compareWithApproved(
        halaqahId: 1,
        candidate: original,
      );

      expect(
        currentComparison.freshness,
        WeeklySupportReportSnapshotFreshness.current,
      );

      final corrected = await candidateService.buildCandidate(
        projection: _projection(
          attendance: SupportReportAttendanceStatus.absent,
          achievedQuarterFaces: <int>[8],
        ),
      );

      final staleComparison = await service.compareWithApproved(
        halaqahId: 1,
        candidate: corrected,
      );

      expect(staleComparison.isStale, isTrue);

      expect(
        staleComparison.approvedSnapshot!.sourceFingerprint,
        original.sourceFingerprint,
      );

      expect(
        staleComparison.approvedSnapshot!.sourceFingerprint,
        isNot(corrected.sourceFingerprint),
      );

      final reapproval = await service.approve(
        halaqahId: 1,
        candidate: corrected,
        artifactGate: _SatisfiedGate(),
        approvedAtUtc: DateTime.utc(2026, 9, 18, 11),
      );

      expect(reapproval.isApproved, isTrue);

      final afterComparison = await service.compareWithApproved(
        halaqahId: 1,
        candidate: corrected,
      );

      expect(
        afterComparison.freshness,
        WeeklySupportReportSnapshotFreshness.current,
      );

      expect(
        afterComparison.approvedSnapshot!.sourceFingerprint,
        corrected.sourceFingerprint,
      );

      expect(
        afterComparison.approvedSnapshot!.approvedAtUtc,
        DateTime.utc(2026, 9, 18, 11),
      );

      final row = await database
          .customSelect(
            'SELECT COUNT(*) AS row_count '
            'FROM support_weekly_reports;',
          )
          .getSingle();

      expect(row.read<int>('row_count'), 1);
    },
  );

  test(
    'failed reapproval rolls back and preserves previous approved snapshot',
    () async {
      final database = AppDatabase(NativeDatabase.memory());

      addTearDown(database.close);

      await _seedIdentity(database);

      final repository = DriftWeeklySupportReportSnapshotRepository(database);

      final service = WeeklySupportReportApprovalService(
        repository: repository,
      );

      final original = await candidateService.buildCandidate(
        projection: _projection(),
      );

      await service.approve(
        halaqahId: 1,
        candidate: original,
        artifactGate: _SatisfiedGate(),
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );

      final badCandidate = await candidateService.buildCandidate(
        projection: _projection(
          studentName: '   ',
          achievedQuarterFaces: <int>[8],
        ),
      );

      await expectLater(
        service.approve(
          halaqahId: 1,
          candidate: badCandidate,
          artifactGate: _SatisfiedGate(),
          approvedAtUtc: DateTime.utc(2026, 9, 18, 11),
        ),
        throwsA(anything),
      );

      final preserved = await repository.findApproved(
        halaqahId: 1,
        period: original.projection.period,
      );

      expect(preserved, isNotNull);

      expect(preserved!.sourceFingerprint, original.sourceFingerprint);

      expect(preserved.approvedAtUtc, DateTime.utc(2026, 9, 17, 10));

      final row = await database
          .customSelect(
            'SELECT COUNT(*) AS row_count '
            'FROM support_weekly_reports;',
          )
          .getSingle();

      expect(row.read<int>('row_count'), 1);
    },
  );
}

WeeklySupportReportProjection _projection({
  String studentName = 'أحمد',
  SupportReportAttendanceStatus attendance =
      SupportReportAttendanceStatus.present,
  List<int> achievedQuarterFaces = const <int>[4],
  bool withWarning = false,
}) {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

  final days = <WeeklySupportReportDayProjection>[];

  for (final date in period.officialDates) {
    final isFirstDay = date == period.weekStart;

    final recitations = isFirstDay
        ? achievedQuarterFaces
              .asMap()
              .entries
              .map(
                (entry) => WeeklySupportReportRecitationProjection(
                  achievedQuarterFaces: entry.value,
                  range: SupportReportQuranRange(
                    startSurah: 2,
                    startAyah: 1 + entry.key * 5,
                    endSurah: 2,
                    endAyah: 5 + entry.key * 5,
                  ),
                  note: 'حفظ جديد ${entry.key + 1}',
                ),
              )
              .toList(growable: false)
        : const <WeeklySupportReportRecitationProjection>[];

    days.add(
      WeeklySupportReportDayProjection(
        localDate: date,
        dayKind: SupportReportDayKind.normal,
        entries: <WeeklySupportReportDayEntryProjection>[
          WeeklySupportReportDayEntryProjection(
            sourceStudentId: 1,
            attendanceStatus: attendance,
            newMemorizationEntries: recitations,
          ),
        ],
      ),
    );
  }

  return WeeklySupportReportProjection(
    period: period,
    header: const SupportReportHeaderSnapshot(
      teacherName: 'المعلم',
      halaqahName: 'حلقة النور',
      organizationName: 'الجهة',
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: <WeeklySupportReportStudentProjection>[
      WeeklySupportReportStudentProjection(
        sourceStudentId: 1,
        supportStudentNumber: 'SUP-001',
        studentName: studentName,
        currentJuz: 2,
        dailyPlanText: 'نصف وجه',
        note: 'ملاحظة الطالب',
        displayOrder: 1,
      ),
    ],
    days: days,
    missingItems: withWarning
        ? <ReportMissingItem>[
            ReportMissingItem(
              studentId: 1,
              studentName: studentName,
              field: ReportMissingField.attendanceStatus,
              localDate: DateTime(2026, 9, 15),
            ),
          ]
        : const <ReportMissingItem>[],
  );
}

Future<void> _seedIdentity(AppDatabase database) async {
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
    "previous_memorization_text, display_order, is_active) "
    "VALUES ("
    "1, 1, 'أحمد', 'محمد', 12, '+967', "
    "'771234567', 'حفظ سابق', 1, 1"
    ");",
  );
}

final class _SatisfiedGate implements PrimaryReportArtifactGate {
  int callCount = 0;

  @override
  Future<PrimaryReportArtifactGateResult> verify(
    PrimaryReportArtifactRequest request,
  ) async {
    callCount++;

    return const PrimaryReportArtifactGateResult.satisfied(
      artifactHash:
          '0123456789abcdef0123456789abcdef'
          '0123456789abcdef0123456789abcdef',
    );
  }
}
