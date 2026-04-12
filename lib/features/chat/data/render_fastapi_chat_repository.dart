import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/render_caller_auth_header_provider.dart';
import 'package:flutter_bloc_app/features/chat/data/render_chat_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/data/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

/// Remote chat via Render FastAPI orchestration (`POST /v1/chat/completions`).
class RenderFastApiChatRepository implements ChatRepository {
  RenderFastApiChatRepository({
    required final Dio dio,
    required final HuggingFacePayloadBuilder payloadBuilder,
    required final HuggingFaceResponseParser responseParser,
    required final RenderCallerAuthHeaderProvider callerAuth,
    required final RenderOrchestrationHfTokenProvider hfTokenProvider,
    required final bool Function() isRunnable,
  }) : _dio = dio,
       _payloadBuilder = payloadBuilder,
       _responseParser = responseParser,
       _callerAuth = callerAuth,
       _hfTokenProvider = hfTokenProvider,
       _isRunnable = isRunnable;

  final Dio _dio;
  final HuggingFacePayloadBuilder _payloadBuilder;
  final HuggingFaceResponseParser _responseParser;
  final RenderCallerAuthHeaderProvider _callerAuth;
  final RenderOrchestrationHfTokenProvider _hfTokenProvider;
  final bool Function() _isRunnable;

  @override
  ChatInferenceTransport? get chatRemoteTransportHint =>
      _isRunnable() ? ChatInferenceTransport.renderOrchestration : null;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    if (!_isRunnable()) {
      throw const ChatRemoteFailureException(
        'Render orchestration is not configured.',
        code: 'upstream_unavailable',
        retryable: false,
        isEdge: false,
      );
    }

    final String? idToken = await _callerAuth.bearerIdToken();
    if (idToken == null || idToken.trim().isEmpty) {
      throw const ChatRemoteFailureException(
        'Sign in required for Render chat demo.',
        code: 'auth_required',
        retryable: false,
        isEdge: false,
      );
    }

    final String? hfToken = await _hfTokenProvider.readHfTokenForUpstream();
    if (hfToken == null || hfToken.isEmpty) {
      throw const ChatRemoteFailureException(
        'Missing Hugging Face read token for orchestration.',
        code: 'token_missing',
        retryable: false,
        isEdge: false,
      );
    }

    final String? trimmedModel = model?.trim();
    final String targetModel = (trimmedModel != null && trimmedModel.isNotEmpty)
        ? trimmedModel
        : kChatOrchestrationAutoModelId;

    final Map<String, dynamic> payload = _payloadBuilder.buildChatCompletionsPayload(
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      prompt: prompt,
      model: targetModel,
    );

    final String idempotencyKey = _idempotencyKey(clientMessageId, conversationId);

    final Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer $idToken',
      'X-HF-Authorization': 'Bearer $hfToken',
      'Idempotency-Key': idempotencyKey,
    };
    final String demoSecret = SecretConfig.chatRenderDemoSecret.trim();
    if (demoSecret.isNotEmpty) {
      headers['X-Render-Demo-Secret'] = demoSecret;
    }

    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        '/v1/chat/completions',
        data: payload,
        options: Options(headers: headers),
      );
      final int? status = response.statusCode;
      if (status == null || status < 200 || status >= 300) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Unexpected status $status',
        );
      }
      final Map<String, dynamic>? json = mapFromDynamic(response.data);
      if (json == null) {
        throw const ChatRemoteFailureException(
          'Invalid response body.',
          code: 'invalid_request',
          retryable: false,
          isEdge: false,
        );
      }
      final ChatResult parsed = _responseParser.buildChatCompletionsResult(
        json: json,
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
      );
      return ChatResult(
        reply: parsed.reply,
        pastUserInputs: parsed.pastUserInputs,
        generatedResponses: parsed.generatedResponses,
        transportUsed: ChatInferenceTransport.renderOrchestration,
      );
    } on ChatRemoteFailureException {
      rethrow;
    } on DioException catch (e) {
      throw mapRenderChatFailure(e);
    } catch (e) {
      throw mapRenderChatFailure(e);
    }
  }

  String _idempotencyKey(final String? clientMessageId, final String? conversationId) {
    final String? a = clientMessageId?.trim();
    if (a != null && a.isNotEmpty) {
      return a;
    }
    final String? b = conversationId?.trim();
    if (b != null && b.isNotEmpty) {
      return b;
    }
    return 'render-${DateTime.now().toUtc().microsecondsSinceEpoch}';
  }
}
