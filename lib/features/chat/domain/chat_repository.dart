import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';

/// Active remote inference path for chrome / diagnostics (Supabase Edge vs direct HF).
enum ChatInferenceTransport { supabase, direct }

mixin ChatRepository {
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  });

  /// Hint for UI chrome when not mid-flight; see plan badge semantics.
  ChatInferenceTransport? get chatRemoteTransportHint;
}

class ChatException implements Exception {
  const ChatException(this.message);
  final String message;

  @override
  String toString() => 'ChatException: $message';
}

/// Typed remote failure for Edge/direct paths (queue table + `supabase/README.md` codes).
class ChatRemoteFailureException extends ChatException {
  const ChatRemoteFailureException(
    super.message, {
    required this.code,
    required this.retryable,
    required this.isEdge,
  });

  /// Stable machine-readable code (e.g. `auth_required`, `upstream_unavailable`).
  final String code;

  /// When false, callers must not enqueue as offline retry (auth, rate limit, etc.).
  final bool retryable;

  /// True when the failure came from the Supabase Edge proxy response.
  final bool isEdge;
}

/// Exception thrown when a chat message is queued for offline sync.
class ChatOfflineEnqueuedException extends ChatException {
  const ChatOfflineEnqueuedException([
    super.message = 'Message queued; will sync when back online.',
  ]);
}

class ChatResult {
  const ChatResult({
    required this.reply,
    required this.pastUserInputs,
    required this.generatedResponses,
    this.transportUsed,
  });

  final ChatMessage reply;
  final List<String> pastUserInputs;
  final List<String> generatedResponses;

  /// Which path produced this completion (for request-scoped transport chip).
  final ChatInferenceTransport? transportUsed;
}
