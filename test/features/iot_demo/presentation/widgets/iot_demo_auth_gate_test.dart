import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/features/iot_demo/presentation/widgets/iot_demo_auth_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('IotDemoAuthGate', () {
    testWidgets('redirects to auth when Supabase user signs out', (
      final tester,
    ) async {
      final StreamController<AuthUser?> authController =
          StreamController<AuthUser?>.broadcast();
      AuthUser? currentUser = const AuthUser(id: 'user-1', isAnonymous: false);
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (final context, final state) => IotDemoAuthGate(
              isSupabaseInitialized: true,
              getCurrentUser: () => currentUser,
              authStateChanges: authController.stream,
              counterPath: '/counter',
              supabaseAuthPath: '/supabase-auth',
              redirectReturnPath: '/iot-demo',
              child: const Scaffold(body: Text('iot child')),
            ),
          ),
          GoRoute(
            path: '/counter',
            builder: (final context, final state) =>
                const Scaffold(body: Text('counter')),
          ),
          GoRoute(
            path: '/supabase-auth',
            builder: (final context, final state) =>
                const Scaffold(body: Text('supabase auth')),
          ),
        ],
      );
      addTearDown(router.dispose);
      addTearDown(authController.close);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('iot child'), findsOneWidget);

      currentUser = null;
      authController.add(null);
      await tester.pumpAndSettle();

      expect(find.text('supabase auth'), findsOneWidget);
    });

    testWidgets('shows child when Supabase is not configured', (
      final tester,
    ) async {
      final StreamController<AuthUser?> authController =
          StreamController<AuthUser?>.broadcast();
      addTearDown(authController.close);
      final GoRouter router = GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (final context, final state) => IotDemoAuthGate(
              isSupabaseInitialized: false,
              getCurrentUser: () => null,
              authStateChanges: authController.stream,
              counterPath: '/counter',
              supabaseAuthPath: '/supabase-auth',
              redirectReturnPath: '/iot-demo',
              child: const Scaffold(body: Text('iot child')),
            ),
          ),
          GoRoute(
            path: '/counter',
            builder: (final context, final state) =>
                const Scaffold(body: Text('counter')),
          ),
          GoRoute(
            path: '/supabase-auth',
            builder: (final context, final state) =>
                const Scaffold(body: Text('supabase auth')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('iot child'), findsOneWidget);
      expect(find.text('counter'), findsNothing);
      expect(find.text('supabase auth'), findsNothing);
    });
  });
}
