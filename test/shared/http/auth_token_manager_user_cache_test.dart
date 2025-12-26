import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

void main() {
  group('AuthTokenManager User-Specific Caching', () {
    late AuthTokenManager tokenManager;
    late _MockFirebaseAuth mockFirebaseAuth;
    late _MockUser user1;
    late _MockUser user2;
    late _MockIdTokenResult mockTokenResult;

    setUp(() {
      mockFirebaseAuth = _MockFirebaseAuth();
      tokenManager = AuthTokenManager(firebaseAuth: mockFirebaseAuth);
      user1 = _MockUser();
      user2 = _MockUser();
      mockTokenResult = _MockIdTokenResult();

      // Mock user UIDs
      when(() => user1.uid).thenReturn('user1-id');
      when(() => user2.uid).thenReturn('user2-id');

      // Mock token result
      when(() => mockTokenResult.token).thenReturn('mock-token');
      when(
        () => mockTokenResult.expirationTime,
      ).thenReturn(DateTime.now().add(const Duration(hours: 1)));
    });

    test('caches token per user correctly', () async {
      // Mock getIdTokenResult for user1
      when(
        () => user1.getIdTokenResult(),
      ).thenAnswer((_) async => mockTokenResult);

      // First call for user1 should fetch and cache token
      final token1 = await tokenManager.getValidAuthToken(user1);
      expect(token1, equals('mock-token'));

      // Second call for user1 should return cached token
      final cachedToken1 = await tokenManager.getValidAuthToken(user1);
      expect(cachedToken1, equals('mock-token'));

      // Verify getIdTokenResult was called only once for user1
      verify(() => user1.getIdTokenResult()).called(1);
    });

    test('does not reuse cached token for different user', () async {
      // Mock getIdTokenResult for both users
      when(
        () => user1.getIdTokenResult(),
      ).thenAnswer((_) async => mockTokenResult);
      when(
        () => user2.getIdTokenResult(),
      ).thenAnswer((_) async => mockTokenResult);

      // Get token for user1
      final token1 = await tokenManager.getValidAuthToken(user1);
      expect(token1, equals('mock-token'));

      // Get token for user2 - should fetch new token, not reuse user1's cached token
      final token2 = await tokenManager.getValidAuthToken(user2);
      expect(token2, equals('mock-token'));

      // Verify both users had their tokens fetched
      verify(() => user1.getIdTokenResult()).called(1);
      verify(() => user2.getIdTokenResult()).called(1);
    });

    test('clears cache when switching users', () async {
      // Mock getIdTokenResult for both users
      when(
        () => user1.getIdTokenResult(),
      ).thenAnswer((_) async => mockTokenResult);
      when(
        () => user2.getIdTokenResult(),
      ).thenAnswer((_) async => mockTokenResult);

      // Get token for user1
      await tokenManager.getValidAuthToken(user1);

      // Clear cache explicitly
      tokenManager.clearCache();

      // Get token for user2 - should fetch new token since cache was cleared
      await tokenManager.getValidAuthToken(user2);

      // Verify both users had their tokens fetched
      verify(() => user1.getIdTokenResult()).called(1);
      verify(() => user2.getIdTokenResult()).called(1);
    });

    test('refreshTokenAndGet clears user-specific cache', () async {
      // Mock getIdTokenResult for user1
      when(
        () => user1.getIdTokenResult(),
      ).thenAnswer((_) async => mockTokenResult);
      when(
        () => user1.getIdToken(true),
      ).thenAnswer((_) async => 'refreshed-token');

      // Get initial token
      await tokenManager.getValidAuthToken(user1);

      // Force refresh - should clear cache including user ID
      await tokenManager.refreshTokenAndGet(user1);

      // Get token again - should fetch since cache was cleared
      await tokenManager.getValidAuthToken(user1);

      // Verify getIdTokenResult was called twice (once for initial, once after refresh)
      verify(() => user1.getIdTokenResult()).called(2);
    });
  });
}
