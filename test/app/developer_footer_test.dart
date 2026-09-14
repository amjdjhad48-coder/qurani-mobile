import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qurani/app/widgets/developer_footer.dart';

void main() {
  testWidgets('developer footer shows the approved exact text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DeveloperFooter())),
    );

    expect(find.text('برمجة وتطوير المهندس أمجد جهاد'), findsOneWidget);

    expect(find.byKey(const Key('developer_footer')), findsOneWidget);
  });
}
