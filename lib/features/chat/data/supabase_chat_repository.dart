import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_payload_builder.dart';
import 'package:flutter_bloc_app/features/chat/data/supabase_chat_edge_function_exception_mapper.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_chat_repository_edge.part.dart';

/// Remote chat via Supabase Edge `chat-complete` (HF proxy). Contract:
/// `supabase/README.md`.
class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository({
    required this._payloadBuilder,
    final String? Function()? readAccessToken,
    final String? Function()? readAnonKey,
    final Future<void> Function()? refreshSessionAfter401,
    final Future<FunctionResponse> Function({
      required String accessToken,
      required String anonKey,
      required Map<String, dynamic> body,
    })?
    invoke,
  }) : _readAccessToken = readAccessToken ?? _defaultReadAccessToken,
       _readAnonKey = readAnonKey ?? _defaultReadAnonKey,
       _refreshSessionAfter401 =
           refreshSessionAfter401 ?? _defaultRefreshSessionAfter401,
       _invoke = invoke ?? _defaultInvoke;

  static const String functionName = 'chat-complete';
  static const int _schemaVersion = 1;
  static const String authorizationHeader = 'Authorization';

  final HuggingFacePayloadBuilder _payloadBuilder;
  final String? Function() _readAccessToken;
  final String? Function() _readAnonKey;
  final Future<void> Function() _refreshSessionAfter401;
  final Future<FunctionResponse> Function({
    required String accessToken,
    required String anonKey,
    required Map<String, dynamic> body,
  })
  _invoke;

  @override
  ChatInferenceTransport? get chatRemoteTransportHint {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      return null;
    }
    final String? token = _readAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return ChatInferenceTransport.supabase;
  }

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    if (!SupabaseBootstrapService.isSupabaseInitialized) {
      throw const ChatRemoteFailureException(
        'Supabase is not configured for chat.',
        code: 'missing_configuration',
        retryable: false,
        isEdge: true,
      );
    }

    String? token = _readAccessToken();
    if (token == null || token.isEmpty) {
      throw const ChatRemoteFailureException(
        'Sign in required to use cloud chat.',
        code: 'auth_required',
        retryable: false,
        isEdge: true,
      );
    }

    final String? requestedModel = model?.trim();
    final String? hfModelConfig = SecretConfig.huggingfaceModel?.trim();
    final String buildPayloadModel =
        (requestedModel != null && requestedModel.isNotEmpty)
        ? requestedModel
        : ((hfModelConfig != null && hfModelConfig.isNotEmpty)
              ? hfModelConfig
              : 'openai/gpt-oss-20b');

    final Map<String, dynamic> hfPayload = _payloadBuilder
        .buildChatCompletionsPayload(
          pastUserInputs: pastUserInputs,
          generatedResponses: generatedResponses,
          prompt: prompt,
          model: buildPayloadModel,
        );

    final List<dynamic>? messagesRaw = hfPayload['messages'] as List<dynamic>?;
    if (messagesRaw == null || messagesRaw.isEmpty) {
      throw const ChatRemoteFailureException(
        'Invalid chat payload.',
        code: 'invalid_request',
        retryable: false,
        isEdge: true,
      );
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'schemaVersion': _schemaVersion,
      'messages': messagesRaw,
      'clientMessageId': (clientMessageId != null && clientMessageId.isNotEmpty)
          ? clientMessageId
          : 'client_${DateTime.now().toUtc().microsecondsSinceEpoch}',
    };
    if (requestedModel != null && requestedModel.isNotEmpty) {
      body['model'] = requestedModel;
    }

    try {
      return await invokeEdgeAndParse(
        token: token,
        body: body,
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
      );
    } on FunctionException catch (e) {
      if (e.status == 401 && SupabaseBootstrapService.isSupabaseInitialized) {
        try {
          await _refreshSessionAfter401();
          token = _readAccessToken();
          if (token != null && token.isNotEmpty) {
            try {
              return await invokeEdgeAndParse(
                token: token,
                body: body,
                pastUserInputs: pastUserInputs,
                generatedResponses: generatedResponses,
                prompt: prompt,
              );
            } on FunctionException catch (retryErr) {
              throw mapSupabaseChatCompleteFunctionException(retryErr);
            }
          }
        } on ChatRemoteFailureException {
          rethrow;
        } on Object {
          // Refresh failed or token missing after refresh; map original 401 below.
        }
      }
      throw mapSupabaseChatCompleteFunctionException(e);
    }
  }
}
