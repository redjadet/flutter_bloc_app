import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';

class ChatState {
  const ChatState({
    this.messages = const <ChatMessage>[],
    this.isLoading = false,
    this.error,
    this.pastUserInputs = const <String>[],
    this.generatedResponses = const <String>[],
  });

  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final List<String> pastUserInputs;
  final List<String> generatedResponses;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<String>? pastUserInputs,
    List<String>? generatedResponses,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pastUserInputs: pastUserInputs ?? this.pastUserInputs,
      generatedResponses: generatedResponses ?? this.generatedResponses,
    );
  }
}
