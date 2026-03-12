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

  group('iGaming demo flow', () {
    testWidgets(
      'opens iGaming demo from overflow and shows iGaming demo lobby',
      (
        final tester,
      ) async {
        await launchTestApp(tester);

        await pumpUntilFound(tester, find.byTooltip('More'));
        await tester.tap(find.byTooltip('More'));
        await pumpUntilFound(tester, find.text('iGaming Demo'));
        final Finder igamingMenuItem = find.text('iGaming Demo');
        await tester.ensureVisible(igamingMenuItem);
        await tester.pumpAndSettle();
        await tester.tap(igamingMenuItem);
        await pumpUntilFound(tester, find.text('iGaming Demo'));

        expect(find.text('iGaming Demo'), findsWidgets);
      },
    );
  });
}
