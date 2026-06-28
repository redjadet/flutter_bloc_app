import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/shared/http/auth_token_refresh_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isAuthClassifiedFirebaseRefreshFailure', () {
    test('returns true for auth-classified Firebase codes', () {
      for (final String code in authClassifiedFirebaseRefreshFailureCodes) {
        expect(
          isAuthClassifiedFirebaseRefreshFailure(
            FirebaseAuthException(code: code, message: 'test'),
          ),
          isTrue,
          reason: code,
        );
      }
    });

    test('returns false for network failures', () {
      expect(
        isAuthClassifiedFirebaseRefreshFailure(
          FirebaseAuthException(
            code: 'network-request-failed',
            message: 'network',
          ),
        ),
        isFalse,
      );
    });

    test('returns false for non-Firebase errors', () {
      expect(
        isAuthClassifiedFirebaseRefreshFailure(Exception('other')),
        isFalse,
      );
    });
  });
}
