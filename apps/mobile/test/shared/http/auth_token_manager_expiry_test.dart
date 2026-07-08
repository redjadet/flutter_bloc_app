import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/http/auth/auth_token_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUser extends Mock implements User {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  group('AuthTokenManager expiry buffer', () {
    late _MockUser user;
    late _MockFirebaseAuth firebaseAuth;
    late AuthTokenManager manager;

    setUp(() {
      user = _MockUser();
      firebaseAuth = _MockFirebaseAuth();
      when(() => user.uid).thenReturn('user-1');
      when(() => firebaseAuth.currentUser).thenReturn(user);
      manager = AuthTokenManager(firebaseAuth: firebaseAuth);
    });

    test('uses cache inside five-minute pre-expiry buffer', () async {
      final _MockIdTokenResult tokenResult = _MockIdTokenResult();
      when(() => tokenResult.token).thenReturn('token-a');
      when(
        () => tokenResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(minutes: 10)));
      when(() => user.getIdTokenResult()).thenAnswer((_) async => tokenResult);

      expect(await manager.getValidAuthToken(user), 'token-a');
      expect(await manager.getValidAuthToken(user), 'token-a');

      verify(() => user.getIdTokenResult()).called(1);
    });

    test('refetches when token is inside expiry buffer', () async {
      final _MockIdTokenResult staleResult = _MockIdTokenResult();
      final _MockIdTokenResult freshResult = _MockIdTokenResult();
      when(() => staleResult.token).thenReturn('token-stale');
      when(
        () => staleResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(minutes: 2)));
      when(() => freshResult.token).thenReturn('token-fresh');
      when(
        () => freshResult.expirationTime,
      ).thenReturn(DateTime.now().toUtc().add(const Duration(hours: 1)));
      var calls = 0;
      when(() => user.getIdTokenResult()).thenAnswer((_) async {
        calls += 1;
        return calls == 1 ? staleResult : freshResult;
      });

      expect(await manager.getValidAuthToken(user), 'token-stale');
      expect(await manager.getValidAuthToken(user), 'token-fresh');

      verify(() => user.getIdTokenResult()).called(2);
    });
  });
}
