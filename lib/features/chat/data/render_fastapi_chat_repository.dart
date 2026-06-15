import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_remote_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_render_orchestration_diagnostics.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/render_caller_auth_header_provider.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

part 'render_fastapi_chat_repository_send.part.dart';

final Random _renderClientCorrelationRandom = Random.secure();

String _newRenderClientCorrelationId() {
  final int a = _renderClientCorrelationRandom.nextInt(0x7fffffff);
  final int b = _renderClientCorrelationRandom.nextInt(0x7fffffff);
  return 'flutter-${DateTime.now().toUtc().microsecondsSinceEpoch}-$a-$b';
}

/// Remote chat via Render FastAPI orchestration (`POST /v1/chat/completions`).
class RenderFastApiChatRepository implements ChatRepository {
  RenderFastApiChatRepository({
    required this._dio,
    required this._payloadBuilder,
    required this._responseParser,
    required this._callerAuth,
    required this._hfTokenProvider,
    required this._isRunnable,
  });

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
  }) => sendMessageImpl(
    pastUserInputs: pastUserInputs,
    generatedResponses: generatedResponses,
    prompt: prompt,
    model: model,
    conversationId: conversationId,
    clientMessageId: clientMessageId,
  );
}
