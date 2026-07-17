import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/memory/leak_safe_test_widgets.dart';

/// App-shell style route *replacement* (`go`), not push/pop stacks.
///
/// Uses [NoTransitionPage] so Material route animations do not dominate the
/// leak report (B0/B1 harness noise). Owned [GoRouter] is disposed after
/// unmount.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  leakSafeTestWidgets('app-shell go route replacement is leak-safe', (final tester) async {
    final GoRouter router = GoRouter(
      initialLocation: '/home',
      routes: <RouteBase>[
        GoRoute(
          path: '/home',
          pageBuilder: (final BuildContext context, final GoRouterState state) {
            return const NoTransitionPage<void>(
              child: Scaffold(body: Center(child: Text('shell-home'))),
            );
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (final BuildContext context, final GoRouterState state) {
            return const NoTransitionPage<void>(
              child: Scaffold(body: Center(child: Text('shell-settings'))),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    expect(find.text('shell-home'), findsOneWidget);

    router.go('/settings');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('shell-settings'), findsOneWidget);

    router.go('/home');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('shell-home'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    router.dispose();
  });
}
