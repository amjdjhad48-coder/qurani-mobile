import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/setup/application/runtime_lock_service.dart';
import 'package:qurani/features/setup/presentation/change_pin_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required SubmitChangePin onSubmit,
    Future<void> Function()? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangePinScreen(
          onSubmit: onSubmit,
          onChanged: onChanged ?? () async {},
          onCancel: () {},
        ),
      ),
    );
  }

  testWidgets('shows current and new PIN only with no confirmation field', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      onSubmit: ({required String currentPin, required String newPin}) async {
        return const RuntimeChangePinResult(RuntimeChangePinStatus.changed);
      },
    );

    expect(find.byKey(const Key('change_pin_current_field')), findsOneWidget);
    expect(find.byKey(const Key('change_pin_new_field')), findsOneWidget);
    expect(find.byKey(const Key('change_pin_confirm_field')), findsNothing);
  });

  testWidgets('requires exactly six digits before calling service', (
    WidgetTester tester,
  ) async {
    var calls = 0;

    await pumpScreen(
      tester,
      onSubmit: ({required String currentPin, required String newPin}) async {
        calls += 1;
        return const RuntimeChangePinResult(RuntimeChangePinStatus.changed);
      },
    );

    await tester.enterText(
      find.byKey(const Key('change_pin_current_field')),
      '48273',
    );
    await tester.enterText(
      find.byKey(const Key('change_pin_new_field')),
      '731482',
    );
    await tester.tap(find.byKey(const Key('change_pin_submit_button')));
    await tester.pump();

    expect(calls, 0);
    expect(find.text('أدخل PIN الحالي من 6 أرقام.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('change_pin_current_field')),
      '482731',
    );
    await tester.enterText(
      find.byKey(const Key('change_pin_new_field')),
      '73148',
    );
    await tester.tap(find.byKey(const Key('change_pin_submit_button')));
    await tester.pump();

    expect(calls, 0);
    expect(find.text('أدخل PIN الجديد من 6 أرقام.'), findsOneWidget);
  });

  testWidgets('wrong current PIN shows concise error and stays on form', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      onSubmit: ({required String currentPin, required String newPin}) async {
        return const RuntimeChangePinResult(
          RuntimeChangePinStatus.invalidCurrentPin,
        );
      },
    );

    await tester.enterText(
      find.byKey(const Key('change_pin_current_field')),
      '482731',
    );
    await tester.enterText(
      find.byKey(const Key('change_pin_new_field')),
      '731482',
    );
    await tester.tap(find.byKey(const Key('change_pin_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('PIN الحالي غير صحيح.'), findsOneWidget);
    expect(find.byKey(const Key('change_pin_screen')), findsOneWidget);
  });

  testWidgets('weak new PIN rejection is surfaced without false success', (
    WidgetTester tester,
  ) async {
    var changedCalls = 0;

    await pumpScreen(
      tester,
      onSubmit: ({required String currentPin, required String newPin}) async {
        throw ArgumentError.value(newPin, 'newPin');
      },
      onChanged: () async {
        changedCalls += 1;
      },
    );

    await tester.enterText(
      find.byKey(const Key('change_pin_current_field')),
      '482731',
    );
    await tester.enterText(
      find.byKey(const Key('change_pin_new_field')),
      '123456',
    );
    await tester.tap(find.byKey(const Key('change_pin_submit_button')));
    await tester.pumpAndSettle();

    expect(find.text('PIN الجديد غير مقبول.'), findsOneWidget);
    expect(changedCalls, 0);
  });

  testWidgets('successful change calls completion callback once', (
    WidgetTester tester,
  ) async {
    var changedCalls = 0;

    await pumpScreen(
      tester,
      onSubmit: ({required String currentPin, required String newPin}) async {
        expect(currentPin, '482731');
        expect(newPin, '731482');
        return const RuntimeChangePinResult(RuntimeChangePinStatus.changed);
      },
      onChanged: () async {
        changedCalls += 1;
      },
    );

    await tester.enterText(
      find.byKey(const Key('change_pin_current_field')),
      '482731',
    );
    await tester.enterText(
      find.byKey(const Key('change_pin_new_field')),
      '731482',
    );
    await tester.tap(find.byKey(const Key('change_pin_submit_button')));
    await tester.pumpAndSettle();

    expect(changedCalls, 1);
  });
}
