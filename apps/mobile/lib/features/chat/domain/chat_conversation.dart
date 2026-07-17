import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';

@freezed
abstract class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required final String id,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    @Default(<ChatMessage>[]) final List<ChatMessage> messages,
    @Default(<String>[]) final List<String> pastUserInputs,
    @Default(<String>[]) final List<String> generatedResponses,
    final String? model,
    final DateTime? lastSyncedAt,
    @Default(true) final bool synchronized,
    final String? changeId,
  }) = _ChatConversation;
  const ChatConversation._();

  bool get hasContent =>
      messages.isNotEmpty ||
      pastUserInputs.isNotEmpty ||
      generatedResponses.isNotEmpty;
}
