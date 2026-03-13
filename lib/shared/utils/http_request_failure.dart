import 'package:flutter_bloc_app/shared/utils/app_error.dart';

/// Exception thrown when an HTTP request fails with a non-success status code.
///
/// Carries [statusCode] so callers can differentiate auth (401), service
/// unavailable (503), rate limit (429), etc., and show accurate messages
/// (e.g. "Sign in again" vs "Service temporarily unavailable").
///
/// See: production error differentiation — avoid returning "Authentication
/// failed" when the backend or database is down.
class HttpRequestFailure implements Exception {
  const HttpRequestFailure(
    this.statusCode,
    this.message, {
    this.retryAfterSeconds,
  });

  final int statusCode;
  final String message;

  /// Optional Retry-After hint (seconds) from response header.
  final int? retryAfterSeconds;

  /// Projects this failure into a structured [AppError].
  AppError toAppError() => appErrorFromHttpStatus(
    statusCode,
    message: message,
    cause: this,
  );

  @override
  String toString() => 'HttpRequestFailure($statusCode): $message';
}
