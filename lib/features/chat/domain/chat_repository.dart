import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';

mixin ChatRepository {
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  });
}

class ChatException implements Exception {
  const ChatException(this.message);
  final String message;

  @override
  String toString() => 'ChatException: $message';
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
  });

  final ChatMessage reply;
  final List<String> pastUserInputs;
  final List<String> generatedResponses;
}
