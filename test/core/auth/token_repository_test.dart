import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/core/auth/auth_provider_kind.dart';
import 'package:flutter_bloc_app/core/auth/token_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse;

class _MockUser extends Mock implements User {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  group('InMemoryTokenRepository', () {
    test('returns hydrated Firebase token from memory while valid', () async {
      final _MockUser user = _MockUser();
      final _MockIdTokenResult tokenResult = _MockIdTokenResult();

      when(() => user.uid).thenReturn('firebase-user');
      when(() => tokenResult.token).thenReturn('firebase-token');
      when(
        () => tokenResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      when(
        () => user.getIdTokenResult(false),
      ).thenAnswer((_) async => tokenResult);

      final InMemoryTokenRepository repository = InMemoryTokenRepository();

      await repository.hydrateFirebaseSession(user);
      final String? token = await repository.getFirebaseAccessToken(user);

      expect(token, 'firebase-token');
      verify(() => user.getIdTokenResult(false)).called(1);
    });

    test('force-refreshes Firebase token and updates memory', () async {
      final _MockUser user = _MockUser();
      final _MockIdTokenResult tokenResult = _MockIdTokenResult();

      when(() => user.uid).thenReturn('firebase-user');
      when(() => user.getIdToken(true)).thenAnswer((_) async => 'forced');
      when(() => tokenResult.token).thenReturn('fresh-firebase-token');
      when(
        () => tokenResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      when(
        () => user.getIdTokenResult(false),
      ).thenAnswer((_) async => tokenResult);

      final InMemoryTokenRepository repository = InMemoryTokenRepository();

      final String? refreshed = await repository.refreshFirebaseAccessToken(
        user,
      );
      final String? cached = await repository.getFirebaseAccessToken(user);

      expect(refreshed, 'fresh-firebase-token');
      expect(cached, 'fresh-firebase-token');
      verify(() => user.getIdToken(true)).called(1);
      verify(() => user.getIdTokenResult(false)).called(1);
    });

    test('reads Supabase token from memory until refresh updates it', () async {
      final InMemoryTokenRepository repository = InMemoryTokenRepository();
      var persistentReads = 0;
      var refreshCalls = 0;

      repository.cacheSupabaseAccessToken('startup-token');

      expect(repository.getSupabaseAccessToken(), 'startup-token');
      expect(persistentReads, 0);

      final String? refreshed = await repository.refreshSupabaseAccessToken(
        refreshSession: () async {
          refreshCalls += 1;
          return AuthResponse();
        },
        readPersistentAccessToken: () {
          persistentReads += 1;
          return 'refreshed-token';
        },
      );

      expect(refreshed, 'refreshed-token');
      expect(repository.getSupabaseAccessToken(), 'refreshed-token');
      expect(refreshCalls, 1);
      expect(persistentReads, 1);
    });

    test('logout clears only requested provider state', () async {
      final _MockUser user = _MockUser();
      final _MockIdTokenResult tokenResult = _MockIdTokenResult();

      when(() => user.uid).thenReturn('firebase-user');
      when(() => tokenResult.token).thenReturn('firebase-token');
      when(
        () => tokenResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      when(
        () => user.getIdTokenResult(false),
      ).thenAnswer((_) async => tokenResult);

      final InMemoryTokenRepository repository = InMemoryTokenRepository();
      await repository.hydrateFirebaseSession(user);
      repository.cacheSupabaseAccessToken('supabase-token');

      repository.clearProvider(AuthProviderKind.supabase);

      expect(repository.getSupabaseAccessToken(), isNull);
      expect(await repository.getFirebaseAccessToken(user), 'firebase-token');
    });
  });
}
