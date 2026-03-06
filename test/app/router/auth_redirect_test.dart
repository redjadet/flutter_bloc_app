import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/router/auth_redirect.dart';
import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  group('createAuthRedirect', () {
    late MockAuthRepository mockAuth;
    late MockGoRouterState mockState;
    late BuildContext testContext;

    setUp(() {
      mockAuth = MockAuthRepository();
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
      const user = AuthUser(id: '1', isAnonymous: false);
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.authPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, equals(AppRoutes.counterPath));
    });

    test('allows anonymous user to stay on auth page to upgrade', () {
      const anonymousUser = AuthUser(id: '1', isAnonymous: true);
      when(() => mockAuth.currentUser).thenReturn(anonymousUser);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.authPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('allows authenticated user to navigate to counter', () {
      const user = AuthUser(id: '1', isAnonymous: false);
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn(AppRoutes.counterPath);

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('allows authenticated user to navigate to deep links', () {
      const user = AuthUser(id: '1', isAnonymous: false);
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn('/chat');

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });

    test('allows navigation to root path for authenticated users', () {
      const user = AuthUser(id: '1', isAnonymous: false);
      when(() => mockAuth.currentUser).thenReturn(user);
      when(() => mockState.matchedLocation).thenReturn('/');

      final redirect = createAuthRedirect(mockAuth);
      final result = redirect(testContext, mockState);

      expect(result, isNull);
    });
  });
}

class MockBuildContext extends Mock implements BuildContext {}
