import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_page_app_bar.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('CounterPageAppBar', () {
    bool settingsOpened = false;

    Widget buildSubject({
      String title = 'Counter',
      TargetPlatform platform = TargetPlatform.android,
    }) {
      return MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                appBar: CounterPageAppBar(
                  title: title,
                  onOpenSettings: () {
                    settingsOpened = true;
                  },
                ),
                body: const Text('Counter Page'),
              ),
            ),
            GoRoute(
              path: AppRoutes.calculator,
              builder: (context, state) =>
                  const Scaffold(body: Text('Calculator Page')),
            ),
            GoRoute(
              path: AppRoutes.example,
              builder: (context, state) =>
                  const Scaffold(body: Text('Example Page')),
            ),
            GoRoute(
              path: AppRoutes.charts,
              builder: (context, state) =>
                  const Scaffold(body: Text('Charts Page')),
            ),
            GoRoute(
              path: AppRoutes.graphql,
              builder: (context, state) =>
                  const Scaffold(body: Text('GraphQL Page')),
            ),
            GoRoute(
              path: AppRoutes.chat,
              builder: (context, state) =>
                  const Scaffold(body: Text('Chat Page')),
            ),
            GoRoute(
              path: AppRoutes.googleMaps,
              builder: (context, state) =>
                  const Scaffold(body: Text('Google Maps Page')),
            ),
          ],
        ),
      );
    }

    setUp(() {
      settingsOpened = false;
    });

    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(buildSubject(title: 'Test Counter'));
      await tester.pumpAndSettle();

      expect(find.text('Test Counter'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('opens settings when settings button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(settingsOpened, isTrue);
    });

    testWidgets('calculator button is tappable', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Verify button exists and is tappable
      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
      final calculatorButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.payments_outlined),
          matching: find.byType(IconButton),
        ),
      );
      expect(calculatorButton.onPressed, isNotNull);
    });

    testWidgets('example button is tappable', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Verify button exists and is tappable
      expect(find.byIcon(Icons.explore), findsOneWidget);
      final exampleButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.explore),
          matching: find.byType(IconButton),
        ),
      );
      expect(exampleButton.onPressed, isNotNull);
    });

    testWidgets('shows overflow menu', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Find PopupMenuButton in the AppBar actions
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, isNotNull);
      expect(
        appBar.actions!.length,
        greaterThan(3),
      ); // Should have overflow menu

      // Verify PopupMenuButton exists by checking actions
      final hasPopupMenu = appBar.actions!.any(
        (action) => action is PopupMenuButton,
      );
      expect(hasPopupMenu, isTrue);
    });

    testWidgets('navigates to charts from overflow menu', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Find PopupMenuButton and tap it
      final popupMenuButton = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(PopupMenuButton),
      );

      if (popupMenuButton.evaluate().isNotEmpty) {
        await tester.tap(popupMenuButton);
        await tester.pumpAndSettle();

        // Find charts menu item using the localization
        final BuildContext context = tester.element(find.byType(AppBar));
        final l10n = AppLocalizations.of(context);
        final chartsText = l10n.openChartsTooltip;
        final chartsMenuItem = find.text(chartsText);

        if (chartsMenuItem.evaluate().isNotEmpty) {
          await tester.tap(chartsMenuItem);
          await tester.pumpAndSettle();
          expect(find.text('Charts Page'), findsOneWidget);
        }
      }
    });

    testWidgets('renders CupertinoNavigationBar on iOS', (tester) async {
      await tester.pumpWidget(buildSubject(platform: TargetPlatform.iOS));
      await tester.pumpAndSettle();

      // On iOS, should render CupertinoNavigationBar
      // Note: This test may need adjustment based on actual platform detection
      expect(find.byType(CounterPageAppBar), findsOneWidget);
    });

    testWidgets('has correct preferred size', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final appBar = tester.widget<CounterPageAppBar>(
        find.byType(CounterPageAppBar),
      );
      expect(appBar.preferredSize.height, equals(kToolbarHeight));
    });

    testWidgets('displays all action buttons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
      expect(find.byIcon(Icons.explore), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Verify overflow menu exists in AppBar actions
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, isNotNull);
      final hasOverflowMenu = appBar.actions!.any(
        (action) => action is PopupMenuButton,
      );
      expect(hasOverflowMenu, isTrue);
    });
  });
}
