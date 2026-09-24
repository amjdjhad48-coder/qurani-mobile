import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/application/support_report_pdf_action_service.dart';
import 'package:qurani/features/reports/application/support_report_pdf_runtime_provider.dart';
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

  testWidgets('approved weekly history generates and opens PDF on demand', (
    tester,
  ) async {
    final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
    final item = SupportReportHistoryItem(
      reportId: 121,
      kind: SupportReportHistoryKind.weekly,
      periodStart: period.weekStart,
      periodEnd: period.weekEnd,
      header: header,
      sourceFingerprint: 'weekly-pdf-121',
      approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
    );
    final detail = SupportReportHistoryDetail.weekly(
      item: item,
      snapshot: ApprovedWeeklySupportReportSnapshot(
        reportId: 121,
        halaqahId: 7,
        period: period,
        header: header,
        sourceFingerprint: 'weekly-pdf-121',
        approvedAtUtc: DateTime.utc(2026, 9, 17, 10),
        students: const <ApprovedWeeklySupportReportStudentSnapshot>[],
        days: const <ApprovedWeeklySupportReportDaySnapshot>[],
      ),
    );
    final service = _FakePdfActionService();

    await _pump(tester, item: item, detail: detail, service: service);

    final button = find.byKey(const Key('approved_history_open_pdf_button'));
    await _scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(service.openCalls, 1);
    expect(service.lastDetail, same(detail));
    expect(find.text('تم إنشاء وفتح PDF من النسخة المعتمدة.'), findsOneWidget);
  });

  testWidgets('PDF SAF cancellation is a normal history outcome', (
    tester,
  ) async {
    final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));
    final item = SupportReportHistoryItem(
      reportId: 122,
      kind: SupportReportHistoryKind.weekly,
      periodStart: period.weekStart,
      periodEnd: period.weekEnd,
      header: header,
      sourceFingerprint: 'weekly-pdf-122',
      approvedAtUtc: DateTime.utc(2026, 9, 17, 11),
    );
    final detail = SupportReportHistoryDetail.weekly(
      item: item,
      snapshot: ApprovedWeeklySupportReportSnapshot(
        reportId: 122,
        halaqahId: 7,
        period: period,
        header: header,
        sourceFingerprint: 'weekly-pdf-122',
        approvedAtUtc: DateTime.utc(2026, 9, 17, 11),
        students: const <ApprovedWeeklySupportReportStudentSnapshot>[],
        days: const <ApprovedWeeklySupportReportDaySnapshot>[],
      ),
    );
    final service = _FakePdfActionService(
      saveOutcome: SupportReportApprovedPdfSaveOutcome.cancelled,
    );

    await _pump(tester, item: item, detail: detail, service: service);

    final button = find.byKey(const Key('approved_history_save_pdf_button'));
    await _scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(service.saveCalls, 1);
    expect(find.text('تم إلغاء حفظ نسخة PDF.'), findsOneWidget);
    expect(find.textContaining('تعذر حفظ نسخة PDF'), findsNothing);
  });

  testWidgets('approved monthly history shares PDF through the same path', (
    tester,
  ) async {
    final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));
    final item = SupportReportHistoryItem(
      reportId: 123,
      kind: SupportReportHistoryKind.monthly,
      periodStart: period.monthStart,
      periodEnd: period.monthEnd,
      header: header,
      sourceFingerprint: 'monthly-pdf-123',
      approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
    );
    final detail = SupportReportHistoryDetail.monthly(
      item: item,
      snapshot: ApprovedMonthlySupportReportSnapshot(
        reportId: 123,
        halaqahId: 7,
        period: period,
        header: header,
        sourceFingerprint: 'monthly-pdf-123',
        approvedAtUtc: DateTime.utc(2026, 10, 1, 10),
        students: const <ApprovedMonthlySupportReportStudentSnapshot>[],
        days: const <ApprovedMonthlySupportReportDaySnapshot>[],
      ),
    );
    final service = _FakePdfActionService();

    await _pump(tester, item: item, detail: detail, service: service);

    final button = find.byKey(const Key('approved_history_share_pdf_button'));
    await _scrollTo(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(service.shareCalls, 1);
    expect(service.lastDetail, same(detail));
    expect(
      find.text(
        'تم فتح قائمة مشاركة PDF. يمكنك اختيار واتساب أو أي تطبيق مناسب.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required SupportReportHistoryItem item,
  required SupportReportHistoryDetail detail,
  required SupportReportApprovedPdfActionService service,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        supportReportHistoryDetailProvider(
          item,
        ).overrideWith((ref) async => detail),
        supportReportApprovedPdfActionServiceProvider.overrideWith(
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

  for (var attempt = 0; attempt < 10; attempt += 1) {
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

final class _FakePdfActionService
    implements SupportReportApprovedPdfActionService {
  _FakePdfActionService({
    this.saveOutcome = SupportReportApprovedPdfSaveOutcome.saved,
  });

  final SupportReportApprovedPdfSaveOutcome saveOutcome;
  var openCalls = 0;
  var saveCalls = 0;
  var shareCalls = 0;
  SupportReportHistoryDetail? lastDetail;

  @override
  Future<void> openApprovedPdf({
    required SupportReportHistoryDetail detail,
  }) async {
    openCalls += 1;
    lastDetail = detail;
  }

  @override
  Future<SupportReportApprovedPdfSaveOutcome> saveApprovedPdf({
    required SupportReportHistoryDetail detail,
  }) async {
    saveCalls += 1;
    lastDetail = detail;
    return saveOutcome;
  }

  @override
  Future<void> shareApprovedPdf({
    required SupportReportHistoryDetail detail,
  }) async {
    shareCalls += 1;
    lastDetail = detail;
  }
}
