import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';

abstract class ChatRepository {
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
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
