import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_bloc_app/shared/firebase/run_with_auth_user.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('runWithAuthUser', () {
    test('returns fallback when action throws FlutterFire TypeError', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );

      final int result = await AppLogger.silenceAsync(() {
        return runWithAuthUser<int>(
          auth: auth,
          logContext: 'runWithAuthUserTest',
          action: (_) async {
            final dynamic details = 'permission-denied';
            details as Map<dynamic, dynamic>;
            return 1;
          },
          onFailureFallback: () async => 42,
        );
      });

      expect(result, 42);
    });

    test('rethrows TypeError when no fallback is provided', () async {
      final MockFirebaseAuth auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user-123'),
      );

      await expectLater(
        AppLogger.silenceAsync(() {
          return runWithAuthUser<int>(
            auth: auth,
            logContext: 'runWithAuthUserTest',
            action: (_) async {
              final dynamic details = 'permission-denied';
              details as Map<dynamic, dynamic>;
              return 1;
            },
          );
        }),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
