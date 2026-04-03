import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// When [chat-complete] is not deployed, the gateway responds with 404 and/or
/// a reason phrase like "Requested function was not found".
bool looksLikeUndeployedChatCompleteFunction(final FunctionException e) {
  if (e.status == 404) {
    return true;
  }
  final String phrase = (e.reasonPhrase ?? '').toLowerCase();
  if (phrase.contains('not found') &&
      (phrase.contains('function') || phrase.contains('requested'))) {
    return true;
  }
  final Object? d = e.details;
  if (d is String) {
    final String s = d.toLowerCase();
    if (s.contains('not found') &&
        (s.contains('function') || s.contains('requested'))) {
      return true;
    }
  }
  if (d is Map) {
    for (final String key in <String>['message', 'error', 'msg']) {
      final Object? v = d[key];
      if (v is String) {
        final String s = v.toLowerCase();
        if (s.contains('not found') &&
            (s.contains('function') || s.contains('requested'))) {
          return true;
        }
      }
    }
  }
  return false;
}

/// Maps [FunctionException] from Supabase Functions `chat-complete` invoke.
ChatRemoteFailureException mapSupabaseChatCompleteFunctionException(
  final FunctionException e,
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

  final int status = e.status;
  if (status == 401) {
    return const ChatRemoteFailureException(
      'Sign in required or session expired.',
      code: 'auth_required',
      retryable: false,
      isEdge: true,
    );
  }
  if (status == 403) {
    return const ChatRemoteFailureException(
      'Not allowed to complete this chat request.',
      code: 'forbidden',
      retryable: false,
      isEdge: true,
    );
  }
  if (status == 429) {
    return const ChatRemoteFailureException(
      'Rate limited. Please wait and try again.',
      code: 'rate_limited',
      retryable: false,
      isEdge: true,
    );
  }
  if (status == 504) {
    return const ChatRemoteFailureException(
      'Cloud chat timed out.',
      code: 'upstream_timeout',
      retryable: true,
      isEdge: true,
    );
  }
  if (status >= 500) {
    return ChatRemoteFailureException(
      'Cloud chat unavailable (HTTP $status).',
      code: 'upstream_unavailable',
      retryable: true,
      isEdge: true,
    );
  }
  if (status >= 400) {
    return ChatRemoteFailureException(
      'Invalid chat request (HTTP $status).',
      code: 'invalid_request',
      retryable: false,
      isEdge: true,
    );
  }

  return const ChatRemoteFailureException(
    'Cloud chat request failed.',
    code: 'upstream_unavailable',
    retryable: true,
    isEdge: true,
  );
}
