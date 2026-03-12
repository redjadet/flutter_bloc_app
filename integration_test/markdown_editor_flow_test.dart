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

  group('Markdown editor flow', () {
    testWidgets(
      'opens markdown editor from overflow and shows markdown editor page',
      (
        final tester,
      ) async {
        await launchTestApp(tester);

        await pumpUntilFound(tester, find.byTooltip('More'));
        await tester.tap(find.byTooltip('More'));
        await pumpUntilFound(tester, find.text('Open Markdown Editor'));
        final Finder markdownMenuItem = find.text('Open Markdown Editor');
        await tester.ensureVisible(markdownMenuItem);
        await tester.pumpAndSettle();
        await tester.tap(markdownMenuItem);
        await pumpUntilFound(tester, find.text('Markdown Editor'));

        expect(find.text('Markdown Editor'), findsWidgets);
      },
    );
  });
}
