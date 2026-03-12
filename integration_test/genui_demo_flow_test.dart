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

  group('GenUI demo flow', () {
    testWidgets('opens GenUI demo from overflow and shows GenUI demo page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('More'));
      await tester.tap(find.byTooltip('More'));
      await pumpUntilFound(tester, find.text('GenUI Demo'));
      final Finder genuiMenuItem = find.text('GenUI Demo');
      await tester.ensureVisible(genuiMenuItem);
      await tester.pumpAndSettle();
      await tester.tap(genuiMenuItem);
      await pumpUntilFound(tester, find.text('GenUI Demo'));

      expect(find.text('GenUI Demo'), findsWidgets);
    });
  });
}
