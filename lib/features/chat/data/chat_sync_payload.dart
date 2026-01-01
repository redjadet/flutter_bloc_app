import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';

class ChatSyncPayload {
  const ChatSyncPayload({
    required this.conversationId,
    required this.prompt,
    required this.pastUserInputs,
    required this.generatedResponses,
    required this.model,
    required this.clientMessageId,
    required this.createdAt,
  });

  final String conversationId;
  final String prompt;
  final List<String> pastUserInputs;
  final List<String> generatedResponses;
  final String? model;
  final String clientMessageId;
  final DateTime createdAt;

  ChatMessage userMessage({
    required final String promptText,
  }) => ChatMessage(
    author: ChatAuthor.user,
    text: promptText,
    clientMessageId: clientMessageId,
    createdAt: createdAt,
    synchronized: false,
  );
}
