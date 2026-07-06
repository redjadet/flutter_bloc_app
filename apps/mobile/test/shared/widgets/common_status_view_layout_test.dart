import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CommonStatusView scrolls when content is too tall', (
    tester,
  ) async {
    final longMessage = List<String>.generate(200, (i) => 'Line $i').join('\n');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: CommonStatusView(
              title: 'Title',
              message: longMessage,
              action: const Text('Action'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
