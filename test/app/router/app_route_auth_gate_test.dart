import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/app_route_auth_gate.dart';
import 'package:flutter_bloc_app/app/router/route_auth_policy.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRouteAuthGate', () {
    testWidgets('redirects unauthenticated deep links for protected routes', (
      final tester,
    ) async {
      final StreamController<AuthUser?> authController =
          StreamController<AuthUser?>.broadcast();
      addTearDown(authController.close);

      AuthUser? currentUser;
      final GoRouter router = _createRouter(
        initialLocation: AppRoutes.profilePath,
        authStateChanges: authController.stream,
        getCurrentUser: () => currentUser,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('auth:/profile'), findsOneWidget);
      expect(find.text('profile'), findsNothing);
    });

    testWidgets('redirects unauthenticated in-app navigation to auth', (
      final tester,
    ) async {
      final StreamController<AuthUser?> authController =
          StreamController<AuthUser?>.broadcast();
      addTearDown(authController.close);

      AuthUser? currentUser;
      final GoRouter router = _createRouter(
        initialLocation: AppRoutes.counterPath,
        authStateChanges: authController.stream,
        getCurrentUser: () => currentUser,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('go to profile'), findsOneWidget);

      await tester.tap(find.text('go to profile'));
      await tester.pumpAndSettle();

      expect(find.text('auth:/profile'), findsOneWidget);
      expect(find.text('profile'), findsNothing);
    });

    testWidgets('shows protected child for authenticated users', (
      final tester,
    ) async {
      final StreamController<AuthUser?> authController =
          StreamController<AuthUser?>.broadcast();
      addTearDown(authController.close);

      AuthUser? currentUser = const AuthUser(id: 'user-1', isAnonymous: false);
      final GoRouter router = _createRouter(
        initialLocation: AppRoutes.profilePath,
        authStateChanges: authController.stream,
        getCurrentUser: () => currentUser,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('profile'), findsOneWidget);
      expect(find.text('auth'), findsNothing);
    });

    testWidgets('does not crash when authStateChanges emits an error', (
      final tester,
    ) async {
      final StreamController<AuthUser?> authController =
          StreamController<AuthUser?>.broadcast();
      addTearDown(authController.close);

      AuthUser? currentUser;
      final GoRouter router = _createRouter(
        initialLocation: AppRoutes.profilePath,
        authStateChanges: authController.stream,
        getCurrentUser: () => currentUser,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      authController.addError(StateError('auth stream failed'));
      await tester.pump();

      // The gate should handle onError and remain stable.
      expect(find.text('auth:/profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not navigate after dispose when auth stream emits', (
      final tester,
    ) async {
      final StreamController<AuthUser?> authController =
          StreamController<AuthUser?>.broadcast();
      addTearDown(authController.close);

      AuthUser? currentUser;
      final GoRouter router = _createRouter(
        initialLocation: AppRoutes.profilePath,
        authStateChanges: authController.stream,
        getCurrentUser: () => currentUser,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Dispose the widget tree.
      await tester.pumpWidget(const SizedBox.shrink());

      // Emitting after dispose should not throw.
      authController.add(null);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('AppRoutePolicies', () {
    test('profile route is explicitly marked authenticated', () {
      expect(AppRoutePolicies.profile.path, AppRoutes.profilePath);
      expect(AppRoutePolicies.profile.requiresAuthentication, isTrue);
    });
  });
}

GoRouter _createRouter({
  required final String initialLocation,
  required final Stream<AuthUser?> authStateChanges,
  required final AuthUser? Function() getCurrentUser,
}) => GoRouter(
  initialLocation: initialLocation,
  routes: <GoRoute>[
    GoRoute(
      path: AppRoutes.counterPath,
      builder: (final context, final state) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => context.go(AppRoutes.profilePath),
            child: const Text('go to profile'),
          ),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.profilePath,
      builder: (final context, final state) => AppRouteAuthGate(
        policy: AppRoutePolicies.profile,
        getCurrentUser: getCurrentUser,
        authStateChanges: authStateChanges,
        authPath: AppRoutes.authPath,
        child: const Scaffold(body: Center(child: Text('profile'))),
      ),
    ),
    GoRoute(
      path: AppRoutes.authPath,
      builder: (final context, final state) => Scaffold(
        body: Center(
          child: Text('auth:${state.uri.queryParameters['redirect'] ?? ''}'),
        ),
      ),
    ),
  ],
);
