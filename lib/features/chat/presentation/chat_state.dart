import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    String? error,
    @Default(<String>[]) List<String> pastUserInputs,
    @Default(<String>[]) List<String> generatedResponses,
    String? currentModel,
    @Default(<ChatConversation>[]) List<ChatConversation> history,
    String? activeConversationId,
  }) = _ChatState;

  const ChatState._();

  factory ChatState.initial({String? currentModel}) =>
      ChatState(currentModel: currentModel);

  bool get hasError => error != null;
  bool get hasMessages => messages.isNotEmpty;
  bool get hasHistory => history.isNotEmpty;
  bool get canSend => !isLoading;
}
