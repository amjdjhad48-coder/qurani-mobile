import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/setup/presentation/forgot_pin_recovery_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required Future<void> Function() onResetConfirmed,
    VoidCallback? onRestoreFromBackup,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ForgotPinRecoveryScreen(
          onResetConfirmed: onResetConfirmed,
          onBack: () {},
          onRestoreFromBackup: onRestoreFromBackup,
        ),
      ),
    );
  }

  testWidgets(
    'states no bypass and keeps Restore disabled until Package 10 wiring',
    (WidgetTester tester) async {
      await pumpScreen(tester, onResetConfirmed: () async {});

      expect(
        find.byKey(const Key('forgot_pin_no_bypass_message')),
        findsOneWidget,
      );
      expect(
        find.text('لا توجد طريقة لتجاوز PIN أو استرجاعه من هذا الجهاز.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('restore_not_available_notice')),
        findsOneWidget,
      );

      final restoreButton = tester.widget<FilledButton>(
        find.byKey(const Key('restore_from_backup_button')),
      );
      expect(restoreButton.onPressed, isNull);
    },
  );

  testWidgets('destructive reset requires explicit confirmation', (
    WidgetTester tester,
  ) async {
    var resetCalls = 0;

    await pumpScreen(
      tester,
      onResetConfirmed: () async {
        resetCalls += 1;
      },
    );

    await tester.tap(find.byKey(const Key('reset_and_start_over_button')));
    await tester.pumpAndSettle();

    expect(find.text('مسح البيانات المحلية؟'), findsOneWidget);
    expect(resetCalls, 0);

    await tester.tap(find.byKey(const Key('cancel_local_reset_button')));
    await tester.pumpAndSettle();
    expect(resetCalls, 0);

    await tester.tap(find.byKey(const Key('reset_and_start_over_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_local_reset_button')));
    await tester.pumpAndSettle();

    expect(resetCalls, 1);
  });

  testWidgets(
    'reset failure remains on recovery screen with no false success',
    (WidgetTester tester) async {
      await pumpScreen(
        tester,
        onResetConfirmed: () async {
          throw StateError('simulated reset failure');
        },
      );

      await tester.tap(find.byKey(const Key('reset_and_start_over_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_local_reset_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('forgot_pin_recovery_screen')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('forgot_pin_reset_error')), findsOneWidget);
    },
  );
}
