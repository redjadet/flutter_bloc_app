import 'package:test/test.dart';
import 'package:utilities/utilities.dart';

void main() {
  group('appErrorFromHttpStatus', () {
    test('maps auth status codes', () {
      final AppError unauthorized = appErrorFromHttpStatus(
        401,
        message: 'Unauthorized',
      );
      expect(unauthorized, isA<AuthError>());
      expect((unauthorized as AuthError).kind, AuthErrorKind.unauthorized);

      final AppError forbidden = appErrorFromHttpStatus(
        403,
        message: 'Forbidden',
      );
      expect(forbidden, isA<AuthError>());
      expect((forbidden as AuthError).kind, AuthErrorKind.forbidden);
    });

    test('maps network status codes', () {
      final AppError timeout = appErrorFromHttpStatus(408, message: 'Timeout');
      expect(timeout, isA<NetworkError>());
      expect((timeout as NetworkError).kind, NetworkErrorKind.timeout);
      expect(timeout.isRetryable, isTrue);

      final AppError rateLimited = appErrorFromHttpStatus(
        429,
        message: 'Too many',
      );
      expect(rateLimited, isA<NetworkError>());
      expect((rateLimited as NetworkError).kind, NetworkErrorKind.rateLimited);
      expect(rateLimited.isRetryable, isTrue);

      final AppError unavailable = appErrorFromHttpStatus(
        503,
        message: 'Unavailable',
      );
      expect(unavailable, isA<NetworkError>());
      expect(
        (unavailable as NetworkError).kind,
        NetworkErrorKind.serviceUnavailable,
      );
      expect(unavailable.isRetryable, isTrue);

      final AppError server = appErrorFromHttpStatus(500, message: 'Server');
      expect((server as NetworkError).kind, NetworkErrorKind.server);
      expect(server.isRetryable, isTrue);

      final AppError badGateway = appErrorFromHttpStatus(
        502,
        message: 'Bad gateway',
      );
      expect((badGateway as NetworkError).kind, NetworkErrorKind.server);
      expect(badGateway.isRetryable, isTrue);

      final AppError client = appErrorFromHttpStatus(404, message: 'Missing');
      expect((client as NetworkError).kind, NetworkErrorKind.client);
      expect(client.isRetryable, isFalse);

      final AppError belowClientRange = appErrorFromHttpStatus(
        399,
        message: 'Redirect',
      );
      expect((belowClientRange as NetworkError).kind, NetworkErrorKind.unknown);
      expect(belowClientRange.isRetryable, isFalse);
    });
  });
}
