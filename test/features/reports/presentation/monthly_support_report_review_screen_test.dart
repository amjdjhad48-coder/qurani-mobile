import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/reports/application/monthly_support_report_review.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';
import 'package:qurani/features/reports/presentation/support_reports_screen.dart';

void main() {
  testWidgets(
    'monthly reports gateway opens monthly live review without enabling approval',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            supportReportsRuntimeContextProvider.overrideWith(
              (ref) async => SupportReportsRuntimeContext(
                halaqahId: 1,
                supportEnabled: true,
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

      await tester.tap(
        find.byKey(const Key('reports_current_monthly_gateway')),
      );

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
    },
  );
}
