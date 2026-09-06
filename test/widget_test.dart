import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/app/qurani_app.dart';
import 'package:qurani/bootstrap/qurani_bootstrap.dart';
import 'package:qurani/core/security/android_local_security_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const localSecurityChannel = MethodChannel(
    AndroidLocalSecurityStore.channelName,
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    messenger.setMockMethodCallHandler(localSecurityChannel, (call) async {
      expect(call.method, 'read');
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(localSecurityChannel, null);
  });

  testWidgets('production bootstrap mounts Riverpod and routes to setup gate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const QuraniRoot());
    await tester.pumpAndSettle();

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(QuraniApp), findsOneWidget);
    expect(find.text('الإعداد الأول'), findsOneWidget);
    expect(find.byKey(const Key('teacher_name_field')), findsOneWidget);
  });
}
