import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_bloc_app/features/auth/data/firebase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAuthRepository', () {
    test('currentUser maps signed-in Firebase user', () {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'uid-1',
          email: 'user@example.com',
          displayName: ' Test User ',
          isAnonymous: false,
        ),
      );
      final repo = FirebaseAuthRepository(firebaseAuth: auth);

      final user = repo.currentUser;

      expect(user, isNotNull);
      expect(user!.id, 'uid-1');
      expect(user.email, 'user@example.com');
      expect(user.displayName, 'Test User');
      expect(user.isAnonymous, isFalse);
    });

    test('currentUser is null when signed out', () {
      final auth = MockFirebaseAuth();
      final repo = FirebaseAuthRepository(firebaseAuth: auth);

      expect(repo.currentUser, isNull);
    });

    test('authStateChanges emits mapped user', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'stream-uid', isAnonymous: true),
      );
      final repo = FirebaseAuthRepository(firebaseAuth: auth);

      final user = await repo.authStateChanges.first;

      expect(user?.id, 'stream-uid');
      expect(user?.isAnonymous, isTrue);
    });

    test('signInAnonymously signs user in', () async {
      final auth = MockFirebaseAuth();
      final repo = FirebaseAuthRepository(firebaseAuth: auth);

      await repo.signInAnonymously();

      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.isAnonymous, isTrue);
    });

    test('signOut clears current user', () async {
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid-signout'),
      );
      final repo = FirebaseAuthRepository(firebaseAuth: auth);

      await repo.signOut();

      expect(repo.currentUser, isNull);
    });
  });
}
