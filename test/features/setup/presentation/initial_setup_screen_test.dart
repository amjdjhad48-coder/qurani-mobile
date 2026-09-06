import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/features/setup/application/setup_providers.dart';
import 'package:qurani/features/setup/domain/initial_setup_request.dart';
import 'package:qurani/features/setup/presentation/initial_setup_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required InitialSetupSubmitter submitter,
    bool recovering = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          initialSetupSubmitterProvider.overrideWithValue(submitter),
        ],
        child: MaterialApp(home: InitialSetupScreen(recovering: recovering)),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows exactly the approved first-setup identity fields', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, submitter: (_) async {});

    expect(find.text('اسم المعلم'), findsOneWidget);
    expect(find.text('اسم الحلقة'), findsOneWidget);
    expect(find.text('اسم المركز/المسجد'), findsOneWidget);
    expect(find.text('هل توجد جهة داعمة؟'), findsOneWidget);
    expect(find.text('PIN من 6 أرقام'), findsOneWidget);
    expect(find.textContaining('رقم هاتف'), findsNothing);
    expect(find.textContaining('عدد الطلاب'), findsNothing);
    expect(find.textContaining('تأكيد PIN'), findsNothing);
  });

  testWidgets('support organization field appears only when support is yes', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester, submitter: (_) async {});

    expect(find.byKey(const Key('support_organization_field')), findsNothing);

    await tester.tap(find.byKey(const Key('support_toggle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('support_organization_field')), findsOneWidget);
  });

  testWidgets('valid form submits normalized approved request', (
    WidgetTester tester,
  ) async {
    InitialSetupRequest? captured;

    await pumpScreen(
      tester,
      submitter: (request) async {
        captured = request;
      },
    );

    await tester.enterText(
      find.byKey(const Key('teacher_name_field')),
      '  المعلم  ',
    );
    await tester.enterText(
      find.byKey(const Key('halaqah_name_field')),
      '  الحلقة  ',
    );
    await tester.enterText(
      find.byKey(const Key('center_name_field')),
      '  مسجد النور  ',
    );

    await tester.tap(find.byKey(const Key('support_toggle')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('support_organization_field')),
      '  الجهة الداعمة  ',
    );
    await tester.enterText(find.byKey(const Key('pin_field')), '482731');

    await tester.ensureVisible(find.byKey(const Key('submit_setup_button')));
    await tester.tap(find.byKey(const Key('submit_setup_button')));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.normalizedTeacherName, 'المعلم');
    expect(captured!.normalizedHalaqahName, 'الحلقة');
    expect(captured!.normalizedCenterName, 'مسجد النور');
    expect(captured!.hasSupportOrganization, isTrue);
    expect(captured!.normalizedSupportOrganizationName, 'الجهة الداعمة');
    expect(captured!.pin, '482731');
  });

  testWidgets('weak PIN is rejected before the setup service is called', (
    WidgetTester tester,
  ) async {
    var calls = 0;

    await pumpScreen(
      tester,
      submitter: (_) async {
        calls += 1;
      },
    );

    await tester.enterText(
      find.byKey(const Key('teacher_name_field')),
      'المعلم',
    );
    await tester.enterText(
      find.byKey(const Key('halaqah_name_field')),
      'الحلقة',
    );
    await tester.enterText(
      find.byKey(const Key('center_name_field')),
      'المركز',
    );
    await tester.enterText(find.byKey(const Key('pin_field')), '123456');

    await tester.ensureVisible(find.byKey(const Key('submit_setup_button')));
    await tester.tap(find.byKey(const Key('submit_setup_button')));
    await tester.pumpAndSettle();

    expect(calls, 0);
    expect(find.textContaining('غير مسموح'), findsOneWidget);
  });
}
