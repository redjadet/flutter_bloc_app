import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

class HuggingfaceChatRepository implements ChatRepository {
  HuggingfaceChatRepository({
    http.Client? client,
    String? apiKey,
    String? model,
    bool useChatCompletions = false,
  }) : _client = client ?? http.Client(),
       _apiKey = _normalize(apiKey),
       _model = _normalize(model) ?? _defaultModel,
       _useChatCompletions = useChatCompletions;

  static const String _defaultModel = 'HuggingFaceH4/zephyr-7b-beta';
  static const String _inferenceBaseUrl =
      'https://api-inference.huggingface.co/models';
  static final Uri _chatCompletionsUri = Uri.parse(
    'https://router.huggingface.co/v1/chat/completions',
  );

  final http.Client _client;
  final String? _apiKey;
  final String _model;
  final bool _useChatCompletions;

  Uri get _inferenceUri => Uri.parse('$_inferenceBaseUrl/$_model');

  Map<String, String> get _headers => <String, String>{
    'Content-Type': 'application/json',
    if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
  };

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) async {
    if (_apiKey == null) {
      throw const ChatException('Missing Hugging Face API token.');
    }

    return _useChatCompletions
        ? _sendViaChatCompletions(
            pastUserInputs: pastUserInputs,
            generatedResponses: generatedResponses,
            prompt: prompt,
          )
        : _sendViaInference(
            pastUserInputs: pastUserInputs,
            generatedResponses: generatedResponses,
            prompt: prompt,
          );
  }

  Future<ChatResult> _sendViaInference({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'inputs': <String, dynamic>{
        'past_user_inputs': pastUserInputs,
        'generated_responses': generatedResponses,
        'text': prompt,
      },
    };

    final Map<String, dynamic> json = await _postJson(
      _inferenceUri,
      payload,
      context: 'inference',
    );

    final Map<String, dynamic> conversation =
        (json['conversation'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
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

  Future<ChatResult> _sendViaChatCompletions({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) async {
    final Map<String, dynamic> payload = <String, dynamic>{
      'model': _model,
      'messages': <Map<String, String>>[
        for (
          int i = 0;
          i < pastUserInputs.length;
          i++
        ) ...<Map<String, String>>[
          <String, String>{'role': 'user', 'content': pastUserInputs[i]},
          if (i < generatedResponses.length)
            <String, String>{
              'role': 'assistant',
              'content': generatedResponses[i],
            },
        ],
        <String, String>{'role': 'user', 'content': prompt},
      ],
      'stream': false,
    };

    final Map<String, dynamic> json = await _postJson(
      _chatCompletionsUri,
      payload,
      context: 'chat-completions',
    );

    final String replyText = _extractAssistantContent(json);

    return ChatResult(
      reply: ChatMessage(author: ChatAuthor.assistant, text: replyText),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, replyText],
    );
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> payload, {
    required String context,
  }) async {
    try {
      final http.Response response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(payload),
      );

      final int code = response.statusCode;
      if (code == 429) {
        throw const ChatException(
          'Hugging Face rate limit hit. Please wait before trying again.',
        );
      }

      if (code >= 400) {
        final String friendly = _formatError(response);
        AppLogger.error(
          'HuggingfaceChatRepository.$context non-success',
          'HTTP $code => ${response.body}',
          StackTrace.current,
        );
        throw ChatException(friendly);
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e, s) {
      if (e is ChatException) rethrow;
      AppLogger.error('HuggingfaceChatRepository.$context failed', e, s);
      throw const ChatException('Failed to contact chat service.');
    }
  }

  static String _extractAssistantContent(Map<String, dynamic> json) {
    final List<dynamic>? choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return _fallbackMessage;
    }

    final Map<String, dynamic>? firstChoice =
        choices.first as Map<String, dynamic>?;
    final dynamic message = firstChoice?['message'];

    if (message is Map<String, dynamic>) {
      final dynamic content = message['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content;
      }
      if (content is List) {
        final String buffer = content
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> chunk) =>
                  (chunk['text'] ?? chunk['content'] ?? '').toString(),
            )
            .join();
        if (buffer.trim().isNotEmpty) {
          return buffer;
        }
      }
    }

    return _fallbackMessage;
  }

  static List<String> _stringsFrom(dynamic value) {
    if (value is List) {
      return value.map((dynamic e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  static String _lastOrFallback(List<String> values) {
    if (values.isNotEmpty && values.last.trim().isNotEmpty) {
      return values.last;
    }
    return _fallbackMessage;
  }

  static String? _normalize(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _formatError(http.Response response) {
    final int code = response.statusCode;
    final String body = response.body;
    String? detail;
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        detail = (decoded['error'] ?? decoded['message']) as String?;
      }
    } catch (_) {
      if (body.isNotEmpty && body != 'null') {
        detail = body;
      }
    }

    if (code == 401 || code == 403 || code == 404) {
      return detail == null
          ? 'Chat service authentication failed (HTTP $code). Check your Hugging Face token or model.'
          : 'Chat service authentication failed (HTTP $code): $detail. Verify your Hugging Face token/model access.';
    }

    if (detail == null || detail.isEmpty) {
      return 'Chat service error (HTTP $code).';
    }
    return 'Chat service error (HTTP $code): $detail';
  }

  static const String _fallbackMessage = "I'm not sure how to respond yet.";
}
