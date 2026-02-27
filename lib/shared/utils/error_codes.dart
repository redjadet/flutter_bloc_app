/// Structured error codes for analytics and crash reporting.
///
/// Use when emitting error state or logging so that dashboards and crash
/// tools can aggregate by type. Attach to error state (e.g. in freezed
/// state) or pass to logging/crash reporting.
enum AppErrorCode {
  /// Network or connectivity failure.
  network,

  /// Request or operation timed out.
  timeout,

  /// Authentication required or token invalid (e.g. 401).
  auth,

  /// Server error (5xx) or backend failure.
  server,

  /// Service temporarily unavailable (503); suggest retry after delay.
  serviceUnavailable,

  /// Client error (4xx) or bad request.
  client,

  /// Rate limited (e.g. 429).
  rateLimit,

  /// Unknown or unclassified error.
  unknown,
}

extension AppErrorCodeExtension on AppErrorCode {
  /// Short string for logging or crash reporting (no PII).
  String get value => name;
}
