import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Integration test scaffolding for critical app flows.
///
/// Run with: `flutter test integration_test/`
/// Or on device: `flutter test integration_test/app_test.dart`
///
/// Add further tests for:
/// - Auth: sign-in/sign-out flow (may require Firebase emulator or test auth)
/// - Counter persistence: increment, restart app, verify count restored
/// - Offline-first sync: trigger sync, verify UI updates
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App launch', () {
    testWidgets('app starts and renders', (final tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 30));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
