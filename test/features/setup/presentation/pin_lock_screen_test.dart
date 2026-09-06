import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/setup/presentation/pin_lock_screen.dart';

void main() {
  testWidgets('requires exactly six digits before invoking runtime unlock', (
    WidgetTester tester,
  ) async {
    final submitted = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: PinLockScreen(
          busy: false,
          failedAttemptCount: 0,
          lockedUntilUtc: null,
          errorText: null,
          onSubmit: (pin) async {
            submitted.add(pin);
          },
          onForgotPin: () {},
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('pin_unlock_field')), '12345');
    await tester.tap(find.byKey(const Key('pin_unlock_button')));
    await tester.pump();

    expect(submitted, isEmpty);
    expect(find.text('أدخل PIN من 6 أرقام.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('pin_unlock_field')), '482731');
    await tester.tap(find.byKey(const Key('pin_unlock_button')));
    await tester.pump();

    expect(submitted, <String>['482731']);
  });

  testWidgets('shows concise error, attempt count, and temporary lock state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PinLockScreen(
          busy: false,
          failedAttemptCount: 5,
          lockedUntilUtc: DateTime.utc(2026, 9, 4, 20, 1),
          errorText: 'تم تفعيل القفل المؤقت.',
          onSubmit: (_) async {},
          onForgotPin: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('temporary_lock_message')), findsOneWidget);
    expect(find.byKey(const Key('failed_attempt_count')), findsOneWidget);
    expect(find.text('المحاولات غير الصحيحة: 5'), findsOneWidget);
    expect(find.text('تم تفعيل القفل المؤقت.'), findsOneWidget);
  });

  testWidgets(
    'forgot PIN entry is available even while a temporary lock is shown',
    (WidgetTester tester) async {
      var forgotCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: PinLockScreen(
            busy: false,
            failedAttemptCount: 5,
            lockedUntilUtc: DateTime.utc(2026, 9, 5, 9, 1),
            errorText: null,
            onSubmit: (_) async {},
            onForgotPin: () {
              forgotCalls += 1;
            },
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('forgot_pin_button')));
      await tester.pump();

      expect(forgotCalls, 1);
    },
  );
}
