part of 'supabase_chat_repository.dart';

extension _SupabaseChatRepositoryEdge on SupabaseChatRepository {
  Future<ChatResult> invokeEdgeAndParse({
    required final String token,
    required final Map<String, dynamic> body,
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
  }) async {
    final FunctionResponse response = await invokeEdge(
      token: token,
      body: body,
    );
    return parseSuccess(
      response,
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      prompt: prompt,
    );
  }

  Future<FunctionResponse> invokeEdge({
    required final String token,
    required final Map<String, dynamic> body,
  }) async {
    final String? anonKey = _readAnonKey();
    if (anonKey == null || anonKey.isEmpty) {
      throw const ChatRemoteFailureException(
        'Supabase anon key is not configured.',
        code: 'missing_configuration',
        retryable: false,
        isEdge: true,
      );
    }
    return _invoke(accessToken: token, anonKey: anonKey, body: body);
  }

  ChatResult parseSuccess(
    final FunctionResponse response, {
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
  }) {
    if (response.status != 200) {
      throw ChatRemoteFailureException(
        'Edge chat-complete failed (HTTP ${response.status}).',
        code: 'upstream_unavailable',
        retryable: response.status >= 500,
        isEdge: true,
      );
    }

    final Object? raw = response.data;
    if (raw is! Map) {
      throw const ChatRemoteFailureException(
        'Invalid response from chat-complete.',
        code: 'upstream_unavailable',
        retryable: true,
        isEdge: true,
      );
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
    final Object? assistantRaw = map['assistantMessage'];
    if (assistantRaw is! Map) {
      throw const ChatRemoteFailureException(
        'Response missing assistantMessage.',
        code: 'upstream_unavailable',
        retryable: true,
        isEdge: true,
      );
    }
    final Map<String, dynamic> assistant = Map<String, dynamic>.from(
      assistantRaw,
    );
    final String? content = assistant['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw const ChatRemoteFailureException(
        'Empty assistant content.',
        code: 'upstream_unavailable',
        retryable: true,
        isEdge: true,
      );
    }

    return ChatResult(
      reply: ChatMessage(author: ChatAuthor.assistant, text: content.trim()),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, content.trim()],
      transportUsed: ChatRemotePath.edgeProxy,
    );
  }
}

String? _defaultReadAccessToken() =>
    Supabase.instance.client.auth.currentSession?.accessToken;

String? _defaultReadAnonKey() => SecretConfig.supabaseAnonKey;

Future<void> _defaultRefreshSessionAfter401() =>
    Supabase.instance.client.auth.refreshSession();

Future<FunctionResponse> _defaultInvoke({
  required final String accessToken,
  required final String anonKey,
  required final Map<String, dynamic> body,
}) {
  return Supabase.instance.client.functions.invoke(
    SupabaseChatRepository.functionName,
    headers: <String, String>{
      SupabaseChatRepository.authorizationHeader: 'Bearer $accessToken',
      'apikey': anonKey,
    },
    body: body,
  );
}
