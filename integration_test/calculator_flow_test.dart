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

  group('Calculator flow', () {
    testWidgets('opens calculator from home and shows calculator page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open payment calculator'));
      await tester.tap(find.byTooltip('Open payment calculator'));
      await pumpUntilFound(tester, find.text('Payment calculator'));

      expect(find.text('Payment calculator'), findsWidgets);
    });
  });
}
