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

  group('Whiteboard flow', () {
    testWidgets('opens whiteboard from overflow and shows whiteboard page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('More'));
      await tester.tap(find.byTooltip('More'));
      await pumpUntilFound(tester, find.text('Open Whiteboard'));
      final Finder whiteboardMenuItem = find.text('Open Whiteboard');
      await tester.ensureVisible(whiteboardMenuItem);
      await tester.pumpAndSettle();
      await tester.tap(whiteboardMenuItem);
      await pumpUntilFound(tester, find.text('Whiteboard'));

      expect(find.text('Whiteboard'), findsWidgets);
    });
  });
}
