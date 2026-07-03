import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/profile/presentation/widgets/profile_bottom_nav.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _profileScreenLabel = 'Profile Screen';
const _registerScreenLabel = 'Register Screen';
const _chatScreenLabel = 'Chat Screen';
const _exampleScreenLabel = 'Example Screen';

Future<void> _pumpBottomNavApp(
  final WidgetTester tester, {
  String initialLocation = AppRoutes.profilePath,
}) async {
  final GoRouter router = GoRouter(
    initialLocation: initialLocation,
    routes: <GoRoute>[
      GoRoute(
        path: AppRoutes.profilePath,
        builder: (final context, final state) => const Scaffold(
          body: Center(child: Text(_profileScreenLabel)),
          bottomNavigationBar: ProfileBottomNav(),
        ),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        builder: (final context, final state) =>
            const Scaffold(body: Center(child: Text(_registerScreenLabel))),
      ),
      GoRoute(
        path: AppRoutes.chatListPath,
        builder: (final context, final state) =>
            const Scaffold(body: Center(child: Text(_chatScreenLabel))),
      ),
      GoRoute(
        path: AppRoutes.examplePath,
        builder: (final context, final state) =>
            const Scaffold(body: Center(child: Text(_exampleScreenLabel))),
      ),
      GoRoute(
        path: AppRoutes.searchPath,
        builder: (final context, final state) =>
            const Scaffold(body: Center(child: Text('Search Screen'))),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
}

Future<void> _tapNavLabel(final WidgetTester tester, final String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('ProfileBottomNav', () {
    testWidgets('stays on profile when current destination is tapped', (
      final WidgetTester tester,
    ) async {
      await _pumpBottomNavApp(tester);

      await _tapNavLabel(tester, 'Profile');

      expect(find.text(_profileScreenLabel), findsOneWidget);
      expect(find.text(_registerScreenLabel), findsNothing);
      expect(find.text(_chatScreenLabel), findsNothing);
      expect(find.text(_exampleScreenLabel), findsNothing);
    });

    testWidgets('pushes register route from add action', (
      final WidgetTester tester,
    ) async {
      await _pumpBottomNavApp(tester);

      await _tapNavLabel(tester, 'Add');

      expect(find.text(_registerScreenLabel), findsOneWidget);
      expect(find.text(_profileScreenLabel), findsNothing);
    });

    testWidgets('pushes chat list route from chat destination', (
      final WidgetTester tester,
    ) async {
      await _pumpBottomNavApp(tester);

      await _tapNavLabel(tester, 'Chat');

      expect(find.text(_chatScreenLabel), findsOneWidget);
      expect(find.text(_profileScreenLabel), findsNothing);
    });

    testWidgets('goes to example route when no route can be popped', (
      final WidgetTester tester,
    ) async {
      await _pumpBottomNavApp(tester);

      await _tapNavLabel(tester, 'Example');

      expect(find.text(_exampleScreenLabel), findsOneWidget);
      expect(find.text(_profileScreenLabel), findsNothing);
    });
  });
}
