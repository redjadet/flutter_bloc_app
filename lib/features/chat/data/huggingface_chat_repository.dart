import 'package:flutter_bloc_app/features/chat/data/huggingface_api_client.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:http/http.dart' as http;

class HuggingfaceChatRepository implements ChatRepository {
  HuggingfaceChatRepository({
    http.Client? client,
    String? apiKey,
    String? model,
    bool useChatCompletions = false,
    HuggingFaceApiClient? apiClient,
    HuggingFacePayloadBuilder? payloadBuilder,
    HuggingFaceResponseParser? responseParser,
  }) : _apiClient =
           apiClient ??
           HuggingFaceApiClient(httpClient: client, apiKey: _normalize(apiKey)),
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

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
  }) async {
    if (!_apiClient.hasApiKey) {
      throw const ChatException('Missing Hugging Face API token.');
    }

    final String? override = _normalize(model);
    return _useChatCompletions
        ? _sendViaChatCompletions(
            pastUserInputs: pastUserInputs,
            generatedResponses: generatedResponses,
            prompt: prompt,
            modelOverride: override,
          )
        : _sendViaInference(
            pastUserInputs: pastUserInputs,
            generatedResponses: generatedResponses,
            prompt: prompt,
            modelOverride: override,
          );
  }

  Future<ChatResult> _sendViaInference({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? modelOverride,
  }) async {
    final String targetModel = modelOverride ?? _model;
    final Map<String, dynamic> payload = _payloadBuilder.buildInferencePayload(
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      prompt: prompt,
    );

    final Map<String, dynamic> json = await _apiClient.postJson(
      uri: Uri.parse('$_inferenceBaseUrl/$targetModel'),
      payload: payload,
      context: 'inference',
    );

    return _responseParser.buildInferenceResult(json);
  }

  Future<ChatResult> _sendViaChatCompletions({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? modelOverride,
  }) async {
    final String targetModel = modelOverride ?? _model;
    final Map<String, dynamic> payload = _payloadBuilder
        .buildChatCompletionsPayload(
          pastUserInputs: pastUserInputs,
          generatedResponses: generatedResponses,
          prompt: prompt,
          model: targetModel,
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

  static String? _normalize(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static const String fallbackMessage = "I'm not sure how to respond yet.";
}
