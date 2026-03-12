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

  group('IoT demo flow', () {
    testWidgets('opens IoT demo from overflow and shows IoT demo page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('More'));
      await tester.tap(find.byTooltip('More'));
      await pumpUntilFound(tester, find.text('Open IoT Demo'));
      final Finder iotMenuItem = find.text('Open IoT Demo');
      await tester.ensureVisible(iotMenuItem);
      await tester.pumpAndSettle();
      await tester.tap(iotMenuItem);
      await pumpUntilFound(tester, find.text('IoT Demo'));

      expect(find.text('IoT Demo'), findsWidgets);
    });
  });
}
