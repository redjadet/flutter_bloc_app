/// Typed analytics events. Construct only via named factories.
///
/// Allowed parameter keys: `mode`, `source`, `result`, `variant`.
/// Values are schema-constrained (short enum-like tokens), never free-form IDs.
final class AppAnalyticsEvent {
  factory AppAnalyticsEvent.showcaseOpened({
    required final String mode,
    required final String source,
  }) => AppAnalyticsEvent._('showcase_opened', <String, String>{
    'mode': mode,
    'source': source,
  });

  factory AppAnalyticsEvent.releaseFlagEvaluated({
    required final String result,
    required final String variant,
    required final String source,
  }) => AppAnalyticsEvent._('release_flag_evaluated', <String, String>{
    'result': result,
    'variant': variant,
    'source': source,
  });

  factory AppAnalyticsEvent.notificationReceived({
    required final String mode,
    required final String source,
  }) => AppAnalyticsEvent._('notification_received', <String, String>{
    'mode': mode,
    'source': source,
  });

  factory AppAnalyticsEvent.notificationOpened({
    required final String mode,
    required final String source,
  }) => AppAnalyticsEvent._('notification_opened', <String, String>{
    'mode': mode,
    'source': source,
  });

  factory AppAnalyticsEvent.demoActionCompleted({
    required final String result,
    required final String source,
  }) => AppAnalyticsEvent._('demo_action_completed', <String, String>{
    'result': result,
    'source': source,
  });

  AppAnalyticsEvent._(this.name, final Map<String, String> rawParameters)
    : parameters = Map<String, String>.unmodifiable(rawParameters) {
    validateParameters(parameters);
  }

  static const Set<String> allowedParameterKeys = <String>{
    'mode',
    'source',
    'result',
    'variant',
  };

  /// Max length for allowlisted string values (enum-like tokens only).
  static const int maxParameterValueLength = 32;

  static final RegExp _allowedValuePattern = RegExp(
    r'^[a-zA-Z][a-zA-Z0-9_.:\-]*$',
  );
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static final RegExp _hexIdPattern = RegExp(r'^[0-9a-fA-F]{16,}$');

  final String name;
  final Map<String, String> parameters;

  /// Defense-in-depth validation before adapters forward parameters.
  static void validateParameters(final Map<String, Object?> parameters) {
    for (final MapEntry<String, Object?> entry in parameters.entries) {
      if (!allowedParameterKeys.contains(entry.key)) {
        throw ArgumentError.value(
          entry.key,
          'parameters',
          'Key is not in analytics allowlist',
        );
      }
      final Object? value = entry.value;
      if (value is! String) {
        throw ArgumentError.value(
          value,
          entry.key,
          'Analytics parameter values must be String',
        );
      }
      if (!_isAllowedParameterValue(value)) {
        throw ArgumentError.value(
          value,
          entry.key,
          'Analytics parameter is not a schema-allowed token',
        );
      }
    }
  }

  /// Coerce free-form remote/config strings into allowlisted tokens.
  static String coerceToken(
    final String raw, {
    required final String fallback,
  }) {
    final String trimmed = raw.trim();
    if (_isAllowedParameterValue(trimmed)) {
      return trimmed;
    }
    return fallback;
  }

  static bool _isAllowedParameterValue(final String value) {
    if (value.isEmpty || value.length > maxParameterValueLength) {
      return false;
    }
    if (!_allowedValuePattern.hasMatch(value)) {
      return false;
    }
    if (_looksLikeForbiddenPayload(value)) {
      return false;
    }
    return true;
  }

  static bool _looksLikeForbiddenPayload(final String value) {
    final String lower = value.toLowerCase();
    if (lower.contains('@') && lower.contains('.')) {
      return true; // email-like
    }
    if (lower.contains('token') || lower.contains('bearer ')) {
      return true;
    }
    if (_uuidPattern.hasMatch(value) || _hexIdPattern.hasMatch(value)) {
      return true;
    }
    // Long opaque strings that look like device tokens.
    if (value.length >= 64 && RegExp(r'^[A-Za-z0-9_\-:]+$').hasMatch(value)) {
      return true;
    }
    return false;
  }
}
