import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_candidate.dart';
import 'package:qurani/features/reports/application/monthly_support_report_approval_service.dart';
import 'package:qurani/features/reports/application/monthly_support_report_review.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/monthly_support_report_projection.dart';
import 'package:qurani/features/reports/domain/support_report_policy.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/presentation/monthly_support_report_review_screen.dart';
import 'package:qurani/features/reports/presentation/support_reports_screen.dart';

void main() {
  testWidgets(
    'monthly general review enables Package 8 final approval when source exists',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            monthlySupportReportReviewProvider.overrideWith(
              (ref) async => _monthlyReview(),
            ),
          ],
          child: const MaterialApp(
            home: MonthlySupportReportReviewScreen(actionsEnabled: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final approvalFinder = find.byKey(
        const Key('monthly_report_final_approval_button'),
      );

      for (
        var attempt = 0;
        attempt < 6 && approvalFinder.evaluate().isEmpty;
        attempt++
      ) {
        await tester.drag(
          find.byKey(const Key('monthly_support_report_review_list')),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
      }

      expect(approvalFinder, findsOneWidget);

      final approval = tester.widget<FilledButton>(approvalFinder);
      expect(approval.onPressed, isNotNull);
    },
  );

  testWidgets(
    'monthly final approval requires explicit confirmation when warnings exist',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1600);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            monthlySupportReportReviewProvider.overrideWith(
              (ref) async => _monthlyReview(withWarning: true),
            ),
          ],
          child: const MaterialApp(
            home: MonthlySupportReportReviewScreen(actionsEnabled: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final approvalFinder = find.byKey(
        const Key('monthly_report_final_approval_button'),
      );

      for (
        var attempt = 0;
        attempt < 6 && approvalFinder.evaluate().isEmpty;
        attempt++
      ) {
        await tester.drag(
          find.byKey(const Key('monthly_support_report_review_list')),
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
      }

      expect(approvalFinder, findsOneWidget);

      await tester.tap(approvalFinder);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('monthly_report_warning_confirmation_dialog')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('monthly_report_warning_cancel_button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('monthly_report_warning_confirmation_dialog')),
        findsNothing,
      );
    },
  );

  testWidgets('monthly reports gateway opens the monthly live review screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          supportReportsRuntimeContextProvider.overrideWith(
            (ref) async => SupportReportsRuntimeContext(
              halaqahId: 1,
              supportEnabled: false,
              history: <SupportReportHistoryItem>[],
            ),
          ),
          monthlySupportReportReviewProvider.overrideWith(
            (ref) => Future<MonthlySupportReportReview>.error(
              StateError('No approved weekly fixtures.'),
            ),
          ),
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

    expect(
      find.byKey(const Key('reports_current_general_card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reports_current_support_card')), findsNothing);
    expect(
      find.byKey(const Key('reports_current_weekly_gateway')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reports_current_monthly_gateway')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('reports_current_monthly_gateway')));

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('monthly_support_report_review_screen')),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('monthly_report_source_unavailable')),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('monthly_report_final_approval_button')),
      findsNothing,
    );
  });
}

MonthlySupportReportReview _monthlyReview({bool withWarning = false}) {
  final period = MonthlySupportReportPeriod.forDate(DateTime(2026, 9, 15));
  final weeklyPeriod = WeeklySupportReportPeriod.forDate(DateTime(2026, 9, 5));

  final projection = MonthlySupportReportProjection(
    halaqahId: 1,
    period: period,
    header: const SupportReportHeaderSnapshot(
      teacherName: 'Teacher',
      halaqahName: 'Halaqah',
      organizationName: 'Center',
      reportContext: SupportReportContext.general,
      policyVersion: SupportReportPolicy.policyVersion,
      templateVersion: SupportReportPolicy.templateVersion,
    ),
    students: <MonthlySupportReportStudentProjection>[
      MonthlySupportReportStudentProjection(
        sourceStudentId: 1,
        studentName: 'Student',
        supportStudentNumber: null,
        currentJuz: withWarning ? null : 2,
        dailyPlanText: 'Half face',
        monthlyGoalQuarterFaces: null,
        achievedQuarterFaces: 8,
        absenceDays: 0,
        goalCompleted: null,
        displayOrder: 1,
      ),
    ],
    days: const <MonthlySupportReportDayProjection>[],
    weeklyInputs: <MonthlySupportReportWeeklyInputIdentity>[
      MonthlySupportReportWeeklyInputIdentity(
        reportId: 101,
        period: weeklyPeriod,
        sourceFingerprint: 'approved-weekly-source',
        approvedAtUtc: DateTime.utc(2026, 9, 10, 12),
      ),
    ],
    missingItems: withWarning
        ? const <ReportMissingItem>[
            ReportMissingItem(
              studentId: 1,
              studentName: 'Student',
              field: ReportMissingField.currentJuz,
            ),
          ]
        : const <ReportMissingItem>[],
  );

  const fingerprint = 'monthly-live-fingerprint';

  return MonthlySupportReportReview(
    candidate: MonthlySupportReportApprovalCandidate(
      projection: projection,
      sourceFingerprint: fingerprint,
      warningsConfirmed: false,
    ),
    comparison: const MonthlySupportReportSnapshotComparison(
      freshness: MonthlySupportReportSnapshotFreshness.noApprovedSnapshot,
      currentSourceFingerprint: fingerprint,
    ),
  );
}
