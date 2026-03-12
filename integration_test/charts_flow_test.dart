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

  group('Charts flow', () {
    testWidgets('opens charts from overflow and shows chart page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('More'));
      await tester.tap(find.byTooltip('More'));
      await pumpUntilFound(tester, find.text('Open charts'));
      final Finder chartsMenuItem = find.text('Open charts');
      await tester.ensureVisible(chartsMenuItem);
      await tester.pumpAndSettle();
      await tester.tap(chartsMenuItem);
      await pumpUntilFound(tester, find.text('Bitcoin Price (USD)'));

      expect(find.text('Bitcoin Price (USD)'), findsWidgets);
    });
  });
}
