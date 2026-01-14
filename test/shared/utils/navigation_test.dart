import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('NavigationUtils', () {
    testWidgets('maybePop returns true when can pop', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/first',
          routes: {
            '/first': (final context) => const FirstPage(),
            '/second': (final context) => const SecondPage(),
          },
        ),
      );

      // Navigate to second page
      Navigator.of(tester.element(find.byType(FirstPage))).pushNamed('/second');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final bool result = NavigationUtils.maybePop(
        tester.element(find.byType(SecondPage)),
      );

      expect(result, isTrue);
    });

    testWidgets('maybePop returns false when cannot pop', (final tester) async {
      await tester.pumpWidget(const MaterialApp(home: FirstPage()));

      final bool result = NavigationUtils.maybePop(
        tester.element(find.byType(FirstPage)),
      );

      expect(result, isFalse);
    });

    testWidgets('popOrGoHome pops when possible', (final tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/first',
          routes: {
            '/first': (final context) => const FirstPage(),
            '/second': (final context) => const SecondPage(),
          },
        ),
      );

      Navigator.of(tester.element(find.byType(FirstPage))).pushNamed('/second');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      NavigationUtils.popOrGoHome(tester.element(find.byType(SecondPage)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FirstPage), findsOneWidget);
    });

    testWidgets('popOrGoHome navigates home when cannot pop', (
      final tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: AppRoutes.counterPath,
        routes: [
          GoRoute(
            path: AppRoutes.counterPath,
            builder: (final context, final state) => const FirstPage(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      NavigationUtils.popOrGoHome(tester.element(find.byType(FirstPage)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be on counter page (home)
      expect(find.byType(FirstPage), findsOneWidget);
    });

    testWidgets('safeGo navigates after delay when context is mounted', (
      final tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: AppRoutes.counterPath,
        routes: [
          GoRoute(
            path: AppRoutes.counterPath,
            builder: (final context, final state) => const FirstPage(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      unawaited(
        NavigationUtils.safeGo(
          tester.element(find.byType(FirstPage)),
          router: router,
          location: AppRoutes.counterPath,
          delay: const Duration(milliseconds: 50),
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));

      // Should not throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('safeGo skips navigation when context is not mounted', (
      final tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: AppRoutes.counterPath,
        routes: [
          GoRoute(
            path: AppRoutes.counterPath,
            builder: (final context, final state) => const FirstPage(),
          ),
        ],
      );

      bool onSkippedCalled = false;

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      final BuildContext context = tester.element(find.byType(FirstPage));

      // Remove widget from tree
      await tester.pumpWidget(const SizedBox());

      unawaited(
        NavigationUtils.safeGo(
          context,
          router: router,
          location: AppRoutes.counterPath,
          delay: const Duration(milliseconds: 50),
          onSkipped: () {
            onSkippedCalled = true;
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 60));

      expect(onSkippedCalled, isTrue);
    });

    testWidgets('safeGo handles navigation errors', (final tester) async {
      final GoRouter router = GoRouter(
        initialLocation: AppRoutes.counterPath,
        routes: [
          GoRoute(
            path: AppRoutes.counterPath,
            builder: (final context, final state) => const FirstPage(),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await NavigationUtils.safeGo(
        tester.element(find.byType(FirstPage)),
        router: router,
        location: '/invalid-path',
        delay: Duration.zero,
      );

      // Should handle error gracefully
      expect(tester.takeException(), isNull);
    });
  });
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(final BuildContext context) =>
      const Scaffold(body: Text('First Page'));
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(final BuildContext context) =>
      const Scaffold(body: Text('Second Page'));
}
