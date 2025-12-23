import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  group('AuthTokenManager', () {
    test('caches token when still valid', () async {
      final _MockUser user = _MockUser();
      final _MockIdTokenResult tokenResult = _MockIdTokenResult();
      final DateTime expiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );

      when(() => tokenResult.token).thenReturn('token');
      when(() => tokenResult.expirationTime).thenReturn(expiry);
      when(
        () => user.getIdTokenResult(),
      ).thenAnswer((final invocation) async => tokenResult);

      final AuthTokenManager manager = AuthTokenManager();
      final String? first = await manager.getValidAuthToken(user);
      final String? second = await manager.getValidAuthToken(user);

      expect(first, 'token');
      expect(second, 'token');
      verify(() => user.getIdTokenResult()).called(1);
    });

    test('refreshToken returns false when no user', () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      when(() => auth.currentUser).thenReturn(null);

      final AuthTokenManager manager = AuthTokenManager(firebaseAuth: auth);
      final bool result = await manager.refreshToken();

      expect(result, isFalse);
    });

    test('refreshToken refreshes token and clears cache', () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockUser user = _MockUser();
      when(() => auth.currentUser).thenReturn(user);
      when(
        () => user.getIdToken(true),
      ).thenAnswer((final invocation) async => 'token');

      final AuthTokenManager manager = AuthTokenManager(firebaseAuth: auth);
      final bool result = await manager.refreshToken();

      expect(result, isTrue);
      verify(() => user.getIdToken(true)).called(1);
    });

    test('refreshTokenAndGet forces refresh then returns token', () async {
      final _MockUser user = _MockUser();
      final _MockIdTokenResult tokenResult = _MockIdTokenResult();
      final DateTime expiry = DateTime.now().toUtc().add(
        const Duration(hours: 1),
      );

      when(
        () => user.getIdToken(true),
      ).thenAnswer((final invocation) async => 'token');
      when(() => tokenResult.token).thenReturn('token');
      when(() => tokenResult.expirationTime).thenReturn(expiry);
      when(
        () => user.getIdTokenResult(),
      ).thenAnswer((final invocation) async => tokenResult);

      final AuthTokenManager manager = AuthTokenManager();
      final String? token = await manager.refreshTokenAndGet(user);

      expect(token, 'token');
      verify(() => user.getIdToken(true)).called(1);
      verify(() => user.getIdTokenResult()).called(1);
    });
  });
}
