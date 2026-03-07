import 'dart:async';

import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stub implementation so we can register it in GetIt and resolve from "other" code.
class _StubSupabaseAuthRepository implements SupabaseAuthRepository {
  _StubSupabaseAuthRepository({
    required this.isConfigured,
    this.user,
    required this.authStateChanges,
  });

  @override
  final bool isConfigured;

  @override
  AuthUser? get currentUser => user;

  final AuthUser? user;

  @override
  final Stream<AuthUser?> authStateChanges;

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) async {}

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {}

  @override
  Future<void> signOut() async {}
}

/// Verifies that code outside the Supabase auth feature can resolve
/// [SupabaseAuthRepository] from DI and access the current user and auth stream.
void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test(
    'other code can resolve SupabaseAuthRepository and read currentUser',
    () async {
      const AuthUser signedInUser = AuthUser(
        id: 'supabase-user-1',
        isAnonymous: false,
        email: 'other@example.com',
        displayName: 'Other User',
      );

      final streamController = StreamController<AuthUser?>.broadcast();
      final repo = _StubSupabaseAuthRepository(
        isConfigured: true,
        user: signedInUser,
        authStateChanges: streamController.stream,
      );

      getIt.registerSingleton<SupabaseAuthRepository>(repo);

      // Simulate "other" code resolving the repository (e.g. another feature or service).
      final resolved = getIt<SupabaseAuthRepository>();
      expect(identical(resolved, repo), isTrue);

      expect(resolved.currentUser, signedInUser);
      expect(resolved.isConfigured, isTrue);

      final List<AuthUser?> emitted = [];
      final sub = resolved.authStateChanges.listen(emitted.add);
      streamController.add(signedInUser);
      streamController.add(null);
      await streamController.close();
      await sub.cancel();

      expect(emitted, [signedInUser, null]);
    },
  );

  test(
    'other code can resolve SupabaseAuthRepository when not signed in',
    () async {
      final streamController = StreamController<AuthUser?>.broadcast();
      final repo = _StubSupabaseAuthRepository(
        isConfigured: true,
        user: null,
        authStateChanges: streamController.stream,
      );

      getIt.registerSingleton<SupabaseAuthRepository>(repo);

      final resolved = getIt<SupabaseAuthRepository>();
      expect(resolved.currentUser, isNull);
      expect(resolved.isConfigured, isTrue);

      await streamController.close();
    },
  );
}
