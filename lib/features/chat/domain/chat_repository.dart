import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';

abstract class ChatRepository {
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
  });
}

class ChatException implements Exception {
  const ChatException(this.message);
  final String message;

  @override
  String toString() => 'ChatException: $message';
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
