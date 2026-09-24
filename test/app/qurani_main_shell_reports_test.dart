import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/app/qurani_main_shell.dart';
import 'package:qurani/features/daily_halaqah/application/daily_halaqah_runtime_providers.dart';
import 'package:qurani/features/reports/application/support_reports_runtime_providers.dart';
import 'package:qurani/features/reports/domain/support_report_types.dart';
import 'package:qurani/features/reports/domain/support_reports_review.dart';

void main() {
  testWidgets('Reports is visible while current support is enabled', (
    tester,
  ) async {
    await _pumpShell(
      tester,
      SupportReportsRuntimeContext(
        halaqahId: 1,
        supportEnabled: true,
        history: const <SupportReportHistoryItem>[],
      ),
    );
    expect(find.text('التقارير'), findsOneWidget);
    await tester.tap(find.text('التقارير'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('support_reports_screen')), findsOneWidget);
    expect(
      find.byKey(const Key('reports_current_support_card')),
      findsOneWidget,
    );
    // The notice may be below the viewport; scroll before asserting its presence.
    await tester.scrollUntilVisible(
      find.byKey(const Key('reports_primary_artifact_gate_notice')),
      150,
      scrollable: find.descendant(
        of: find.byKey(const Key('reports_gateway_list')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(
      find.byKey(const Key('reports_primary_artifact_gate_notice')),
      findsOneWidget,
    );
    expect(
      find.text(
        'يُنفذ الاعتماد النهائي من شاشة التقرير الأسبوعي أو الشهري. '
        'عند الاعتماد يُنشأ ملف Excel الأساسي ويُعاد فتحه والتحقق منه '
        'قبل تثبيت الاعتماد.',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'Reports stays visible when support is disabled with no history',
    (tester) async {
      await _pumpShell(
        tester,
        SupportReportsRuntimeContext(
          halaqahId: 1,
          supportEnabled: false,
          history: const <SupportReportHistoryItem>[],
        ),
      );
      expect(find.text('التقارير'), findsOneWidget);
      await tester.tap(find.text('التقارير'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('support_reports_screen')), findsOneWidget);
      expect(
        find.byKey(const Key('reports_current_general_card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('reports_current_monthly_gateway')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('reports_current_weekly_gateway')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('reports_current_support_card')),
        findsNothing,
      );
      expect(find.byKey(const Key('reports_history_only_card')), findsNothing);
    },
  );

  testWidgets('disabled support keeps Reports visible for approved history', (
    tester,
  ) async {
    final history = SupportReportHistoryItem(
      reportId: 7,
      kind: SupportReportHistoryKind.weekly,
      periodStart: DateTime(2026, 8, 1),
      periodEnd: DateTime(2026, 8, 5),
      header: const SupportReportHeaderSnapshot(
        teacherName: 'المعلم',
        halaqahName: 'حلقة النور',
        organizationName: 'الجهة',
        policyVersion: 1,
        templateVersion: 1,
      ),
      sourceFingerprint: 'history-fingerprint',
      approvedAtUtc: DateTime.utc(2026, 8, 6, 10),
    );
    await _pumpShell(
      tester,
      SupportReportsRuntimeContext(
        halaqahId: 1,
        supportEnabled: false,
        history: <SupportReportHistoryItem>[history],
      ),
    );
    expect(find.text('التقارير'), findsOneWidget);
    await tester.tap(find.text('التقارير'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('reports_current_general_card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reports_current_monthly_gateway')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('reports_current_weekly_gateway')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('support_report_history_weekly_7')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reports_current_support_card')), findsNothing);
    expect(find.byKey(const Key('reports_history_only_card')), findsNothing);
  });
  testWidgets(
    'main shell waits for report artifact startup cleanup before runtime UI',
    (tester) async {
      final cleanup = Completer<int>();
      var cleanupCalls = 0;

      await _pumpShell(
        tester,
        SupportReportsRuntimeContext(
          halaqahId: 1,
          supportEnabled: false,
          history: const <SupportReportHistoryItem>[],
        ),
        startupCleanup: () {
          cleanupCalls += 1;
          return cleanup.future;
        },
        settle: false,
      );

      await tester.pump();

      expect(cleanupCalls, 1);
      expect(
        find.byKey(const Key('qurani_startup_recovery_loading')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('qurani_main_shell')), findsNothing);

      cleanup.complete(0);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('qurani_startup_recovery_loading')),
        findsNothing,
      );
      expect(find.byKey(const Key('qurani_main_shell')), findsOneWidget);
    },
  );

  testWidgets(
    'startup cleanup failure does not block an unlocked runtime session',
    (tester) async {
      var cleanupCalls = 0;

      await _pumpShell(
        tester,
        SupportReportsRuntimeContext(
          halaqahId: 1,
          supportEnabled: false,
          history: const <SupportReportHistoryItem>[],
        ),
        startupCleanup: () async {
          cleanupCalls += 1;
          throw StateError('intentional startup cleanup failure');
        },
      );

      expect(cleanupCalls, 1);
      expect(
        find.byKey(const Key('qurani_startup_recovery_loading')),
        findsNothing,
      );
      expect(find.byKey(const Key('qurani_main_shell')), findsOneWidget);
    },
  );
}

Future<void> _pumpShell(
  WidgetTester tester,
  SupportReportsRuntimeContext reportsContext, {
  Future<int> Function()? startupCleanup,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supportReportsRuntimeContextProvider.overrideWith(
          (ref) async => reportsContext,
        ),
        supportReportStartupCleanupProvider.overrideWith((ref) async {
          final cleanup = startupCleanup;
          if (cleanup == null) {
            return 0;
          }
          return cleanup();
        }),
        dailyHalaqahRuntimeContextProvider.overrideWith(
          (ref) => Future<DailyHalaqahRuntimeContext>.error(
            StateError(
              'Daily runtime intentionally unavailable in shell Reports test.',
            ),
          ),
        ),
      ],
      child: MaterialApp(
        home: QuraniMainShell(onChangePin: () {}, onLockNow: () {}),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
