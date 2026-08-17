/// Synchronous, side-effect-free sanitizers for application logs and crash
/// reports. Redact before any sink (console, observer, Crashlytics).
abstract final class LogRedaction {
  static const String redacted = '[REDACTED]';
  static const String invalidUri = '[INVALID_URI]';
  static const String unsafe = '[UNSAFE]';
  static const String truncationMarker = '…[truncated]';
  static const int maxMessageLength = 1024;

  static const Set<String> _secretKeyNormalized = {
    'password',
    'token',
    'accesstoken',
    'refreshtoken',
    'idtoken',
    'authorization',
    'cookie',
    'apikey',
    'sessionid',
    'secret',
    'bearer',
  };

  static final RegExp _controlChars = RegExp(r'[\x00-\x1f\x7f]+');
  static final RegExp _whitespaceCollapse = RegExp(r'\s+');
  static final RegExp _bearer = RegExp(
    r'Bearer\s+[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );
  static final RegExp _jwtLike = RegExp(
    r'\b[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b',
  );
  static final RegExp _secretAssignment = RegExp(
    r'\b(password|token|access[_-]?token|refresh[_-]?token|id[_-]?token|'
    r'authorization|cookie|api[_-]?key|session[_-]?id|secret|bearer)\s*[=:]\s*'
    r'([^\s&,;]+)',
    caseSensitive: false,
  );

  /// Normalize key for denylist: strip `_`/`-`, lowercase.
  static String normalizeKey(String key) =>
      key.replaceAll(RegExp(r'[_-]'), '').toLowerCase();

  static bool isSecretKey(String key) =>
      _secretKeyNormalized.contains(normalizeKey(key));

  /// Collapse CR/LF/control chars, scrub secret patterns, truncate.
  static String sanitizeMessage(String message) {
    var out = message.replaceAll(_controlChars, ' ');
    out = out.replaceAll(_whitespaceCollapse, ' ').trim();
    out = scrubSecretPatterns(out);
    if (out.length <= maxMessageLength) {
      return out;
    }
    final keep = maxMessageLength - truncationMarker.length;
    return '${out.substring(0, keep)}$truncationMarker';
  }

  /// Preserve scheme/host/port/path; redact query and fragment values.
  static Uri sanitizeUri(Uri uri) {
    final query = <String, String>{};
    for (final entry in uri.queryParameters.entries) {
      query[entry.key] = redacted;
    }
    final hasFragment = uri.fragment.isNotEmpty;
    return uri.replace(
      queryParameters: query.isEmpty ? null : query,
      fragment: hasFragment ? redacted : null,
    );
  }

  /// Log-safe URI string that keeps [redacted] literal (not percent-encoded).
  static String uriForLog(Uri uri) {
    final safe = sanitizeUri(uri);
    final buffer = StringBuffer()
      ..write(safe.scheme)
      ..write('://')
      ..write(safe.host);
    if (safe.hasPort &&
        !((safe.scheme == 'https' && safe.port == 443) ||
            (safe.scheme == 'http' && safe.port == 80))) {
      buffer.write(':');
      buffer.write(safe.port);
    }
    buffer.write(safe.path);
    if (safe.queryParameters.isNotEmpty) {
      buffer.write('?');
      buffer.write(
        safe.queryParameters.entries.map((e) => '${e.key}=$redacted').join('&'),
      );
    }
    if (safe.fragment.isNotEmpty) {
      buffer.write('#');
      buffer.write(redacted);
    }
    return buffer.toString();
  }

  /// Parse absolute URI only; never echo invalid input.
  static String sanitizeUriString(String raw) {
    final Uri uri;
    try {
      uri = Uri.parse(raw);
    } on FormatException {
      return invalidUri;
    }
    if (!uri.hasScheme || uri.host.isEmpty) {
      return invalidUri;
    }
    return uriForLog(uri);
  }

  /// Convert once, scrub, return null for null.
  static Object? sanitizeError(Object? error) {
    if (error == null) {
      return null;
    }
    return sanitizeMessage(error.toString());
  }

  /// Redact denylisted keys; safe primitives kept; nested maps one level.
  static Map<String, Object?> safeFields(Map<String, Object?> fields) {
    final out = <String, Object?>{};
    for (final entry in fields.entries) {
      out[entry.key] = _safeValue(entry.key, entry.value, depth: 0);
    }
    return out;
  }

  static Object? _safeValue(String key, Object? value, {required int depth}) {
    if (isSecretKey(key)) {
      return redacted;
    }
    if (value == null) {
      return null;
    }
    if (value is bool || value is num) {
      return value;
    }
    if (value is Uri) {
      return uriForLog(value);
    }
    if (value is String) {
      return sanitizeMessage(value);
    }
    if (value is Map) {
      if (depth >= 1) {
        return unsafe;
      }
      final nested = <String, Object?>{};
      for (final entry in value.entries) {
        final nestedKey = entry.key.toString();
        nested[nestedKey] = _safeValue(
          nestedKey,
          entry.value,
          depth: depth + 1,
        );
      }
      return nested;
    }
    return unsafe;
  }

  /// Best-effort free-text scrub for Bearer / JWT / secret assignments.
  static String scrubSecretPatterns(String input) {
    var out = input.replaceAllMapped(_bearer, (_) => 'Bearer $redacted');
    out = out.replaceAllMapped(_jwtLike, (_) => redacted);
    out = out.replaceAllMapped(_secretAssignment, (match) {
      final name = match.group(1)!;
      return '$name=$redacted';
    });
    return out;
  }
}
