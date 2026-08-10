import 'dart:async';

import 'package:auth/auth.dart' hide AuthRepository;
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/presentation/cubit/app_auth_cubit.dart';
import 'package:flutter_bloc_app/app/presentation/cubit/app_auth_state.dart';
import 'package:flutter_bloc_app/features/auth/data/sign_out_aware_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AppAuthCubit', () {
    late _MockAuthRepository authRepository;
    late SessionLifecycleCoordinatorImpl sessionCoordinator;
    late StreamController<AuthUser?> authController;
    late AppAuthCubit cubit;

    setUp(() {
      authRepository = _MockAuthRepository();
      sessionCoordinator = SessionLifecycleCoordinatorImpl();
      authController = StreamController<AuthUser?>.broadcast();
      when(
        () => authRepository.authStateChanges,
      ).thenAnswer((_) => authController.stream);
      when(() => authRepository.currentUser).thenReturn(null);
      cubit = AppAuthCubit(
        authRepository: authRepository,
        sessionCoordinator: sessionCoordinator,
      );
    });

    tearDown(() async {
      await authController.close();
      await cubit.close();
      await sessionCoordinator.dispose();
    });

    test('sessionExpired is sticky until acknowledgeSessionExpired', () async {
      await cubit.start();

      const AuthUser user = AuthUser(id: 'u1', isAnonymous: false);
      authController.add(user);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, AppAuthState.authenticated(user));

      await sessionCoordinator.invalidateSession(
        provider: AuthProviderKind.firebase,
        reason: SessionInvalidationReason.remoteRejected,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        cubit.state,
        const AppAuthState.sessionExpired(
          SessionInvalidationReason.remoteRejected,
        ),
      );

      authController.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(
        cubit.state,
        const AppAuthState.sessionExpired(
          SessionInvalidationReason.remoteRejected,
        ),
      );

      cubit.acknowledgeSessionExpired();
      expect(cubit.state, const AppAuthState.unauthenticated());
    });

    test('sign-in clears sessionExpired', () async {
      await cubit.start();
      await sessionCoordinator.invalidateSession(
        provider: AuthProviderKind.firebase,
        reason: SessionInvalidationReason.accessTokenRefreshFailed,
      );
      await Future<void>.delayed(Duration.zero);

      const AuthUser user = AuthUser(id: 'u2', isAnonymous: false);
      when(() => authRepository.currentUser).thenReturn(user);
      authController.add(user);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, AppAuthState.authenticated(user));
    });

    test(
      'acknowledgeSessionExpired does not re-authenticate before sign-out completes',
      () async {
        const AuthUser user = AuthUser(id: 'u1', isAnonymous: false);
        when(() => authRepository.currentUser).thenReturn(user);

        await cubit.start();
        authController.add(user);
        await Future<void>.delayed(Duration.zero);

        await sessionCoordinator.invalidateSession(
          provider: AuthProviderKind.firebase,
          reason: SessionInvalidationReason.remoteRejected,
        );
        await Future<void>.delayed(Duration.zero);

        cubit.acknowledgeSessionExpired();

        expect(cubit.state, const AppAuthState.unauthenticated());
      },
    );
  });

  group('AppAuthCubit + SignOutAware session-ready', () {
    late _MockAuthRepository rawRepository;
    late SessionLifecycleCoordinatorImpl sessionCoordinator;
    late StreamController<AuthUser?> rawAuthController;
    late SignOutAwareAuthRepository gatedRepository;
    late AppAuthCubit cubit;

    setUp(() {
      rawRepository = _MockAuthRepository();
      sessionCoordinator = SessionLifecycleCoordinatorImpl();
      rawAuthController = StreamController<AuthUser?>.broadcast();
      when(
        () => rawRepository.authStateChanges,
      ).thenAnswer((_) => rawAuthController.stream);
      when(() => rawRepository.currentUser).thenReturn(null);
      gatedRepository = SignOutAwareAuthRepository(
        delegate: rawRepository,
        coordinator: sessionCoordinator,
      );
      cubit = AppAuthCubit(
        authRepository: gatedRepository,
        sessionCoordinator: sessionCoordinator,
      );
    });

    tearDown(() async {
      await cubit.close();
      await sessionCoordinator.dispose();
      await rawAuthController.close();
    });

    test(
      'does not emit account B until session-ready cleanup finishes',
      () async {
        const AuthUser userA = AuthUser(id: 'user-a', isAnonymous: false);
        const AuthUser userB = AuthUser(id: 'user-b', isAnonymous: false);
        when(() => rawRepository.currentUser).thenReturn(userA);

        final Completer<void> cleanupStarted = Completer<void>();
        final Completer<void> releaseCleanup = Completer<void>();
        sessionCoordinator.bindLocalSessionDataCleanup(({
          required final AuthProviderKind provider,
          required final SessionLocalCleanupReason reason,
        }) async {
          cleanupStarted.complete();
          await releaseCleanup.future;
        });

        // Attach undecorated repo (production DI rule) so cleanup can observe
        // raw A→B hops without session-ready deadlock.
        sessionCoordinator.attachAuthRepository(rawRepository);
        await cubit.start();
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state, AppAuthState.authenticated(userA));

        when(() => rawRepository.currentUser).thenReturn(userB);
        rawAuthController.add(userB);
        await cleanupStarted.future;
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, AppAuthState.authenticated(userA));

        releaseCleanup.complete();
        await Future<void>.delayed(Duration.zero);

        expect(cubit.state, AppAuthState.authenticated(userB));
      },
    );
  });
}
