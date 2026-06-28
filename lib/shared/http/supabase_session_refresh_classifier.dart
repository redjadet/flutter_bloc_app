import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Auth error shapes that indicate the session cannot be recovered
/// without signing the user out (not transient network failures).
bool isAuthClassifiedSupabaseRefreshFailure(final Object error) {
  if (error is AuthRetryableFetchException) {
    return false;
  }
  if (error is! AuthException) {
    return false;
  }
  final int? statusCode = _parseStatusCode(error.statusCode);
  if (statusCode == null) {
    return false;
  }
  return statusCode == 400 || statusCode == 401 || statusCode == 403;
}

int? _parseStatusCode(final Object? statusCode) {
  if (statusCode is int) {
    return statusCode;
  }
  if (statusCode is String) {
    return int.tryParse(statusCode);
  }
  return null;
}
