import 'dart:async';

import 'package:auth/auth.dart' hide AuthRepository;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/app/http/auth/auth_token_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockRemoteBackendAuthPort extends Mock
    implements RemoteBackendAuthPort {}

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  group('SessionLifecycleCoordinatorImpl', () {
    late SessionLifecycleCoordinatorImpl coordinator;
    late AuthTokenManager authTokenManager;
    late _MockFirebaseAuth firebaseAuth;
    late _MockUser user;
    late _MockIdTokenResult tokenResult;

    setUp(() {
      coordinator = SessionLifecycleCoordinatorImpl();
      firebaseAuth = _MockFirebaseAuth();
      user = _MockUser();
      tokenResult = _MockIdTokenResult();
      when(() => user.uid).thenReturn('user-1');
      when(() => tokenResult.token).thenReturn('cached-token');
      when(
        () => tokenResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      when(() => user.getIdTokenResult()).thenAnswer((_) async => tokenResult);
      when(() => firebaseAuth.currentUser).thenReturn(user);
      authTokenManager = AuthTokenManager(firebaseAuth: firebaseAuth);
      coordinator.bindAuthTokenManager(authTokenManager);
    });

    tearDown(() async {
      await getIt.reset();
      await coordinator.dispose();
    });

    Future<void> warmCache() async {
      await authTokenManager.getValidAuthToken(user);
      clearInteractions(user);
    }

    test('onSignOutCompleted clears auth token manager cache', () async {
      await warmCache();

      await coordinator.onSignOutCompleted(provider: AuthProviderKind.firebase);
      await authTokenManager.getValidAuthToken(user);

      verify(() => user.getIdTokenResult()).called(1);
    });

    test(
      'onSignOutCompleted clears bound token repository provider state',
      () async {
        final InMemoryTokenRepository tokenRepository =
            InMemoryTokenRepository();
        coordinator.bindTokenRepository(tokenRepository);
        tokenRepository.cacheSupabaseAccessToken('supabase-token');

        await coordinator.onSignOutCompleted(
          provider: AuthProviderKind.supabase,
        );

        expect(tokenRepository.getSupabaseAccessToken(), isNull);
      },
    );

    test(
      'attachAuthRepository skips cleanup on cold-start null emission',
      () async {
        final StreamController<AuthUser?> controller =
            StreamController<AuthUser?>.broadcast();
        final _MockAuthRepository repository = _MockAuthRepository();
        when(() => repository.currentUser).thenReturn(null);
        when(
          () => repository.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        coordinator.attachAuthRepository(repository);
        controller.add(null);

        await Future<void>.delayed(Duration.zero);

        verifyNever(() => user.getIdTokenResult());
        await controller.close();
      },
    );

    test(
      'attachAuthRepository runs cleanup when user transitions to signed out',
      () async {
        final StreamController<AuthUser?> controller =
            StreamController<AuthUser?>.broadcast();
        final _MockAuthRepository repository = _MockAuthRepository();
        const AuthUser signedInUser = AuthUser(id: 'u1', isAnonymous: false);
        when(() => repository.currentUser).thenReturn(signedInUser);
        when(
          () => repository.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        await warmCache();
        coordinator.attachAuthRepository(repository);
        controller.add(null);

        await Future<void>.delayed(Duration.zero);
        await authTokenManager.getValidAuthToken(user);

        verify(() => user.getIdTokenResult()).called(1);
        await controller.close();
      },
    );

    test(
      'attachAuthRepository clears local session data on A→B account switch',
      () async {
        final StreamController<AuthUser?> controller =
            StreamController<AuthUser?>.broadcast();
        final _MockAuthRepository repository = _MockAuthRepository();
        const AuthUser userA = AuthUser(id: 'user-a', isAnonymous: false);
        const AuthUser userB = AuthUser(id: 'user-b', isAnonymous: false);
        when(() => repository.currentUser).thenReturn(userA);
        when(
          () => repository.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        SessionLocalCleanupReason? seenReason;
        AuthProviderKind? seenProvider;
        coordinator.bindLocalSessionDataCleanup(({
          required final AuthProviderKind provider,
          required final SessionLocalCleanupReason reason,
        }) async {
          seenProvider = provider;
          seenReason = reason;
        });

        coordinator.attachAuthRepository(repository);
        controller.add(userB);
        await Future<void>.delayed(Duration.zero);

        expect(seenProvider, AuthProviderKind.firebase);
        expect(seenReason, SessionLocalCleanupReason.accountSwitch);
        await controller.close();
      },
    );

    test(
      'sessionReadyAuthStateChanges waits for A→B cleanup before publishing B',
      () async {
        final StreamController<AuthUser?> controller =
            StreamController<AuthUser?>.broadcast();
        final _MockAuthRepository repository = _MockAuthRepository();
        const AuthUser userA = AuthUser(id: 'user-a', isAnonymous: false);
        const AuthUser userB = AuthUser(id: 'user-b', isAnonymous: false);
        when(() => repository.currentUser).thenReturn(userA);
        when(
          () => repository.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        final Completer<void> cleanupStarted = Completer<void>();
        final Completer<void> releaseCleanup = Completer<void>();
        coordinator.bindLocalSessionDataCleanup(({
          required final AuthProviderKind provider,
          required final SessionLocalCleanupReason reason,
        }) async {
          cleanupStarted.complete();
          await releaseCleanup.future;
        });

        final List<AuthUser?> readyUsers = <AuthUser?>[];
        final StreamSubscription<AuthUser?> readySub = coordinator
            .sessionReadyAuthStateChanges
            .listen(readyUsers.add);

        coordinator.attachAuthRepository(repository);
        await Future<void>.delayed(Duration.zero);
        expect(readyUsers, <AuthUser?>[userA]);

        controller.add(userB);
        await cleanupStarted.future;
        await Future<void>.delayed(Duration.zero);

        expect(readyUsers, <AuthUser?>[userA]);

        releaseCleanup.complete();
        await Future<void>.delayed(Duration.zero);

        expect(readyUsers, <AuthUser?>[userA, userB]);
        await readySub.cancel();
        await controller.close();
      },
    );

    test('newer auth event supersedes in-flight A→B publish', () async {
      final StreamController<AuthUser?> controller =
          StreamController<AuthUser?>.broadcast();
      final _MockAuthRepository repository = _MockAuthRepository();
      const AuthUser userA = AuthUser(id: 'user-a', isAnonymous: false);
      const AuthUser userB = AuthUser(id: 'user-b', isAnonymous: false);
      when(() => repository.currentUser).thenReturn(userA);
      when(
        () => repository.authStateChanges,
      ).thenAnswer((_) => controller.stream);

      final Completer<void> cleanupStarted = Completer<void>();
      final Completer<void> releaseCleanup = Completer<void>();
      coordinator.bindLocalSessionDataCleanup(({
        required final AuthProviderKind provider,
        required final SessionLocalCleanupReason reason,
      }) async {
        if (reason == SessionLocalCleanupReason.accountSwitch) {
          cleanupStarted.complete();
          await releaseCleanup.future;
        }
      });

      final List<AuthUser?> readyUsers = <AuthUser?>[];
      final StreamSubscription<AuthUser?> readySub = coordinator
          .sessionReadyAuthStateChanges
          .listen(readyUsers.add);

      coordinator.attachAuthRepository(repository);
      await Future<void>.delayed(Duration.zero);
      readyUsers.clear();

      controller.add(userB);
      await cleanupStarted.future;
      controller.add(null);
      releaseCleanup.complete();
      await Future<void>.delayed(Duration.zero);

      expect(readyUsers, isNot(contains(userB)));
      expect(readyUsers.last, isNull);
      await readySub.cancel();
      await controller.close();
    });

    test(
      'account switch cleanup failure fails closed without publishing B',
      () async {
        final StreamController<AuthUser?> controller =
            StreamController<AuthUser?>.broadcast();
        final _MockAuthRepository repository = _MockAuthRepository();
        const AuthUser userA = AuthUser(id: 'user-a', isAnonymous: false);
        const AuthUser userB = AuthUser(id: 'user-b', isAnonymous: false);
        when(() => repository.currentUser).thenReturn(userA);
        when(
          () => repository.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        coordinator.bindLocalSessionDataCleanup(({
          required final AuthProviderKind provider,
          required final SessionLocalCleanupReason reason,
        }) async {
          throw StateError('cleanup boom');
        });

        final List<AuthUser?> readyUsers = <AuthUser?>[];
        final StreamSubscription<AuthUser?> readySub = coordinator
            .sessionReadyAuthStateChanges
            .listen(readyUsers.add);

        coordinator.attachAuthRepository(repository);
        await Future<void>.delayed(Duration.zero);
        readyUsers.clear();

        controller.add(userB);
        await Future<void>.delayed(Duration.zero);

        expect(readyUsers, <AuthUser?>[null]);
        await readySub.cancel();
        await controller.close();
      },
    );

    test(
      'onSignOutCompleted invokes bound local session data cleanup',
      () async {
        var cleanupCalls = 0;
        coordinator.bindLocalSessionDataCleanup(({
          required final AuthProviderKind provider,
          required final SessionLocalCleanupReason reason,
        }) async {
          cleanupCalls += 1;
          expect(provider, AuthProviderKind.firebase);
          expect(reason, SessionLocalCleanupReason.signOut);
        });

        await coordinator.onSignOutCompleted(
          provider: AuthProviderKind.firebase,
        );

        expect(cleanupCalls, 1);
      },
    );

    test('invalidateSession emits invalidation event', () async {
      final List<SessionInvalidationEvent> events =
          <SessionInvalidationEvent>[];
      final StreamSubscription<SessionInvalidationEvent> sub = coordinator
          .invalidationEvents
          .listen(events.add);

      await coordinator.invalidateSession(
        provider: AuthProviderKind.firebase,
        reason: SessionInvalidationReason.remoteRejected,
      );

      expect(events, hasLength(1));
      expect(events.single.provider, AuthProviderKind.firebase);
      expect(events.single.reason, SessionInvalidationReason.remoteRejected);
      await sub.cancel();
    });

    test(
      'invalidateSession for different providers runs concurrently',
      () async {
        final Completer<void> firebaseSignOutGate = Completer<void>();
        final _MockAuthRepository authRepository = _MockAuthRepository();
        final _MockRemoteBackendAuthPort remoteAuth =
            _MockRemoteBackendAuthPort();
        when(() => authRepository.signOut()).thenAnswer((_) async {
          await firebaseSignOutGate.future;
        });
        when(() => remoteAuth.signOut()).thenAnswer((_) async {});

        getIt.registerSingleton<AuthRepository>(authRepository);
        getIt.registerSingleton<RemoteBackendAuthPort>(remoteAuth);

        final List<SessionInvalidationEvent> events =
            <SessionInvalidationEvent>[];
        final StreamSubscription<SessionInvalidationEvent> sub = coordinator
            .invalidationEvents
            .listen(events.add);

        final Future<void> firebaseInvalidation = coordinator.invalidateSession(
          provider: AuthProviderKind.firebase,
          reason: SessionInvalidationReason.remoteRejected,
        );
        await Future<void>.delayed(Duration.zero);

        await coordinator.invalidateSession(
          provider: AuthProviderKind.supabase,
          reason: SessionInvalidationReason.supabaseSessionInvalid,
        );
        await Future<void>.delayed(Duration.zero);

        verify(() => remoteAuth.signOut()).called(1);
        expect(
          events.where(
            (final SessionInvalidationEvent e) =>
                e.provider == AuthProviderKind.supabase,
          ),
          hasLength(1),
        );

        firebaseSignOutGate.complete();
        await firebaseInvalidation;
        await Future<void>.delayed(Duration.zero);

        verify(() => authRepository.signOut()).called(1);

        expect(events, hasLength(2));
        expect(
          events.map((final SessionInvalidationEvent e) => e.provider).toSet(),
          <AuthProviderKind>{
            AuthProviderKind.firebase,
            AuthProviderKind.supabase,
          },
        );
        await sub.cancel();
      },
    );

    test('onSignOutCompleted is idempotent', () async {
      await coordinator.onSignOutCompleted(provider: AuthProviderKind.firebase);
      await coordinator.onSignOutCompleted(provider: AuthProviderKind.firebase);
    });
  });
}
