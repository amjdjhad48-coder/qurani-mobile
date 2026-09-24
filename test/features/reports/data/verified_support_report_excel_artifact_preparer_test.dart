import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/data/support_report_artifact_file_store.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_artifact_preparer.dart';
import 'package:qurani/features/reports/data/verified_support_report_excel_generator.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';

void main() {
  group('VerifiedSupportReportExcelArtifactPreparer', () {
    test(
      'weekly candidate survives private disk close/reopen semantic verification',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p8_weekly_candidate_',
        );

        try {
          final store = SupportReportArtifactFileStore(
            applicationSupportDirectory: root,
          );
          final preparer = VerifiedSupportReportExcelArtifactPreparer(
            fileStore: store,
          );
          final projection = _weeklyProjection();
          const fingerprint =
              '1111111111111111111111111111111111111111111111111111111111111111';

          final artifact = await preparer.prepareWeekly(
            halaqahId: 1,
            projection: projection,
            sourceFingerprint: fingerprint,
          );

          expect(artifact.kind, SupportReportArtifactKind.weekly);
          expect(artifact.sourceFingerprint, fingerprint);
          expect(artifact.templateVersion, SupportReportPolicy.templateVersion);
          expect(
            artifact.internalPath,
            'report_artifacts/${artifact.sha256}.xlsx',
          );
          expect(artifact.sizeBytes, greaterThan(1000));

          final reopened = await store.readVerifiedPreparedBytes(artifact);
          final semantic = const VerifiedSupportReportExcelGenerator()
              .verifyWeeklyCandidateBytes(
                bytes: reopened,
                halaqahId: 1,
                projection: projection,
                sourceFingerprint: fingerprint,
              );

          expect(semantic.isValid, isTrue);
        } finally {
          await root.delete(recursive: true);
        }
      },
    );

    test(
      'monthly candidate survives private disk close/reopen semantic verification',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p8_monthly_candidate_',
        );

        try {
          final store = SupportReportArtifactFileStore(
            applicationSupportDirectory: root,
          );
          final preparer = VerifiedSupportReportExcelArtifactPreparer(
            fileStore: store,
          );
          final projection = _monthlyProjection();
          const fingerprint =
              '2222222222222222222222222222222222222222222222222222222222222222';

          final artifact = await preparer.prepareMonthly(
            projection: projection,
            sourceFingerprint: fingerprint,
          );

          expect(artifact.kind, SupportReportArtifactKind.monthly);
          expect(artifact.sourceFingerprint, fingerprint);
          expect(artifact.templateVersion, SupportReportPolicy.templateVersion);
          expect(
            artifact.internalPath,
            'report_artifacts/${artifact.sha256}.xlsx',
          );
          expect(artifact.sizeBytes, greaterThan(1000));

          final reopened = await store.readVerifiedPreparedBytes(artifact);
          final semantic = const VerifiedSupportReportExcelGenerator()
              .verifyMonthlyCandidateBytes(
                bytes: reopened,
                projection: projection,
                sourceFingerprint: fingerprint,
              );

          expect(semantic.isValid, isTrue);
        } finally {
          await root.delete(recursive: true);
        }
      },
    );

    test(
      'verified prepared byte read rejects a tampered published file',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p8_candidate_tamper_',
        );

        try {
          final store = SupportReportArtifactFileStore(
            applicationSupportDirectory: root,
          );
          final projection = _weeklyProjection();
          const fingerprint =
              '3333333333333333333333333333333333333333333333333333333333333333';
          final artifact =
              await VerifiedSupportReportExcelArtifactPreparer(
                fileStore: store,
              ).prepareWeekly(
                halaqahId: 1,
                projection: projection,
                sourceFingerprint: fingerprint,
              );
          final file = File(
            '${root.path}${Platform.pathSeparator}'
            '${artifact.internalPath.replaceAll('/', Platform.pathSeparator)}',
          );

          await file.writeAsBytes(<int>[1, 2, 3, 4], flush: true);

          await expectLater(
            store.readVerifiedPreparedBytes(artifact),
            throwsStateError,
          );
        } finally {
          await root.delete(recursive: true);
        }
      },
    );
    test(
      'general weekly and monthly candidates stage reopen and verify semantically',
      () async {
        final root = await Directory.systemTemp.createTemp(
          'qurani_p8_general_candidate_',
        );

        try {
          final store = SupportReportArtifactFileStore(
            applicationSupportDirectory: root,
          );
          final preparer = VerifiedSupportReportExcelArtifactPreparer(
            fileStore: store,
          );
          const generator = VerifiedSupportReportExcelGenerator();

          final weeklyProjection = _weeklyProjection(general: true);
          const weeklyFingerprint =
              '4444444444444444444444444444444444444444444444444444444444444444';
          final weeklyArtifact = await preparer.prepareWeekly(
            halaqahId: 1,
            projection: weeklyProjection,
            sourceFingerprint: weeklyFingerprint,
          );
          final weeklyBytes = await store.readVerifiedPreparedBytes(
            weeklyArtifact,
          );
          final weeklySemantic = generator.verifyWeeklyCandidateBytes(
            bytes: weeklyBytes,
            halaqahId: 1,
            projection: weeklyProjection,
            sourceFingerprint: weeklyFingerprint,
          );

          expect(weeklySemantic.isValid, isTrue);

          final monthlyProjection = _monthlyProjection(general: true);
          const monthlyFingerprint =
              '5555555555555555555555555555555555555555555555555555555555555555';
          final monthlyArtifact = await preparer.prepareMonthly(
            projection: monthlyProjection,
            sourceFingerprint: monthlyFingerprint,
          );
          final monthlyBytes = await store.readVerifiedPreparedBytes(
            monthlyArtifact,
          );
          final monthlySemantic = generator.verifyMonthlyCandidateBytes(
            bytes: monthlyBytes,
            projection: monthlyProjection,
            sourceFingerprint: monthlyFingerprint,
          );

          expect(monthlySemantic.isValid, isTrue);
        } finally {
          await root.delete(recursive: true);
        }
      },
    );
  });
}

WeeklySupportReportProjection _weeklyProjection({bool general = false}) {
  final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 14));

  return WeeklySupportReportProjection(
    period: period,
    header: SupportReportHeaderSnapshot(
      reportContext: general
          ? SupportReportContext.general
          : SupportReportContext.support,
      teacherName: 'المعلم',
      halaqahName: 'حلقة النور',
      organizationName: general ? 'مركز النور' : 'الجهة',
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: <WeeklySupportReportStudentProjection>[
      WeeklySupportReportStudentProjection(
        sourceStudentId: 1,
        supportStudentNumber: general ? null : 'SUP-001',
        studentName: 'أحمد',
        currentJuz: 2,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: general
            ? null
            : SupportReportPolicy.monthlyGoalQuarterFaces,
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
                        WeeklySupportReportRecitationProjection(
                          achievedQuarterFaces: 4,
                          range: SupportReportQuranRange(
                            startSurah: 2,
                            startAyah: 6,
                            endSurah: 2,
                            endAyah: 10,
                          ),
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

MonthlySupportReportProjection _monthlyProjection({bool general = false}) {
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));
  final weeklyPeriod = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 5));

  return MonthlySupportReportProjection(
    halaqahId: 1,
    period: period,
    header: SupportReportHeaderSnapshot(
      reportContext: general
          ? SupportReportContext.general
          : SupportReportContext.support,
      teacherName: 'المعلم',
      halaqahName: 'حلقة النور',
      organizationName: general ? 'مركز النور' : 'الجهة',
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: <MonthlySupportReportStudentProjection>[
      MonthlySupportReportStudentProjection(
        sourceStudentId: 1,
        supportStudentNumber: general ? null : 'SUP-001',
        studentName: 'أحمد',
        currentJuz: 2,
        dailyPlanText: 'نصف وجه',
        monthlyGoalQuarterFaces: general
            ? null
            : SupportReportPolicy.monthlyGoalQuarterFaces,
        achievedQuarterFaces: 8,
        absenceDays: 0,
        goalCompleted: general ? null : false,
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
