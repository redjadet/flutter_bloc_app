import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/shared/utils/navigation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('NavigationUtils.popOrGoHome', () {
    testWidgets('pops current route when navigator can pop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    const Text('Home Screen'),
                    ElevatedButton(
                      key: const ValueKey('push'),
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (context) {
                              return Scaffold(
                                body: Builder(
                                  builder: (innerContext) {
                                    return Column(
                                      children: [
                                        const Text('Details Screen'),
                                        ElevatedButton(
                                          key: const ValueKey('pop'),
                                          onPressed: () =>
                                              NavigationUtils.popOrGoHome(
                                                innerContext,
                                              ),
                                          child: const Text('Pop'),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: const Text('Open Details'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('push')));
      await tester.pumpAndSettle();

      expect(find.text('Details Screen'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('pop')));
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Details Screen'), findsNothing);
    });

    testWidgets('navigates to home route when navigator cannot pop', (
      WidgetTester tester,
    ) async {
      final GoRouter router = GoRouter(
        initialLocation: '/example',
        routes: <GoRoute>[
          GoRoute(
            path: AppRoutes.counterPath,
            builder: (context, state) => const Text('Counter Screen'),
          ),
          GoRoute(
            path: '/example',
            builder: (context, state) => Scaffold(
              body: Center(
                child: Builder(
                  builder: (innerContext) {
                    return ElevatedButton(
                      onPressed: () =>
                          NavigationUtils.popOrGoHome(innerContext),
                      child: const Text('Navigate Home'),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Navigate Home'), findsOneWidget);
      expect(find.text('Counter Screen'), findsNothing);

      await tester.tap(find.text('Navigate Home'));
      await tester.pumpAndSettle();

      expect(find.text('Counter Screen'), findsOneWidget);
      expect(find.text('Navigate Home'), findsNothing);
    });
  });
}
