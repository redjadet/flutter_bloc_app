import 'dart:convert';

/// Canonical `sha256/<base64>` pin helpers.
abstract final class CertificatePinFormatter {
  static const String prefix = 'sha256/';

  static bool isValidFormat(final String pin) {
    final String canonical = canonicalize(pin);
    if (!canonical.startsWith(prefix)) {
      return false;
    }
    final String encoded = canonical.substring(prefix.length);
    if (encoded.isEmpty) {
      return false;
    }
    try {
      final List<int> bytes = base64Decode(encoded);
      return bytes.length == 32;
    } on FormatException {
      return false;
    }
  }

  static String canonicalize(final String pin) {
    final String trimmed = pin.trim();
    if (trimmed.toLowerCase().startsWith(prefix)) {
      final String body = trimmed.substring(prefix.length).trim();
      return '$prefix$body';
    }
    return trimmed;
  }

  static String fromSha256Bytes(final List<int> digest) {
    if (digest.length != 32) {
      throw ArgumentError.value(digest.length, 'digest.length', 'must be 32');
    }
    return '$prefix${base64Encode(digest)}';
  }
}
