import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qurani/app/qurani_app.dart';
import 'package:qurani/bootstrap/qurani_bootstrap.dart';

void main() {
  testWidgets('production bootstrap mounts Riverpod and QuraniApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const QuraniRoot());

    expect(find.byType(ProviderScope), findsOneWidget);
    expect(find.byType(QuraniApp), findsOneWidget);
    expect(find.text('قرآني'), findsOneWidget);
  });
}
