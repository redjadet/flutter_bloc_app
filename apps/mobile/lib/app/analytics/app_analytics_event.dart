/// Typed analytics events. Construct only via named factories.
///
/// Allowed parameter keys: `mode`, `source`, `result`, `variant`.
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
  AppAnalyticsEvent._(this.name, this.parameters)
    : assert(
        parameters.keys.every(allowedParameterKeys.contains),
        'Analytics parameters must use allowlisted keys only',
      );

  static const Set<String> allowedParameterKeys = <String>{
    'mode',
    'source',
    'result',
    'variant',
  };

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
      if (_looksLikeForbiddenPayload(value)) {
        throw ArgumentError.value(
          value,
          entry.key,
          'Analytics parameter looks like a forbidden payload',
        );
      }
    }
  }

  static bool _looksLikeForbiddenPayload(final String value) {
    final String lower = value.toLowerCase();
    if (lower.contains('@') && lower.contains('.')) {
      return true; // email-like
    }
    if (lower.contains('token') || lower.contains('bearer ')) {
      return true;
    }
    // Long opaque strings that look like device tokens.
    if (value.length >= 64 && RegExp(r'^[A-Za-z0-9_\-:]+$').hasMatch(value)) {
      return true;
    }
    return false;
  }
}
