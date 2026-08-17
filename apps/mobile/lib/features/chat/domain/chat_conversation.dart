import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';

@freezed
abstract class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
    @Default(<String>[]) List<String> pastUserInputs,
    @Default(<String>[]) List<String> generatedResponses,
    String? model,
    DateTime? lastSyncedAt,
    @Default(true) bool synchronized,
    String? changeId,
  }) = _ChatConversation;
  const ChatConversation._();

  bool get hasContent =>
      messages.isNotEmpty ||
      pastUserInputs.isNotEmpty ||
      generatedResponses.isNotEmpty;
}
