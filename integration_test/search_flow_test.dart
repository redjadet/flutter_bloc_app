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

  group('Search flow', () {
    testWidgets('opens search from example and shows results section', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tester.tap(find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      await tester.scrollUntilVisible(
        find.text('Search Demo'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final Finder searchDemoButton = find.text('Search Demo');
      await tester.ensureVisible(searchDemoButton);
      await tester.pumpAndSettle();
      await tester.tap(searchDemoButton);
      await pumpUntilFound(tester, find.text('ALL RESULTS'));

      expect(find.text('ALL RESULTS'), findsWidgets);
    });
  });
}
