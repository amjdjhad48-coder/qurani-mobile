import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/core/database/app_database.dart';
import 'package:qurani/features/reports/data/drift_monthly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/data/drift_weekly_support_report_snapshot_repository.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_export_artifact.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('atomic report snapshot + primary artifact repository', () {
    test(
      'weekly approval commits snapshot and Excel metadata together',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);
        await _seedIdentity(database);

        final repository = DriftWeeklySupportReportSnapshotRepository(database);
        final projection = _weeklyProjection();

        await repository.replaceApprovedWithPrimaryArtifact(
          halaqahId: 1,
          projection: projection,
          sourceFingerprint: 'weekly-source',
          approvedAtUtc: DateTime.utc(2026, 9, 18, 10),
          primaryArtifact: _artifact('a'),
        );

        final snapshot = await repository.findApproved(
          halaqahId: 1,
          period: projection.period,
        );
        final artifacts = await database
            .select(database.reportExportArtifacts)
            .get();

        expect(snapshot, isNotNull);
        expect(artifacts, hasLength(1));
        expect(artifacts.single.weeklyReportId, snapshot!.reportId);
        expect(artifacts.single.monthlyReportId, isNull);
        expect(artifacts.single.format, 'excel');
        expect(
          artifacts.single.internalPath,
          'report_artifacts/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.xlsx',
        );
        expect(
          artifacts.single.sha256,
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        );
        expect(artifacts.single.templateVersion, 1);
        expect(artifacts.single.sizeBytes, 2048);
      },
    );

    test(
      'monthly approval commits snapshot and Excel metadata together',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);
        await _seedIdentity(database);

        final repository = DriftMonthlySupportReportSnapshotRepository(
          database,
        );
        final projection = _monthlyProjection();

        await repository.replaceApprovedWithPrimaryArtifact(
          halaqahId: 1,
          projection: projection,
          sourceFingerprint: 'monthly-source',
          approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
          primaryArtifact: _artifact('b'),
        );

        final snapshot = await repository.findApproved(
          halaqahId: 1,
          period: projection.period,
        );
        final artifacts = await database
            .select(database.reportExportArtifacts)
            .get();

        expect(snapshot, isNotNull);
        expect(artifacts, hasLength(1));
        expect(artifacts.single.weeklyReportId, isNull);
        expect(artifacts.single.monthlyReportId, snapshot!.reportId);
        expect(artifacts.single.format, 'excel');
        expect(
          artifacts.single.sha256,
          'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        );
        expect(artifacts.single.templateVersion, 1);
        expect(artifacts.single.sizeBytes, 2048);
      },
    );

    test(
      'failed weekly reapproval preserves previous snapshot and artifact metadata',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);
        await _seedIdentity(database);

        final repository = DriftWeeklySupportReportSnapshotRepository(database);
        final original = _weeklyProjection();

        await repository.replaceApprovedWithPrimaryArtifact(
          halaqahId: 1,
          projection: original,
          sourceFingerprint: 'original-source',
          approvedAtUtc: DateTime.utc(2026, 9, 18, 10),
          primaryArtifact: _artifact('c'),
        );

        await expectLater(
          repository.replaceApprovedWithPrimaryArtifact(
            halaqahId: 1,
            projection: _weeklyProjection(studentName: '   '),
            sourceFingerprint: 'replacement-source',
            approvedAtUtc: DateTime.utc(2026, 9, 18, 11),
            primaryArtifact: _artifact('d'),
          ),
          throwsA(anything),
        );

        final snapshot = await repository.findApproved(
          halaqahId: 1,
          period: original.period,
        );
        final artifacts = await database
            .select(database.reportExportArtifacts)
            .get();

        expect(snapshot, isNotNull);
        expect(snapshot!.sourceFingerprint, 'original-source');
        expect(artifacts, hasLength(1));
        expect(artifacts.single.weeklyReportId, snapshot.reportId);
        expect(
          artifacts.single.sha256,
          'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
        );
      },
    );
  });
}

SupportReportExportArtifactMetadata _artifact(String hexDigit) {
  final hash = List<String>.filled(64, hexDigit).join();

  return SupportReportExportArtifactMetadata(
    format: SupportReportExportFormat.excel,
    internalPath: 'report_artifacts/$hash.xlsx',
    sha256: hash,
    templateVersion: SupportReportPolicy.templateVersion,
    sizeBytes: 2048,
  );
}

WeeklySupportReportProjection _weeklyProjection({String studentName = 'أحمد'}) {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

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
    days: period.officialDates
        .map(
          (date) => WeeklySupportReportDayProjection(
            localDate: date,
            dayKind: SupportReportDayKind.normal,
            entries: <WeeklySupportReportDayEntryProjection>[
              WeeklySupportReportDayEntryProjection(
                sourceStudentId: 1,
                attendanceStatus: SupportReportAttendanceStatus.present,
                newMemorizationEntries: date == period.weekStart
                    ? const <WeeklySupportReportRecitationProjection>[
                        WeeklySupportReportRecitationProjection(
                          achievedQuarterFaces: 4,
                          range: SupportReportQuranRange(
                            startSurah: 2,
                            startAyah: 1,
                            endSurah: 2,
                            endAyah: 5,
                          ),
                          note: 'حفظ',
                        ),
                      ]
                    : const <WeeklySupportReportRecitationProjection>[],
              ),
            ],
          ),
        )
        .toList(growable: false),
    missingItems: const <ReportMissingItem>[],
  );
}

MonthlySupportReportProjection _monthlyProjection() {
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
        sourceStudentId: 1,
        supportStudentNumber: 'SUP-001',
        studentName: 'أحمد',
        currentJuz: 2,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: SupportReportPolicy.monthlyGoalQuarterFaces,
        achievedQuarterFaces: 8,
        absenceDays: 0,
        goalCompleted: false,
        note: 'ملاحظة شهرية',
        displayOrder: 1,
      ),
    ],
    days: <MonthlySupportReportDayProjection>[
      MonthlySupportReportDayProjection(
        sourceWeeklyReportId: 101,
        localDate: DateTime(2026, 9, 5),
        dayKind: SupportReportDayKind.normal,
        entries: const <MonthlySupportReportDayEntryProjection>[
          MonthlySupportReportDayEntryProjection(
            sourceStudentId: 1,
            attendanceStatus: SupportReportAttendanceStatus.present,
            achievedQuarterFaces: 8,
            range: SupportReportQuranRange(
              startSurah: 2,
              startAyah: 1,
              endSurah: 2,
              endAyah: 5,
            ),
            note: 'حفظ',
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
    missingItems: const <ReportMissingItem>[],
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
    "previous_memorization_text, support_student_number, "
    "display_order, is_active) "
    "VALUES ("
    "1, 1, 'أحمد', 'محمد', 12, '+967', "
    "'771234567', 'حفظ سابق', 'SUP-001', 1, 1"
    ");",
  );
}
