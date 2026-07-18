import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/memory/leak_safe_test_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  leakSafeTestWidgets('GoRouter MaterialApp mount/unmount is leak-safe', (final tester) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (final BuildContext context, final GoRouterState state) {
            return const Scaffold(body: Center(child: Text('home')));
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'details',
              builder: (final BuildContext context, final GoRouterState state) {
                return const Scaffold(body: Center(child: Text('details')));
              },
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    expect(find.text('home'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    router.dispose();
  });
}
