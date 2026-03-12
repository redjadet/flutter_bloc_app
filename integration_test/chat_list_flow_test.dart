import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeIntegrationTestHarness);

  setUp(() async {
    await configureIntegrationTestDependencies();
  });

  tearDown(() async {
    await tearDownIntegrationTestDependencies();
  });

  group('Chat list flow', () {
    testWidgets('opens chat list from example and shows conversation history', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tester.tap(find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      await tester.scrollUntilVisible(
        find.text('Chat List Demo'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final Finder chatListDemoButton = find.text('Chat List Demo');
      await tester.ensureVisible(chatListDemoButton);
      await tester.pumpAndSettle();
      await tester.tap(chatListDemoButton);
      await pumpUntilFound(tester, find.text('Conversation history'));

      expect(find.text('Conversation history'), findsWidgets);
    });
  });
}
