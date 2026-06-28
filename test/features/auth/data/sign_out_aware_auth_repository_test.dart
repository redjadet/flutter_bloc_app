import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
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
      when(
        () => delegate.authStateChanges,
      ).thenAnswer((_) => const Stream<AuthUser?>.empty());
      when(() => delegate.signOut()).thenAnswer((_) async {});
      when(
        () =>
            coordinator.onSignOutCompleted(provider: AuthProviderKind.firebase),
      ).thenAnswer((_) async {});
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
