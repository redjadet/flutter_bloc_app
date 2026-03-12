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

  group('WebSocket flow', () {
    testWidgets('opens WebSocket demo from example and shows WebSocket page', (
      final tester,
    ) async {
      await launchTestApp(tester);

      await pumpUntilFound(tester, find.byTooltip('Open example page'));
      await tester.tap(find.byTooltip('Open example page'));
      await pumpUntilFound(tester, find.text('Example Page'));

      await tester.scrollUntilVisible(
        find.text('Open WebSocket demo'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final Finder websocketButton = find.text('Open WebSocket demo');
      await tester.ensureVisible(websocketButton);
      await tester.pumpAndSettle();
      await tester.tap(websocketButton);
      await pumpUntilFound(tester, find.text('WebSocket demo'));

      expect(find.text('WebSocket demo'), findsWidgets);
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
  });
}
