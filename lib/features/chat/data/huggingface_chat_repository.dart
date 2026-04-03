import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';

class HuggingfaceChatRepository implements ChatRepository {
  HuggingfaceChatRepository({
    final Dio? client,
    final String? apiKey,
    final String? model,
    final bool useChatCompletions = true,
    final HuggingFaceApiClient? apiClient,
    final HuggingFacePayloadBuilder? payloadBuilder,
    final HuggingFaceResponseParser? responseParser,
  }) : _apiClient =
           apiClient ??
           HuggingFaceApiClient(dio: client, apiKey: _normalize(apiKey)),
       _payloadBuilder = payloadBuilder ?? const HuggingFacePayloadBuilder(),
       _responseParser =
           responseParser ??
           const HuggingFaceResponseParser(fallbackMessage: fallbackMessage),
       _model = _normalize(model) ?? _defaultModel,
       _useChatCompletions = useChatCompletions;

  static const String _defaultModel = 'HuggingFaceH4/zephyr-7b-beta';
  static const String _inferenceBaseUrl =
      'https://api-inference.huggingface.co/models';
  static final Uri _chatCompletionsUri = Uri.parse(
    'https://router.huggingface.co/v1/chat/completions',
  );

  final HuggingFaceApiClient _apiClient;
  final HuggingFacePayloadBuilder _payloadBuilder;
  final HuggingFaceResponseParser _responseParser;
  final String _model;
  final bool _useChatCompletions;

  bool get usesChatCompletions => _useChatCompletions;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    if (!_apiClient.hasApiKey) {
      throw const ChatException('Missing Hugging Face API token.');
    }

    final String targetModel = _resolveModel(model);
    if (_useChatCompletions) {
      return _sendViaChatCompletions(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: targetModel,
      );
    }

    try {
      return await _sendViaInference(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: targetModel,
      );
    } on ChatException catch (error) {
      if (!_shouldFallbackToChatCompletions(error)) {
        rethrow;
      }
      return _sendViaChatCompletions(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: targetModel,
      );
    }
  }

  Future<ChatResult> _sendViaInference({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    required final String model,
  }) async {
    final Map<String, dynamic> payload = _payloadBuilder.buildInferencePayload(
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      prompt: prompt,
    );

    final Map<String, dynamic> json = await _apiClient.postJson(
      uri: Uri.parse('$_inferenceBaseUrl/$model'),
      payload: payload,
      context: 'inference',
    );

    return _responseParser.buildInferenceResult(json);
  }

  Future<ChatResult> _sendViaChatCompletions({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    required final String model,
  }) async {
    final Map<String, dynamic> payload = _payloadBuilder
        .buildChatCompletionsPayload(
          pastUserInputs: pastUserInputs,
          generatedResponses: generatedResponses,
          prompt: prompt,
          model: model,
        );

    final Map<String, dynamic> json = await _apiClient.postJson(
      uri: _chatCompletionsUri,
      payload: payload,
      context: 'chat-completions',
    );

    return _responseParser.buildChatCompletionsResult(
      json: json,
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      prompt: prompt,
    );
  }

  String _resolveModel(final String? value) => _normalize(value) ?? _model;

  static String? _normalize(final String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _shouldFallbackToChatCompletions(final ChatException error) {
    final String message = error.message.toLowerCase();
    return message.contains('http 410') &&
        message.contains('api-inference.huggingface.co') &&
        message.contains('router.huggingface.co');
  }

  static const String fallbackMessage = "I'm not sure how to respond yet.";
}
