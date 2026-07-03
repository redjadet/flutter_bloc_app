import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';

ChatRemoteFailureException _directRemoteFailure(
  final ChatException error, {
  required final String code,
  required final bool retryable,
}) => ChatRemoteFailureException(
  error.message,
  code: code,
  retryable: retryable,
  isEdge: false,
);

/// Maps direct Hugging Face [ChatException] messages to [ChatRemoteFailureException]
/// for queue classification (plan: terminal vs retryable).
ChatRemoteFailureException mapDirectChatException(final ChatException error) {
  final String m = error.message;
  final String lower = m.toLowerCase();

  if (lower.contains('rate limit')) {
    return _directRemoteFailure(error, code: 'rate_limited', retryable: false);
  }

  if (lower.contains('http 401') || lower.contains('authentication failed')) {
    return _directRemoteFailure(
      error,
      code: 'auth_required',
      retryable: false,
    );
  }

  if (lower.contains('http 403')) {
    return _directRemoteFailure(error, code: 'forbidden', retryable: false);
  }

  if (lower.contains('timed out') || lower.contains('timeout')) {
    return _directRemoteFailure(
      error,
      code: 'upstream_timeout',
      retryable: true,
    );
  }

  if (lower.contains('failed to contact') ||
      lower.contains('chat service returned invalid') ||
      lower.contains('unsupported content')) {
    return _directRemoteFailure(
      error,
      code: 'upstream_unavailable',
      retryable: true,
    );
  }

  final RegExpMatch? httpMatch = RegExp(r'http (\d{3})').firstMatch(lower);
  if (httpMatch != null) {
    final String? statusDigits = httpMatch.group(1);
    final int code = int.tryParse(statusDigits ?? '') ?? 0;
    if (code == 429) {
      return _directRemoteFailure(
        error,
        code: 'rate_limited',
        retryable: false,
      );
    }
    if (code == 401) {
      return _directRemoteFailure(
        error,
        code: 'auth_required',
        retryable: false,
      );
    }
    if (code == 403) {
      return _directRemoteFailure(error, code: 'forbidden', retryable: false);
    }
    if (code >= 500) {
      return _directRemoteFailure(
        error,
        code: 'upstream_unavailable',
        retryable: true,
      );
    }
    if (code >= 400) {
      return _directRemoteFailure(
        error,
        code: 'invalid_request',
        retryable: false,
      );
    }
  }

  return _directRemoteFailure(
    error,
    code: 'upstream_unavailable',
    retryable: true,
  );
}
