import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

enum ChatStatus { idle, loading, success, error }

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default(<ChatMessage>[]) final List<ChatMessage> messages,
    @Default(false) final bool isLoading,
    final String? error,
    @Default(<String>[]) final List<String> pastUserInputs,
    @Default(<String>[]) final List<String> generatedResponses,
    final String? currentModel,
    @Default(<ChatConversation>[]) final List<ChatConversation> history,
    final String? activeConversationId,
    @Default(ChatStatus.idle) final ChatStatus status,
  }) = _ChatState;

  const ChatState._();

  factory ChatState.initial({final String? currentModel}) =>
      ChatState(currentModel: currentModel);

  bool get hasError => error != null;
  bool get hasMessages => messages.isNotEmpty;
  bool get hasHistory => history.isNotEmpty;
  bool get canSend => !isLoading;
  bool get hasContent =>
      hasMessages || pastUserInputs.isNotEmpty || generatedResponses.isNotEmpty;
}
