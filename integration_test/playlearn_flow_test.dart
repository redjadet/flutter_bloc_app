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

  group('Playlearn flow', () {
    testWidgets('opens playlearn from overflow and shows playlearn page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('More'));
      await tester.tap(find.byTooltip('More'));
      await pumpUntilFound(tester, find.text('Open Playlearn'));
      final Finder playlearnMenuItem = find.text('Open Playlearn');
      await tester.ensureVisible(playlearnMenuItem);
      await tester.pumpAndSettle();
      await tester.tap(playlearnMenuItem);
      await pumpUntilFound(
        tester,
        find.text('Playlearn'),
        timeout: const Duration(seconds: 10),
      );

      expect(find.text('Playlearn'), findsWidgets);
    });
  });
}
