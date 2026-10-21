import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

typedef JsonMap = Map<String, dynamic>;

class HuggingFaceResponseParser {
  const new({required this._fallbackMessage});

  final String _fallbackMessage;

  ChatResult buildInferenceResult(JsonMap json) {
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

  List<String> _stringsFrom(Object? value) => switch (value) {
    final List<dynamic> items =>
      items.map((element) => element.toString()).toList(growable: false),
    _ => const <String>[],
  };

  String _lastOrFallback(List<String> values) => switch (values) {
    [..., final String last] when last.trim().isNotEmpty => last,
    _ => _fallbackMessage,
  };

  String _extractAssistantContent(JsonMap json) {
    final List<dynamic>? choices = listFromDynamic(json['choices']);
    if (choices case [final Object? first, ...]) {
      final JsonMap? firstChoice = first is JsonMap ? first : null;
      return switch (firstChoice?['message']) {
        {'content': final String content} when content.trim().isNotEmpty =>
          content,
        {'content': final List<dynamic> chunks} => _textFromContentChunks(
          chunks,
        ),
        _ => _fallbackMessage,
      };
    }
    return _fallbackMessage;
  }

  /// Joins text/content parts. A present `text` wins even when it is unusable,
  /// matching `text ?? content` rather than falling through to `content`.
  String _textFromContentChunks(Iterable<Object?> chunks) {
    final StringBuffer buffer = StringBuffer();
    for (final Object? chunk in chunks) {
      if (chunk is! JsonMap) {
        continue;
      }
      final Object? primary = chunk['text'] ?? chunk['content'];
      if (primary is String && primary.trim().isNotEmpty) {
        buffer.write(primary);
      }
    }
    final String combined = buffer.toString().trim();
    if (combined.isEmpty) {
      return _fallbackMessage;
    }
    return combined;
  }
}
