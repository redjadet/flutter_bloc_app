import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_sync_payload.freezed.dart';

@freezed
abstract class ChatSyncPayload with _$ChatSyncPayload {
  const factory ChatSyncPayload({
    required String conversationId,
    required String prompt,
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String? model,
    required String clientMessageId,
    required DateTime createdAt,
  }) = _ChatSyncPayload;

  const ChatSyncPayload._();

  ChatMessage userMessage({
    required String promptText,
  }) => ChatMessage(
    author: ChatAuthor.user,
    text: promptText,
    clientMessageId: clientMessageId,
    createdAt: createdAt,
    synchronized: false,
  );
}
