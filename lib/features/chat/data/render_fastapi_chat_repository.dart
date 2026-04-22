import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_render_orchestration_diagnostics.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/render_caller_auth_header_provider.dart';
import 'package:flutter_bloc_app/features/chat/data/render_chat_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/data/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

final Random _renderClientCorrelationRandom = Random.secure();

String _newRenderClientCorrelationId() {
  final int a = _renderClientCorrelationRandom.nextInt(0x7fffffff);
  final int b = _renderClientCorrelationRandom.nextInt(0x7fffffff);
  return 'flutter-${DateTime.now().toUtc().microsecondsSinceEpoch}-$a-$b';
}

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
      if (kDebugMode) {
        AppLogger.info(
          'Chat: RenderFastApi.sendMessage blocked at isRunnable gate '
          '(DemoFirst may fall through to composite).',
        );
        logChatRenderOrchestrationIfDebug('render_repo_not_runnable');
      }
      throw const ChatRemoteFailureException(
        'Render orchestration is not configured.',
        code: 'upstream_unavailable',
        retryable: false,
        isEdge: false,
      );
    }

    final String? idToken = await _callerAuth.bearerIdToken();
    if (idToken == null || idToken.trim().isEmpty) {
      if (kDebugMode) {
        AppLogger.info(
          'Chat: RenderFastApi.sendMessage blocked: caller idToken empty '
          '(Firebase ID token for Authorization header).',
        );
      }
      throw const ChatRemoteFailureException(
        'Sign in required for Render chat demo.',
        code: 'auth_required',
        retryable: false,
        isEdge: false,
      );
    }

    final String? hfToken = await _hfTokenProvider.readHfTokenForUpstream();
    if (hfToken == null || hfToken.isEmpty) {
      if (kDebugMode) {
        AppLogger.info(
          'Chat: RenderFastApi.sendMessage blocked: HF read token missing '
          '(callable / secure storage / huggingface_api_key).',
        );
      }
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

    final Map<String, dynamic> payload = _payloadBuilder
        .buildChatCompletionsPayload(
          pastUserInputs: pastUserInputs,
          generatedResponses: generatedResponses,
          prompt: prompt,
          model: targetModel,
        );

    final String idempotencyKey = _idempotencyKey(
      clientMessageId,
      conversationId,
    );

    final String clientCorrelationId = _newRenderClientCorrelationId();
    final Map<String, String> headers = <String, String>{
      'Authorization': 'Bearer $idToken',
      'X-HF-Authorization': 'Bearer $hfToken',
      'Idempotency-Key': idempotencyKey,
      'X-Client-Correlation-Id': clientCorrelationId,
    };
    final String demoSecret = SecretConfig.chatRenderDemoSecret.trim();
    if (demoSecret.isNotEmpty) {
      headers['X-Render-Demo-Secret'] = demoSecret;
    }

    if (kDebugMode) {
      AppLogger.info(
        'Chat: RenderFastApi POST /v1/chat/completions '
        'client_correlation_id=$clientCorrelationId idempotency_key=$idempotencyKey',
      );
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
      if (kDebugMode) {
        final Map<String, dynamic>? meta = mapFromDynamic(
          json?['_render_meta'],
        );
        final String? fromBodyServer = stringFromDynamicTrimmed(
          meta?['server_request_id'],
        );
        final String? fromBodyEcho = stringFromDynamicTrimmed(
          meta?['client_correlation_id'],
        );
        final String? fromHeaderServer = response.headers.value(
          'x-server-request-id',
        );
        final String? fromHeaderEcho = response.headers.value(
          'x-client-correlation-id',
        );
        final String? serverRequestId = fromBodyServer ?? fromHeaderServer;
        final String? echoedCorrelation = fromBodyEcho ?? fromHeaderEcho;
        final String idSource = fromBodyServer != null
            ? 'body'
            : (fromHeaderServer != null ? 'headers' : 'none');
        final String? rndrId = response.headers.value('rndr-id');
        AppLogger.info(
          'Chat: RenderFastApi response '
          'client_correlation_id=$clientCorrelationId '
          'x_server_request_id=${serverRequestId ?? "(missing)"} '
          'echoed_x_client_correlation_id=${echoedCorrelation ?? "(missing)"} '
          '(server_request_id source=$idSource; rndr_id=${rndrId ?? "(missing)"})',
        );
        if (serverRequestId == null) {
          AppLogger.info(
            'Chat: RenderFastApi response header keys (diagnostic)='
            '${response.headers.map.keys.toList()}',
          );
          if (json != null) {
            final bool hasRenderMeta = json.containsKey('_render_meta');
            final String? completionId = stringFromDynamicTrimmed(json['id']);
            AppLogger.info(
              'Chat: RenderFastApi response body (diagnostic) '
              '_render_meta=$hasRenderMeta completion_id=${completionId ?? "(missing)"}. '
              'If _render_meta is false, redeploy the FastAPI service from a commit that '
              'includes `_render_meta` in chat completion JSON (see main.py).',
            );
          }
        }
      }
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

  String _idempotencyKey(
    final String? clientMessageId,
    final String? conversationId,
  ) {
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
