import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';

typedef JsonMap = Map<String, dynamic>;

class HuggingFaceResponseParser {
  const HuggingFaceResponseParser({required String fallbackMessage})
    : _fallbackMessage = fallbackMessage;

  final String _fallbackMessage;

  ChatResult buildInferenceResult(JsonMap json) {
    final JsonMap conversation =
        (json['conversation'] as JsonMap?) ?? const <String, dynamic>{};
    final List<String> updatedPastInputs = _stringsFrom(
      conversation['past_user_inputs'],
    );
    final List<String> updatedResponses = _stringsFrom(
      conversation['generated_responses'],
    );
    final String replyText =
        (json['generated_text'] as String?) ??
        _lastOrFallback(updatedResponses);

    return ChatResult(
      reply: ChatMessage(author: ChatAuthor.assistant, text: replyText),
      pastUserInputs: updatedPastInputs,
      generatedResponses: updatedResponses,
    );
  }

  ChatResult buildChatCompletionsResult({
    required JsonMap json,
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    final String replyText = _extractAssistantContent(json);

    return ChatResult(
      reply: ChatMessage(author: ChatAuthor.assistant, text: replyText),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, replyText],
    );
  }

  List<String> _stringsFrom(dynamic value) {
    if (value is List) {
      return value
          .map((dynamic element) => element.toString())
          .toList(growable: false);
    }
    return const <String>[];
  }

  String _lastOrFallback(List<String> values) {
    if (values.isNotEmpty && values.last.trim().isNotEmpty) {
      return values.last;
    }
    return _fallbackMessage;
  }

  String _extractAssistantContent(JsonMap json) {
    final List<dynamic>? choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return _fallbackMessage;
    }

    final JsonMap? firstChoice = choices.first as JsonMap?;
    final dynamic message = firstChoice?['message'];

    if (message is JsonMap) {
      final dynamic content = message['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content;
      }
      if (content is List) {
        final StringBuffer buffer = StringBuffer();
        for (final dynamic chunk in content) {
          if (chunk is JsonMap) {
            final Object? primary = chunk['text'] ?? chunk['content'];
            if (primary is String && primary.trim().isNotEmpty) {
              buffer.write(primary);
            }
          }
        }
        final String combined = buffer.toString().trim();
        if (combined.isNotEmpty) {
          return combined;
        }
      }
    }

    return _fallbackMessage;
  }
}
