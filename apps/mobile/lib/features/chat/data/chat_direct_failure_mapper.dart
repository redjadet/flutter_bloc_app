import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';

ChatRemoteFailureException _directRemoteFailure(
  ChatException error, {
  required String code,
  required bool retryable,
}) => ChatRemoteFailureException(
  error.message,
  code: code,
  retryable: retryable,
  isEdge: false,
);

/// Maps direct Hugging Face [ChatException] messages to [ChatRemoteFailureException]
/// for queue classification (plan: terminal vs retryable).
ChatRemoteFailureException mapDirectChatException(ChatException error) {
  final ({String code, bool retryable}) classified = _classifyDirectChatMessage(
    error.message.toLowerCase(),
  );
  return _directRemoteFailure(
    error,
    code: classified.code,
    retryable: classified.retryable,
  );
}

/// Phrase checks stay ordered: the first matching hint wins, then an HTTP
/// status embedded in the message, then the retryable upstream fallback.
({String code, bool retryable}) _classifyDirectChatMessage(String lower) {
  if (lower.contains('rate limit')) {
    return (code: 'rate_limited', retryable: false);
  }
  if (lower.contains('http 401') || lower.contains('authentication failed')) {
    return (code: 'auth_required', retryable: false);
  }
  if (lower.contains('http 403')) {
    return (code: 'forbidden', retryable: false);
  }
  if (lower.contains('timed out') || lower.contains('timeout')) {
    return (code: 'upstream_timeout', retryable: true);
  }
  if (lower.contains('failed to contact') ||
      lower.contains('chat service returned invalid') ||
      lower.contains('unsupported content')) {
    return (code: 'upstream_unavailable', retryable: true);
  }

  final RegExpMatch? httpMatch = RegExp(r'http (\d{3})').firstMatch(lower);
  if (httpMatch?.group(1) case final String statusDigits) {
    final int statusCode = int.tryParse(statusDigits) ?? 0;
    return switch (statusCode) {
      429 => (code: 'rate_limited', retryable: false),
      401 => (code: 'auth_required', retryable: false),
      403 => (code: 'forbidden', retryable: false),
      >= 500 => (code: 'upstream_unavailable', retryable: true),
      >= 400 => (code: 'invalid_request', retryable: false),
      _ => (code: 'upstream_unavailable', retryable: true),
    };
  }

  return (code: 'upstream_unavailable', retryable: true);
}
