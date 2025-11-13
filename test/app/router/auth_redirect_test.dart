import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/auth_redirect.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  bool get isAnonymous => false;
}

class MockAnonymousUser extends Mock implements User {
  @override
  bool get isAnonymous => true;
}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  group('createAuthRedirect', () {
    late MockFirebaseAuth mockAuth;
    late MockGoRouterState mockState;
    late BuildContext testContext;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockState = MockGoRouterState();
      testContext = MockBuildContext();
    });

    test('redirects unauthenticated user to auth page', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.counterPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, equals(AppRoutes.authPath));
    });

    test('allows unauthenticated user to stay on auth page', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.authPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('allows deep link navigation for unauthenticated users', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockState.matchedLocation).thenReturn('/profile');

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('redirects authenticated user away from auth page', () {
      final user = MockUser();
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.authPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, equals(AppRoutes.counterPath));
    });

    test('allows anonymous user to stay on auth page to upgrade', () {
      final anonymousUser = MockAnonymousUser();
      when(() => mockAuth.currentUser).thenReturn(anonymousUser);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.authPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('allows authenticated user to navigate to counter', () {
      final user = MockUser();
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.counterPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('allows authenticated user to navigate to deep links', () {
      final user = MockUser();
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn('/chat');

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('allows navigation to root path for authenticated users', () {
      final user = MockUser();
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn('/');

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
