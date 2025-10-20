import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _pushButtonKey = ValueKey('navigation-utils-push-button');
const _popButtonKey = ValueKey('navigation-utils-pop-button');
const _navigateHomeButtonKey = ValueKey('navigation-utils-home-button');

const _homeScreenLabel = 'Home Screen';
const _detailsScreenLabel = 'Details Screen';
const _openDetailsLabel = 'Open Details';
const _popLabel = 'Pop';
const _navigateHomeLabel = 'Navigate Home';
const _counterScreenLabel = 'Counter Screen';
const _exampleRoutePath = '/example';

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

GoRouter _createRouter() {
  return GoRouter(
    initialLocation: _exampleRoutePath,
    routes: <GoRoute>[
      GoRoute(
        path: AppRoutes.counterPath,
        builder: (context, state) => const Text(_counterScreenLabel),
      ),
      GoRoute(
        path: _exampleRoutePath,
        builder: (context, state) => const _ExampleRoute(),
      ),
    ],
  );
}

void main() {
  group('NavigationUtils.popOrGoHome', () {
    testWidgets('pops current route when navigator can pop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const _NavigatorPopTestApp());

      await _tapAndSettle(tester, find.byKey(_pushButtonKey));
      expect(find.text(_detailsScreenLabel), findsOneWidget);

      await _tapAndSettle(tester, find.byKey(_popButtonKey));
      expect(find.text(_homeScreenLabel), findsOneWidget);
      expect(find.text(_detailsScreenLabel), findsNothing);
    });

    testWidgets('navigates to home route when navigator cannot pop', (
      WidgetTester tester,
    ) async {
      final GoRouter router = _createRouter();
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text(_navigateHomeLabel), findsOneWidget);
      expect(find.text(_counterScreenLabel), findsNothing);

      await _tapAndSettle(tester, find.text(_navigateHomeLabel));

      expect(find.text(_counterScreenLabel), findsOneWidget);
      expect(find.text(_navigateHomeLabel), findsNothing);
    });
  });
}

class _NavigatorPopTestApp extends StatelessWidget {
  const _NavigatorPopTestApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: _PopTestHome());
  }
}

class _PopTestHome extends StatelessWidget {
  const _PopTestHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(_homeScreenLabel),
          ElevatedButton(
            key: _pushButtonKey,
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const _DetailsScreen()),
            ),
            child: const Text(_openDetailsLabel),
          ),
        ],
      ),
    );
  }
}

class _DetailsScreen extends StatelessWidget {
  const _DetailsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text(_detailsScreenLabel),
          ElevatedButton(
            key: _popButtonKey,
            onPressed: () => NavigationUtils.popOrGoHome(context),
            child: const Text(_popLabel),
          ),
        ],
      ),
    );
  }
}

class _ExampleRoute extends StatelessWidget {
  const _ExampleRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: _navigateHomeButtonKey,
          onPressed: () => NavigationUtils.popOrGoHome(context),
          child: const Text(_navigateHomeLabel),
        ),
      ),
    );
  }
}
