import 'dart:math';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_remote_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_response_parser.dart';
import 'package:flutter_bloc_app/features/chat/data/render_caller_auth_header_provider.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

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
    required this._isRunnable,
    this._logOrchestrationDiagnostics,
  });

  final Dio _dio;
  final HuggingFacePayloadBuilder _payloadBuilder;
  final HuggingFaceResponseParser _responseParser;
  final RenderCallerAuthHeaderProvider _callerAuth;
  final bool Function() _isRunnable;
  final void Function(String tag)? _logOrchestrationDiagnostics;

  @override
  ChatRemotePath? get chatRemoteTransportHint =>
      _isRunnable() ? ChatRemotePath.renderOrchestration : null;

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) => sendMessageImpl(
    pastUserInputs: pastUserInputs,
    generatedResponses: generatedResponses,
    prompt: prompt,
    model: model,
    conversationId: conversationId,
    clientMessageId: clientMessageId,
  );
}
