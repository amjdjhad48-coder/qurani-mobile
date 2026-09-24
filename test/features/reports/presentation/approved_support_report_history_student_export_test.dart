import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/application/support_report_student_export_runtime_provider.dart';
import 'package:qurani/features/reports/application/support_report_student_export_service.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/presentation/approved_support_report_history_detail_screen.dart';

void main() {
  const header = SupportReportHeaderSnapshot(
    teacherName: 'المعلم أحمد',
    halaqahName: 'حلقة الفجر',
    organizationName: 'مسجد النور',
    reportContext: SupportReportContext.general,
    policyVersion: 1,
    templateVersion: 1,
  );

  testWidgets(
    'weekly history exports selected student Excel with normal SAF cancel',
    (tester) async {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
      final item = SupportReportHistoryItem(
        reportId: 601,
        kind: SupportReportHistoryKind.weekly,
        periodStart: period.weekStart,
        periodEnd: period.weekEnd,
        header: header,
        sourceFingerprint: 'weekly-student-widget-601',
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
      );
      final detail = SupportReportHistoryDetail.weekly(
        item: item,
        snapshot: ApprovedWeeklySupportReportSnapshot(
          reportId: 601,
          halaqahId: 7,
          period: period,
          header: header,
          sourceFingerprint: item.sourceFingerprint,
          approvedAtUtc: item.approvedAtUtc,
          students: const <ApprovedWeeklySupportReportStudentSnapshot>[
            ApprovedWeeklySupportReportStudentSnapshot(
              snapshotRowId: 1,
              sourceStudentId: 71,
              studentName: 'علي',
              monthlyGoalQuarterFaces: 40,
              displayOrder: 1,
            ),
          ],
          days: const <ApprovedWeeklySupportReportDaySnapshot>[],
        ),
      );
      final service = _FakeStudentExportService(
        outcome: SupportReportStudentExportOutcome.cancelled,
      );

      await _pump(tester, item: item, detail: detail, service: service);

      final button = find.byKey(
        const Key('approved_history_student_export_excel_save_button'),
      );
      await _scrollTo(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(service.calls, 1);
      expect(service.lastDetail, same(detail));
      expect(service.lastStudentId, 71);
      expect(service.lastFormat, SupportReportStudentExportFormat.excel);
      expect(service.lastAction, SupportReportStudentExportAction.save);
      expect(find.text('تم إلغاء حفظ نسخة Excel للطالب.'), findsOneWidget);
      expect(find.textContaining('تعذر تصدير ملف Excel'), findsNothing);
    },
  );

  testWidgets(
    'monthly history shares selected student PDF through same UI path',
    (tester) async {
      final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));
      final item = SupportReportHistoryItem(
        reportId: 602,
        kind: SupportReportHistoryKind.monthly,
        periodStart: period.monthStart,
        periodEnd: period.monthEnd,
        header: header,
        sourceFingerprint: 'monthly-student-widget-602',
        approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
      );
      final detail = SupportReportHistoryDetail.monthly(
        item: item,
        snapshot: ApprovedMonthlySupportReportSnapshot(
          reportId: 602,
          halaqahId: 7,
          period: period,
          header: header,
          sourceFingerprint: item.sourceFingerprint,
          approvedAtUtc: item.approvedAtUtc,
          students: const <ApprovedMonthlySupportReportStudentSnapshot>[
            ApprovedMonthlySupportReportStudentSnapshot(
              snapshotRowId: 2,
              sourceStudentId: 72,
              studentName: 'محمد',
              monthlyGoalQuarterFaces: 40,
              achievedQuarterFaces: 32,
              absenceDays: 1,
              goalCompleted: false,
              displayOrder: 1,
            ),
          ],
          days: const <ApprovedMonthlySupportReportDaySnapshot>[],
        ),
      );
      final service = _FakeStudentExportService();

      await _pump(tester, item: item, detail: detail, service: service);

      final button = find.byKey(
        const Key('approved_history_student_export_pdf_share_button'),
      );
      await _scrollTo(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(service.calls, 1);
      expect(service.lastDetail, same(detail));
      expect(service.lastStudentId, 72);
      expect(service.lastFormat, SupportReportStudentExportFormat.pdf);
      expect(service.lastAction, SupportReportStudentExportAction.share);
      expect(find.text('تم فتح قائمة مشاركة PDF للطالب.'), findsOneWidget);
    },
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required SupportReportHistoryItem item,
  required SupportReportHistoryDetail detail,
  required SupportReportStudentExportService service,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        supportReportHistoryDetailProvider(
          item,
        ).overrideWith((ref) async => detail),
        supportReportStudentExportServiceProvider.overrideWith(
          (ref) => service,
        ),
      ],
      child: MaterialApp(
        home: ApprovedSupportReportHistoryDetailScreen(item: item),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  final detailList = find.byKey(const Key('approved_history_detail_list'));
  expect(detailList, findsOneWidget);

  for (var attempt = 0; attempt < 16; attempt += 1) {
    if (target.evaluate().isNotEmpty) {
      final listTop = tester.getTopLeft(detailList).dy;
      final listBottom = tester.getBottomRight(detailList).dy;
      final targetCenter = tester.getCenter(target).dy;

      if (targetCenter > listTop && targetCenter < listBottom) {
        return;
      }
    }

    await tester.drag(detailList, const Offset(0, -240));
    await tester.pumpAndSettle();
  }

  expect(target, findsOneWidget);

  final listTop = tester.getTopLeft(detailList).dy;
  final listBottom = tester.getBottomRight(detailList).dy;
  final targetCenter = tester.getCenter(target).dy;

  expect(targetCenter, greaterThan(listTop));
  expect(targetCenter, lessThan(listBottom));
}

final class _FakeStudentExportService
    implements SupportReportStudentExportService {
  _FakeStudentExportService({
    this.outcome = SupportReportStudentExportOutcome.completed,
  });

  final SupportReportStudentExportOutcome outcome;
  var calls = 0;
  SupportReportHistoryDetail? lastDetail;
  int? lastStudentId;
  SupportReportStudentExportFormat? lastFormat;
  SupportReportStudentExportAction? lastAction;

  @override
  Future<SupportReportStudentExportOutcome> exportStudent({
    required SupportReportHistoryDetail detail,
    required int sourceStudentId,
    required SupportReportStudentExportFormat format,
    required SupportReportStudentExportAction action,
  }) async {
    calls += 1;
    lastDetail = detail;
    lastStudentId = sourceStudentId;
    lastFormat = format;
    lastAction = action;
    return outcome;
  }
}
