import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// When [chat-complete] is not deployed, the gateway responds with 404 and/or
/// a reason phrase like "Requested function was not found".
bool looksLikeUndeployedChatCompleteFunction(FunctionException e) {
  if (e.status == 404) {
    return true;
  }
  if (_mentionsMissingFunction(e.reasonPhrase)) {
    return true;
  }
  return _detailsMentionMissingFunction(e.details);
}

bool _mentionsMissingFunction(String? value) {
  if (value == null) {
    return false;
  }
  final String lower = value.toLowerCase();
  return lower.contains('not found') &&
      (lower.contains('function') || lower.contains('requested'));
}

bool _detailsMentionMissingFunction(Object? details) {
  switch (details) {
    case final String text:
      return _mentionsMissingFunction(text);
    case final Map<dynamic, dynamic> map:
      for (final String key in <String>['message', 'error', 'msg']) {
        final Object? value = map[key];
        if (value is String && _mentionsMissingFunction(value)) {
          return true;
        }
      }
      return false;
    default:
      return false;
  }
}

/// Maps [FunctionException] from Supabase Functions `chat-complete` invoke.
ChatRemoteFailureException mapSupabaseChatCompleteFunctionException(
  FunctionException e,
) {
  final Object? details = e.details;
  if (details is Map) {
    final Object? code = details['code'];
    final Object? retry = details['retryable'];
    final Object? message = details['message'];
    if (code is String) {
      return ChatRemoteFailureException(
        message is String && message.isNotEmpty
            ? message
            : 'Chat request failed.',
        code: code,
        retryable: retry == true,
        isEdge: true,
      );
    }
  }

  if (looksLikeUndeployedChatCompleteFunction(e)) {
    return const ChatRemoteFailureException(
      'Edge function chat-complete is not deployed for this Supabase project. '
      'Run: npx supabase functions deploy chat-complete (see supabase/README.md). '
      'Until then, chat can use direct Hugging Face when a device key is allowed.',
      code: 'missing_configuration',
      retryable: false,
      isEdge: true,
    );
  }

  return switch (e.status) {
    401 => const ChatRemoteFailureException(
      'Sign in required or session expired.',
      code: 'auth_required',
      retryable: false,
      isEdge: true,
    ),
    403 => const ChatRemoteFailureException(
      'Not allowed to complete this chat request.',
      code: 'forbidden',
      retryable: false,
      isEdge: true,
    ),
    429 => const ChatRemoteFailureException(
      'Rate limited. Please wait and try again.',
      code: 'rate_limited',
      retryable: false,
      isEdge: true,
    ),
    504 => const ChatRemoteFailureException(
      'Cloud chat timed out.',
      code: 'upstream_timeout',
      retryable: true,
      isEdge: true,
    ),
    >= 500 => ChatRemoteFailureException(
      'Cloud chat unavailable (HTTP ${e.status}).',
      code: 'upstream_unavailable',
      retryable: true,
      isEdge: true,
    ),
    >= 400 => ChatRemoteFailureException(
      'Invalid chat request (HTTP ${e.status}).',
      code: 'invalid_request',
      retryable: false,
      isEdge: true,
    ),
    _ => const ChatRemoteFailureException(
      'Cloud chat request failed.',
      code: 'upstream_unavailable',
      retryable: true,
      isEdge: true,
    ),
  };
}
