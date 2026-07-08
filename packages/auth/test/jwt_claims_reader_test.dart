import 'package:auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tryReadJwtClaims', () {
    test('parses iss sub and exp from valid jwt payload', () {
      final String token =
          'eyJhbGciOiJIUzI1NiJ9.'
          'eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tIiwic3ViIjoidXNlci0xIiwiZXhwIjoxNzAwMDAwMDAwfQ.'
          'signature';

      final JwtClaims? claims = tryReadJwtClaims(token);

      expect(claims?.iss, 'https://example.com');
      expect(claims?.sub, 'user-1');
      expect(claims?.exp, 1700000000);
    });

    test('returns null for malformed token', () {
      expect(tryReadJwtClaims('not-a-jwt'), isNull);
      expect(tryReadJwtClaims(null), isNull);
    });
  });
}
