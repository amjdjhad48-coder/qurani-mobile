import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/support_report_history_detail.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/approved_monthly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/approved_weekly_support_report_snapshot.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/domain/weekly_support_report_projection.dart';
import 'package:qurani/features/reports/presentation/approved_support_report_history_detail_screen.dart';
import 'package:qurani/features/reports/presentation/support_reports_screen.dart';

void main() {
  const header = SupportReportHeaderSnapshot(
    teacherName: 'المعلم',
    halaqahName: 'الحلقة',
    organizationName: 'الجهة',
    policyVersion: 1,
    templateVersion: 1,
  );

  testWidgets('approved weekly history renders immutable student day details', (
    tester,
  ) async {
    final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));

    final item = SupportReportHistoryItem(
      reportId: 91,
      kind: SupportReportHistoryKind.weekly,
      periodStart: period.weekStart,
      periodEnd: period.weekEnd,
      header: header,
      sourceFingerprint: 'weekly-91',
      approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
    );

    final student = const ApprovedWeeklySupportReportStudentSnapshot(
      snapshotRowId: 1,
      sourceStudentId: 11,
      supportStudentNumber: 'S-11',
      studentName: 'طالب أسبوعي',
      currentJuz: 5,
      dailyPlanText: 'نصف وجه',
      monthlyGoalQuarterFaces: 80,
      note: 'ملاحظة أسبوعية',
      displayOrder: 1,
    );

    final day = ApprovedWeeklySupportReportDaySnapshot(
      snapshotRowId: 2,
      localDate: period.weekStart,
      dayKind: SupportReportDayKind.normal,
      entries: const <ApprovedWeeklySupportReportDayEntrySnapshot>[
        ApprovedWeeklySupportReportDayEntrySnapshot(
          snapshotRowId: 3,
          sourceStudentId: 11,
          attendanceStatus: SupportReportAttendanceStatus.present,
          achievedQuarterFaces: 2,
          range: SupportReportQuranRange(
            startSurah: 1,
            startAyah: 1,
            endSurah: 1,
            endAyah: 7,
          ),
          note: null,
          entryOrder: 0,
        ),
      ],
    );

    final snapshot = ApprovedWeeklySupportReportSnapshot(
      reportId: 91,
      halaqahId: 7,
      period: period,
      header: header,
      sourceFingerprint: 'weekly-91',
      approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
      students: <ApprovedWeeklySupportReportStudentSnapshot>[student],
      days: <ApprovedWeeklySupportReportDaySnapshot>[day],
    );

    final detail = SupportReportHistoryDetail.weekly(
      item: item,
      snapshot: snapshot,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          supportReportHistoryDetailProvider(
            item,
          ).overrideWith((ref) async => detail),
        ],
        child: MaterialApp(
          home: ApprovedSupportReportHistoryDetailScreen(item: item),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('approved_weekly_history_snapshot')),
      findsOneWidget,
    );
    expect(find.text('طالب أسبوعي'), findsOneWidget);
    expect(find.textContaining('حاضر'), findsOneWidget);
    expect(find.textContaining('1:1 - 1:7'), findsOneWidget);
  });

  testWidgets('approved monthly history renders monthly aggregate details', (
    tester,
  ) async {
    final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 1));

    final item = SupportReportHistoryItem(
      reportId: 92,
      kind: SupportReportHistoryKind.monthly,
      periodStart: period.monthStart,
      periodEnd: period.monthEnd,
      header: header,
      sourceFingerprint: 'monthly-92',
      approvedAtUtc: DateTime.utc(2026, 9, 30, 10),
    );

    final snapshot = ApprovedMonthlySupportReportSnapshot(
      reportId: 92,
      halaqahId: 7,
      period: period,
      header: header,
      sourceFingerprint: 'monthly-92',
      approvedAtUtc: DateTime.utc(2026, 9, 30, 10),
      students: const <ApprovedMonthlySupportReportStudentSnapshot>[
        ApprovedMonthlySupportReportStudentSnapshot(
          snapshotRowId: 4,
          sourceStudentId: 12,
          supportStudentNumber: 'S-12',
          studentName: 'طالب شهري',
          currentJuz: 8,
          dailyPlanText: 'وجه',
          monthlyGoalQuarterFaces: 80,
          achievedQuarterFaces: 76,
          absenceDays: 2,
          goalCompleted: false,
          note: 'ملاحظة شهرية',
          displayOrder: 1,
        ),
      ],
    );

    final detail = SupportReportHistoryDetail.monthly(
      item: item,
      snapshot: snapshot,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          supportReportHistoryDetailProvider(
            item,
          ).overrideWith((ref) async => detail),
        ],
        child: MaterialApp(
          home: ApprovedSupportReportHistoryDetailScreen(item: item),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('approved_monthly_history_snapshot')),
      findsOneWidget,
    );
    expect(find.text('طالب شهري'), findsOneWidget);
    expect(find.textContaining('إكمال الجزء: لم يتم'), findsOneWidget);
  });

  testWidgets(
    'reports history tile opens approved detail even when support off',
    (tester) async {
      final period = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 12));

      final item = SupportReportHistoryItem(
        reportId: 93,
        kind: SupportReportHistoryKind.weekly,
        periodStart: period.weekStart,
        periodEnd: period.weekEnd,
        header: header,
        sourceFingerprint: 'weekly-93',
        approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
      );

      final snapshot = ApprovedWeeklySupportReportSnapshot(
        reportId: 93,
        halaqahId: 7,
        period: period,
        header: header,
        sourceFingerprint: 'weekly-93',
        approvedAtUtc: DateTime.utc(2026, 9, 16, 10),
        students: const <ApprovedWeeklySupportReportStudentSnapshot>[],
        days: const <ApprovedWeeklySupportReportDaySnapshot>[],
      );

      final detail = SupportReportHistoryDetail.weekly(
        item: item,
        snapshot: snapshot,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            supportReportsRuntimeContextProvider.overrideWith(
              (ref) async => SupportReportsRuntimeContext(
                halaqahId: 7,
                supportEnabled: false,
                history: <SupportReportHistoryItem>[item],
              ),
            ),
            supportReportHistoryDetailProvider(
              item,
            ).overrideWith((ref) async => detail),
          ],
          child: MaterialApp(
            home: SupportReportsScreen(
              actionsEnabled: true,
              onChangePin: () {},
              onLockNow: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey<String>('support_report_history_weekly_93')),
      );

      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('approved_support_report_history_detail_screen')),
        findsOneWidget,
      );

      expect(
        find.byKey(const Key('approved_history_read_only_notice')),
        findsOneWidget,
      );
    },
  );
}
