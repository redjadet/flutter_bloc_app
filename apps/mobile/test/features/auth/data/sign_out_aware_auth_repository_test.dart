import 'package:auth/auth.dart' hide AuthRepository;
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/features/auth/data/sign_out_aware_auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockCoordinator extends Mock implements SessionLifecycleCoordinator {}

void main() {
  group('SignOutAwareAuthRepository', () {
    late _MockAuthRepository delegate;
    late _MockCoordinator coordinator;
    late SignOutAwareAuthRepository repository;

    setUp(() {
      delegate = _MockAuthRepository();
      coordinator = _MockCoordinator();
      repository = SignOutAwareAuthRepository(
        delegate: delegate,
        coordinator: coordinator,
      );
    when(() => delegate.currentUser).thenReturn(null);
    when(() => coordinator.sessionReadyCurrentUser).thenReturn(null);
    when(
      () => coordinator.sessionReadyAuthStateChanges,
    ).thenAnswer((_) => const Stream<AuthUser?>.empty());
      when(() => delegate.signOut()).thenAnswer((_) async {});
      when(
        () =>
            coordinator.onSignOutCompleted(provider: AuthProviderKind.firebase),
      ).thenAnswer((_) async {});
    });

    test('authStateChanges uses coordinator session-ready stream', () {
      // ignore: unnecessary_statements
      repository.authStateChanges;
      verify(() => coordinator.sessionReadyAuthStateChanges).called(1);
      verifyNever(() => delegate.authStateChanges);
    });

    test('currentUser uses coordinator session-ready identity', () {
      const AuthUser readyUser = AuthUser(id: 'ready-user', isAnonymous: false);
      when(() => coordinator.sessionReadyCurrentUser).thenReturn(readyUser);

      expect(repository.currentUser, readyUser);
      verify(() => coordinator.sessionReadyCurrentUser).called(1);
      verifyNever(() => delegate.currentUser);
    });

    test('delegates signOut then notifies coordinator', () async {
      await repository.signOut();

      verifyInOrder([
        () => delegate.signOut(),
        () =>
            coordinator.onSignOutCompleted(provider: AuthProviderKind.firebase),
      ]);
    });
  });
}
