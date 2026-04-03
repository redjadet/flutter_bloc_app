import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/case_study_demo/presentation/widgets/case_study_supabase_auth_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('CaseStudySupabaseAuthGate', () {
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
            builder: (final context, final state) => CaseStudySupabaseAuthGate(
              isSupabaseInitialized: true,
              getCurrentUser: () => currentUser,
              authStateChanges: authController.stream,
              fallbackPath: '/counter',
              supabaseAuthPath: '/supabase-auth',
              redirectReturnPath: '/case-study-demo',
              child: const Scaffold(body: Text('case study child')),
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

      expect(find.text('case study child'), findsOneWidget);

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
            builder: (final context, final state) => CaseStudySupabaseAuthGate(
              isSupabaseInitialized: false,
              getCurrentUser: () => null,
              authStateChanges: authController.stream,
              fallbackPath: '/counter',
              supabaseAuthPath: '/supabase-auth',
              redirectReturnPath: '/case-study-demo',
              child: const Scaffold(body: Text('case study child')),
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

      expect(find.text('case study child'), findsOneWidget);
      expect(find.text('counter'), findsNothing);
      expect(find.text('supabase auth'), findsNothing);
    });
  });
}
