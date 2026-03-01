import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

typedef JsonMap = Map<String, dynamic>;

class HuggingFaceResponseParser {
  const HuggingFaceResponseParser({required final String fallbackMessage})
    : _fallbackMessage = fallbackMessage;

  final String _fallbackMessage;

  ChatResult buildInferenceResult(final JsonMap json) {
    final JsonMap conversation =
        mapFromDynamic(json['conversation']) ?? const <String, dynamic>{};
    final List<String> updatedPastInputs = _stringsFrom(
      conversation['past_user_inputs'],
    );
    final List<String> updatedResponses = _stringsFrom(
      conversation['generated_responses'],
    );
    final String replyText =
        stringFromDynamic(json['generated_text']) ??
        _lastOrFallback(updatedResponses);

    return ChatResult(
      reply: ChatMessage(author: ChatAuthor.assistant, text: replyText),
      pastUserInputs: updatedPastInputs,
      generatedResponses: updatedResponses,
    );
  }

  ChatResult buildChatCompletionsResult({
    required final JsonMap json,
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
  }) {
    final String replyText = _extractAssistantContent(json);

    return ChatResult(
      reply: ChatMessage(author: ChatAuthor.assistant, text: replyText),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, replyText],
    );
  }

  List<String> _stringsFrom(final dynamic value) {
    if (value is List) {
      return value
          .map((final dynamic element) => element.toString())
          .toList(growable: false);
    }
    return const <String>[];
  }

  String _lastOrFallback(final List<String> values) {
    if (values.isNotEmpty && values.last.trim().isNotEmpty) {
      return values.last;
    }
    return _fallbackMessage;
  }

  String _extractAssistantContent(final JsonMap json) {
    final List<dynamic>? choices = listFromDynamic(json['choices']);
    if (choices == null || choices.isEmpty) {
      return _fallbackMessage;
    }

    final dynamic first = choices.first;
    final JsonMap? firstChoice = first is JsonMap ? first : null;
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
