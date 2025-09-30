import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_app/features/counter/data/realtime_database_counter_repository.dart';

void main() {
  group('waitForAuthUser', () {
    test('returns current user immediately when already signed in', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth();
      final UserCredential credential = await auth.signInAnonymously();

      final User user = await waitForAuthUser(auth);

      expect(user.uid, credential.user?.uid);
    });

    test('awaits authStateChanges when no current user yet', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth();

      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: 20),
          () => auth.signInAnonymously(),
        ),
      );

      final User user = await waitForAuthUser(
        auth,
        timeout: const Duration(seconds: 1),
      );

      expect(user.isAnonymous, isTrue);
    });

    test(
      'throws FirebaseAuthException when timeout elapses without user',
      () async {
        final MockFirebaseAuth auth = MockFirebaseAuth();

        expect(
          () =>
              waitForAuthUser(auth, timeout: const Duration(milliseconds: 50)),
          throwsA(
            isA<FirebaseAuthException>().having(
              (error) => error.code,
              'code',
              'no-current-user',
            ),
          ),
        );
      },
    );
  });
}
