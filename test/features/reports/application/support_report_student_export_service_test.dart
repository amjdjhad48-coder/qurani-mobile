import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/primary_report_artifact_gate.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/application/support_report_student_export_service.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

void main() {
  const header = SupportReportHeaderSnapshot(
    teacherName: 'المعلم أحمد',
    halaqahName: 'حلقة الفجر',
    organizationName: 'مسجد النور',
    reportContext: SupportReportContext.general,
    policyVersion: 1,
    templateVersion: 3,
  );

  test(
    'weekly student export filters approved snapshot and day entries to one student',
    () async {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
      final item = SupportReportHistoryItem(
        reportId: 501,
        kind: SupportReportHistoryKind.weekly,
        periodStart: period.weekStart,
        periodEnd: period.weekEnd,
        header: header,
        sourceFingerprint: 'weekly-student-export-501',
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );
      final detail = SupportReportHistoryDetail.weekly(
        item: item,
        snapshot: ApprovedWeeklySupportReportSnapshot(
          reportId: 501,
          halaqahId: 7,
          period: period,
          header: header,
          sourceFingerprint: 'weekly-student-export-501',
          approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
          students: const <ApprovedWeeklySupportReportStudentSnapshot>[
            ApprovedWeeklySupportReportStudentSnapshot(
              snapshotRowId: 1,
              sourceStudentId: 11,
              studentName: 'علي',
              monthlyGoalQuarterFaces: 40,
              displayOrder: 1,
            ),
            ApprovedWeeklySupportReportStudentSnapshot(
              snapshotRowId: 2,
              sourceStudentId: 22,
              studentName: 'محمد',
              monthlyGoalQuarterFaces: 44,
              displayOrder: 2,
            ),
          ],
          days: <ApprovedWeeklySupportReportDaySnapshot>[
            ApprovedWeeklySupportReportDaySnapshot(
              snapshotRowId: 10,
              localDate: period.weekStart,
              dayKind: SupportReportDayKind.normal,
              entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[
                ApprovedWeeklySupportReportDayEntrySnapshot(
                  snapshotRowId: 101,
                  sourceStudentId: 11,
                  attendanceStatus: SupportReportAttendanceStatus.present,
                  achievedQuarterFaces: 4,
                  range: null,
                  note: null,
                  entryOrder: 1,
                ),
                ApprovedWeeklySupportReportDayEntrySnapshot(
                  snapshotRowId: 102,
                  sourceStudentId: 22,
                  attendanceStatus: SupportReportAttendanceStatus.absent,
                  achievedQuarterFaces: 0,
                  range: null,
                  note: 'غياب',
                  entryOrder: 1,
                ),
              ],
            ),
          ],
        ),
      );
      final excel = _FakeGenerator(
        format: SupportReportStudentExportFormat.excel,
      );
      final pdf = _FakeGenerator(format: SupportReportStudentExportFormat.pdf);
      final external = _FakeExternalActions();
      final service = Package8SupportReportStudentExportService(
        excelGenerator: excel,
        pdfGenerator: pdf,
        externalActions: external,
      );

      final outcome = await service.exportStudent(
        detail: detail,
        sourceStudentId: 22,
        format: SupportReportStudentExportFormat.excel,
        action: SupportReportStudentExportAction.share,
      );

      expect(outcome, SupportReportStudentExportOutcome.completed);
      expect(excel.calls, 1);
      expect(pdf.calls, 0);

      final projection = excel.lastProjection!;
      expect(projection.kind, SupportReportArtifactKind.weekly);
      expect(projection.sourceStudentId, 22);
      expect(projection.studentName, 'محمد');
      expect(projection.sourceFingerprint, item.sourceFingerprint);
      expect(projection.weeklySnapshot!.reportId, 501);
      expect(projection.weeklySnapshot!.students, hasLength(1));
      expect(projection.weeklySnapshot!.students.single.sourceStudentId, 22);
      expect(projection.weeklySnapshot!.days, hasLength(1));
      expect(projection.weeklySnapshot!.days.single.entries, hasLength(1));
      expect(
        projection.weeklySnapshot!.days.single.entries.single.sourceStudentId,
        22,
      );

      expect(external.shareCalls, 1);
      expect(external.openCalls, 0);
      expect(external.saveCalls, 0);
      expect(
        external.lastFileName,
        'qurani_weekly_student_22_2026-09-12_2026-09-16.xlsx',
      );
    },
  );

  test(
    'monthly PDF SAF cancellation is a normal student export outcome',
    () async {
      final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));
      final item = SupportReportHistoryItem(
        reportId: 502,
        kind: SupportReportHistoryKind.monthly,
        periodStart: period.monthStart,
        periodEnd: period.monthEnd,
        header: header,
        sourceFingerprint: 'monthly-student-export-502',
        approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
      );
      final detail = SupportReportHistoryDetail.monthly(
        item: item,
        snapshot: ApprovedMonthlySupportReportSnapshot(
          reportId: 502,
          halaqahId: 7,
          period: period,
          header: header,
          sourceFingerprint: 'monthly-student-export-502',
          approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
          students: const <ApprovedMonthlySupportReportStudentSnapshot>[
            ApprovedMonthlySupportReportStudentSnapshot(
              snapshotRowId: 3,
              sourceStudentId: 33,
              studentName: 'خالد',
              monthlyGoalQuarterFaces: 40,
              achievedQuarterFaces: 28,
              absenceDays: 1,
              goalCompleted: false,
              displayOrder: 1,
            ),
            ApprovedMonthlySupportReportStudentSnapshot(
              snapshotRowId: 4,
              sourceStudentId: 44,
              studentName: 'ياسر',
              monthlyGoalQuarterFaces: 40,
              achievedQuarterFaces: 40,
              absenceDays: 0,
              goalCompleted: true,
              displayOrder: 2,
            ),
          ],
          days: <ApprovedMonthlySupportReportDaySnapshot>[
            ApprovedMonthlySupportReportDaySnapshot(
              snapshotRowId: 20,
              sourceWeeklyReportId: 900,
              localDate: DateTime(2026, 9, 8),
              dayKind: SupportReportDayKind.normal,
              entries: const <ApprovedMonthlySupportReportDayEntrySnapshot>[
                ApprovedMonthlySupportReportDayEntrySnapshot(
                  snapshotRowId: 201,
                  sourceStudentId: 33,
                  attendanceStatus: SupportReportAttendanceStatus.present,
                  achievedQuarterFaces: 4,
                  range: null,
                  note: null,
                  entryOrder: 1,
                ),
                ApprovedMonthlySupportReportDayEntrySnapshot(
                  snapshotRowId: 202,
                  sourceStudentId: 44,
                  attendanceStatus: SupportReportAttendanceStatus.present,
                  achievedQuarterFaces: 8,
                  range: null,
                  note: null,
                  entryOrder: 1,
                ),
              ],
            ),
          ],
        ),
      );
      final excel = _FakeGenerator(
        format: SupportReportStudentExportFormat.excel,
      );
      final pdf = _FakeGenerator(format: SupportReportStudentExportFormat.pdf);
      final external = _FakeExternalActions(
        saveOutcome: SupportReportStudentExportOutcome.cancelled,
      );
      final service = Package8SupportReportStudentExportService(
        excelGenerator: excel,
        pdfGenerator: pdf,
        externalActions: external,
      );

      final outcome = await service.exportStudent(
        detail: detail,
        sourceStudentId: 44,
        format: SupportReportStudentExportFormat.pdf,
        action: SupportReportStudentExportAction.save,
      );

      expect(outcome, SupportReportStudentExportOutcome.cancelled);
      expect(pdf.calls, 1);
      expect(excel.calls, 0);
      expect(pdf.lastProjection!.monthlySnapshot!.students, hasLength(1));
      expect(
        pdf
            .lastProjection!
            .monthlySnapshot!
            .days
            .single
            .entries
            .single
            .sourceStudentId,
        44,
      );
      expect(
        external.lastFileName,
        'qurani_monthly_student_44_2026-09-01_2026-09-30.pdf',
      );
    },
  );

  test(
    'missing student is rejected before generation or external actions',
    () async {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
      final item = SupportReportHistoryItem(
        reportId: 503,
        kind: SupportReportHistoryKind.weekly,
        periodStart: period.weekStart,
        periodEnd: period.weekEnd,
        header: header,
        sourceFingerprint: 'weekly-student-export-503',
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );
      final detail = SupportReportHistoryDetail.weekly(
        item: item,
        snapshot: ApprovedWeeklySupportReportSnapshot(
          reportId: 503,
          halaqahId: 7,
          period: period,
          header: header,
          sourceFingerprint: item.sourceFingerprint,
          approvedAtUtc: item.approvedAtUtc,
          students: const <ApprovedWeeklySupportReportStudentSnapshot>[
            ApprovedWeeklySupportReportStudentSnapshot(
              snapshotRowId: 1,
              sourceStudentId: 11,
              studentName: 'علي',
              monthlyGoalQuarterFaces: 40,
              displayOrder: 1,
            ),
          ],
          days: const <ApprovedWeeklySupportReportDaySnapshot>[],
        ),
      );
      final excel = _FakeGenerator(
        format: SupportReportStudentExportFormat.excel,
      );
      final pdf = _FakeGenerator(format: SupportReportStudentExportFormat.pdf);
      final external = _FakeExternalActions();
      final service = Package8SupportReportStudentExportService(
        excelGenerator: excel,
        pdfGenerator: pdf,
        externalActions: external,
      );

      await expectLater(
        service.exportStudent(
          detail: detail,
          sourceStudentId: 99,
          format: SupportReportStudentExportFormat.excel,
          action: SupportReportStudentExportAction.open,
        ),
        throwsStateError,
      );

      expect(excel.calls, 0);
      expect(pdf.calls, 0);
      expect(external.totalCalls, 0);
    },
  );

  test(
    'generated identity mismatch is rejected before external actions',
    () async {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
      final item = SupportReportHistoryItem(
        reportId: 504,
        kind: SupportReportHistoryKind.weekly,
        periodStart: period.weekStart,
        periodEnd: period.weekEnd,
        header: header,
        sourceFingerprint: 'weekly-student-export-504',
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );
      final detail = SupportReportHistoryDetail.weekly(
        item: item,
        snapshot: ApprovedWeeklySupportReportSnapshot(
          reportId: 504,
          halaqahId: 7,
          period: period,
          header: header,
          sourceFingerprint: item.sourceFingerprint,
          approvedAtUtc: item.approvedAtUtc,
          students: const <ApprovedWeeklySupportReportStudentSnapshot>[
            ApprovedWeeklySupportReportStudentSnapshot(
              snapshotRowId: 1,
              sourceStudentId: 11,
              studentName: 'علي',
              monthlyGoalQuarterFaces: 40,
              displayOrder: 1,
            ),
          ],
          days: const <ApprovedWeeklySupportReportDaySnapshot>[],
        ),
      );
      final excel = _FakeGenerator(
        format: SupportReportStudentExportFormat.excel,
        fingerprintOverride: 'wrong-fingerprint',
      );
      final external = _FakeExternalActions();
      final service = Package8SupportReportStudentExportService(
        excelGenerator: excel,
        pdfGenerator: _FakeGenerator(
          format: SupportReportStudentExportFormat.pdf,
        ),
        externalActions: external,
      );

      await expectLater(
        service.exportStudent(
          detail: detail,
          sourceStudentId: 11,
          format: SupportReportStudentExportFormat.excel,
          action: SupportReportStudentExportAction.open,
        ),
        throwsStateError,
      );

      expect(external.totalCalls, 0);
    },
  );
}

final class _FakeGenerator implements SupportReportStudentExportGenerator {
  _FakeGenerator({required this.format, this.fingerprintOverride});

  static const hash =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  final SupportReportStudentExportFormat format;
  final String? fingerprintOverride;
  var calls = 0;
  StudentExportProjection? lastProjection;

  @override
  Future<SupportReportStudentGeneratedArtifact> generate(
    StudentExportProjection projection,
  ) async {
    calls += 1;
    lastProjection = projection;

    return SupportReportStudentGeneratedArtifact(
      format: format,
      kind: projection.kind,
      sourceFingerprint: fingerprintOverride ?? projection.sourceFingerprint,
      templateVersion: projection.templateVersion,
      sha256: hash,
      bytes: const <int>[1, 2, 3, 4],
    );
  }
}

final class _FakeExternalActions
    implements SupportReportStudentExportExternalActions {
  _FakeExternalActions({
    this.saveOutcome = SupportReportStudentExportOutcome.completed,
  });

  final SupportReportStudentExportOutcome saveOutcome;
  var openCalls = 0;
  var saveCalls = 0;
  var shareCalls = 0;
  String? lastFileName;

  int get totalCalls => openCalls + saveCalls + shareCalls;

  @override
  Future<void> open({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) async {
    openCalls += 1;
    lastFileName = fileName;
  }

  @override
  Future<SupportReportStudentExportOutcome> save({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) async {
    saveCalls += 1;
    lastFileName = fileName;
    return saveOutcome;
  }

  @override
  Future<void> share({
    required SupportReportStudentGeneratedArtifact artifact,
    required String fileName,
  }) async {
    shareCalls += 1;
    lastFileName = fileName;
  }
}
