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
       _apiKey = apiKey?.isEmpty ?? true ? null : apiKey,
       _model = model ?? _defaultModel,
       _useChatCompletions = useChatCompletions;

  static const String _baseUrl = 'https://api-inference.huggingface.co/models';
  static const String _defaultModel = 'HuggingFaceH4/zephyr-7b-beta';
  static const String _chatCompletionsUrl =
      'https://router.huggingface.co/v1/chat/completions';

  final http.Client _client;
  final String? _apiKey;
  final String _model;
  final bool _useChatCompletions;

  Uri get _endpoint => _useChatCompletions
      ? Uri.parse(_chatCompletionsUrl)
      : Uri.parse('$_baseUrl/$_model');

  Map<String, String> _headers() {
    return <String, String>{
      'Content-Type': 'application/json',
      if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
    };
  }

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) async {
    if (_apiKey == null) {
      throw const ChatException('Missing Hugging Face API token.');
    }

    final Map<String, dynamic> payload = _useChatCompletions
        ? _buildChatCompletionsPayload(
            pastUserInputs: pastUserInputs,
            generatedResponses: generatedResponses,
            prompt: prompt,
          )
        : _buildInferencePayload(
            pastUserInputs: pastUserInputs,
            generatedResponses: generatedResponses,
            prompt: prompt,
          );

    try {
      final http.Response response = await _client.post(
        _endpoint,
        headers: _headers(),
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
          'HuggingfaceChatRepository.sendMessage non-success',
          'HTTP $code => ${response.body}',
          StackTrace.current,
        );
        throw ChatException(friendly);
      }

      final Map<String, dynamic> decoded =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (_useChatCompletions) {
        return _mapChatCompletionsResult(
          decoded: decoded,
          pastUserInputs: pastUserInputs,
          generatedResponses: generatedResponses,
          prompt: prompt,
        );
      }

      return _mapInferenceResult(decoded);
    } catch (e, s) {
      if (e is ChatException) rethrow;
      AppLogger.error('HuggingfaceChatRepository.sendMessage failed', e, s);
      throw const ChatException('Failed to contact chat service.');
    }
  }

  Map<String, dynamic> _buildInferencePayload({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    return <String, dynamic>{
      'inputs': <String, dynamic>{
        'past_user_inputs': pastUserInputs,
        'generated_responses': generatedResponses,
        'text': prompt,
      },
    };
  }

  Map<String, dynamic> _buildChatCompletionsPayload({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    final List<Map<String, String>> messages = <Map<String, String>>[
      for (int i = 0; i < pastUserInputs.length; i++) ...<Map<String, String>>[
        <String, String>{'role': 'user', 'content': pastUserInputs[i]},
        if (i < generatedResponses.length)
          <String, String>{
            'role': 'assistant',
            'content': generatedResponses[i],
          },
      ],
      <String, String>{'role': 'user', 'content': prompt},
    ];

    return <String, dynamic>{
      'model': _model,
      'messages': messages,
      'stream': false,
    };
  }

  ChatResult _mapInferenceResult(Map<String, dynamic> decoded) {
    final Map<String, dynamic>? conversation =
        decoded['conversation'] as Map<String, dynamic>?;
    final List<dynamic>? responses =
        conversation?['generated_responses'] as List<dynamic>?;
    final List<dynamic>? pastInputs =
        conversation?['past_user_inputs'] as List<dynamic>?;
    final String replyText =
        (decoded['generated_text'] as String?) ?? _fallbackFromList(responses);

    final ChatMessage reply = ChatMessage(
      author: ChatAuthor.assistant,
      text: replyText,
    );

    return ChatResult(
      reply: reply,
      pastUserInputs: (pastInputs ?? const <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(growable: false),
      generatedResponses: (responses ?? const <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(growable: false),
    );
  }

  ChatResult _mapChatCompletionsResult({
    required Map<String, dynamic> decoded,
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
  }) {
    final List<dynamic>? choices = decoded['choices'] as List<dynamic>?;
    final Map<String, dynamic>? firstChoice =
        (choices != null && choices.isNotEmpty)
        ? choices.first as Map<String, dynamic>?
        : null;
    final dynamic message = firstChoice?['message'];
    final String replyText = _extractAssistantContent(message);

    final ChatMessage reply = ChatMessage(
      author: ChatAuthor.assistant,
      text: replyText,
    );

    return ChatResult(
      reply: reply,
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, replyText],
    );
  }

  static String _fallbackFromList(List<dynamic>? list) {
    if (list == null || list.isEmpty) {
      return 'I\'m not sure how to respond yet.';
    }
    return list.last.toString();
  }

  static String _extractAssistantContent(dynamic message) {
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
    return 'I\'m not sure how to respond yet.';
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
}
