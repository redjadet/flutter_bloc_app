import 'dart:async';

import 'package:flutter_bloc_app/app/presentation/cubit/app_auth_cubit.dart';
import 'package:flutter_bloc_app/app/presentation/cubit/app_auth_state.dart';
import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/auth/session_invalidation_reason.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
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
  });
}
