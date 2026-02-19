import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_sync_payload.freezed.dart';

@freezed
abstract class ChatSyncPayload with _$ChatSyncPayload {
  const factory ChatSyncPayload({
    required final String conversationId,
    required final String prompt,
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String? model,
    required final String clientMessageId,
    required final DateTime createdAt,
  }) = _ChatSyncPayload;

  const ChatSyncPayload._();

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
