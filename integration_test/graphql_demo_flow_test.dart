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

  group('GraphQL demo flow', () {
    testWidgets('opens GraphQL demo from overflow and shows GraphQL page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('More'));
      await tester.tap(find.byTooltip('More'));
      await pumpUntilFound(tester, find.text('Explore GraphQL sample'));
      await tester.tap(find.text('Explore GraphQL sample'));
      await pumpUntilFound(
        tester,
        find.text('GraphQL Countries'),
        timeout: const Duration(seconds: 10),
      );

      expect(find.text('GraphQL Countries'), findsWidgets);
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
  });
}
