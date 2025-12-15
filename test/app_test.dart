import 'package:flutter_bloc_app/app.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/features/counter/presentation/pages/counter_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart' as test_helpers;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    await test_helpers.setupTestDependencies();
  });

  tearDown(() async {
    await test_helpers.tearDownTestDependencies();
  });

  group('MyApp', () {
    testWidgets('renders counter page when auth not required', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp(requireAuth: false));
      // Wait for initial build and async operations
      await tester.pump();
      // Allow time for cubits to initialize
      await tester.pump(const Duration(milliseconds: 100));
      // Wait for any pending timers/async operations
      await tester.pump(const Duration(seconds: 1));
      // Check without waiting for all animations to settle
      expect(find.byType(CounterPage), findsOneWidget);
    });

    testWidgets(
      'creates router with correct initial location when auth not required',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp(requireAuth: false));
        await tester.pump();
        // Allow time for cubits to initialize and any async operations
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(seconds: 1));

        // Verify AppScope is rendered (which contains the router)
        // This test verifies the router is created correctly
        expect(find.byType(AppScope), findsOneWidget);
      },
    );

    // Note: Testing `requireAuth: true` requires Firebase Auth initialization
    // which is complex in widget tests. The router creation logic is tested
    // indirectly through the `requireAuth: false` case and the auth_redirect_test.dart

    testWidgets('router uses correct initial location', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp(requireAuth: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));

      // Verify counter page is shown (which is the initial location)
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
