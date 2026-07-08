import 'dart:convert';

/// Decode-only JWT claims for UI/diagnostics. Never use for authorization.
class JwtClaims {
  const JwtClaims({this.sub, this.exp, this.iat, this.iss, this.aud, this.nbf});

  final String? sub;
  final int? exp;
  final int? iat;
  final String? iss;
  final String? aud;
  final int? nbf;
}

/// Parses JWT payload claims without signature verification.
JwtClaims? tryReadJwtClaims(final String? token) {
  if (token == null || token.isEmpty) {
    return null;
  }
  final List<String> parts = token.split('.');
  if (parts.length < 2) {
    return null;
  }
  try {
    final String normalized = base64Url.normalize(parts[1]);
    final String payload = utf8.decode(base64Url.decode(normalized));
    // check-ignore: small payload (<8KB) — JWT claim segment only
    final dynamic decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return JwtClaims(
      sub: _stringClaim(decoded['sub']),
      exp: _intClaim(decoded['exp']),
      iat: _intClaim(decoded['iat']),
      iss: _stringClaim(decoded['iss']),
      aud: _stringClaim(decoded['aud']),
      nbf: _intClaim(decoded['nbf']),
    );
  } on FormatException {
    return null;
  } on Exception {
    return null;
  }
}

String? _stringClaim(final Object? value) {
  return value is String ? value : null;
}

int? _intClaim(final Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}
