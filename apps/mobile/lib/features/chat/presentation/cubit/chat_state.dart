import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_failure.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    ChatFailure? failure,
    @Default(<String>[]) List<String> pastUserInputs,
    @Default(<String>[]) List<String> generatedResponses,
    String? currentModel,
    @Default(<ChatConversation>[]) List<ChatConversation> history,
    String? activeConversationId,
    ChatRemotePath? runnableTransportHint,
    ChatRemotePath? lastCompletionTransport,
  }) = _ChatState;

  const ChatState._();

  factory ChatState.initial({String? currentModel}) =>
      ChatState(currentModel: currentModel);

  bool get hasError => failure != null;
  String? get error => failure?.message;
  String? get remoteFailureL10nCode => failure?.l10nCode;
  bool get hasMessages => messages.isNotEmpty;
  bool get hasHistory => history.isNotEmpty;
  bool get canSend => !isLoading;
  bool get hasContent =>
      hasMessages || pastUserInputs.isNotEmpty || generatedResponses.isNotEmpty;

  /// Transport shown in the online chip: last successful completion, else repo hint.
  ChatRemotePath? get transportForBadge =>
      lastCompletionTransport ?? runnableTransportHint;
}
