import 'package:flutter_bloc_app/features/chat/data/chat_remote_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/data/huggingface_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:networking/networking.dart';

bool _defaultAllowLocalFallback() => false;

/// Picks Supabase Edge first when the user session allows, then optional direct
/// HF fallback for allowed Edge failures while **online** only.
class CompositeChatRepository implements ChatRepository {
  CompositeChatRepository({
    required ChatRepository supabaseRepository,
    required HuggingfaceChatRepository directRepository,
    required NetworkStatusService networkStatusService,
    required this._isSupabaseProxyRunnable,
    required this._isDirectPolicyAllowed,
    this._allowLocalFallback = _defaultAllowLocalFallback,
  }) : _supabase = supabaseRepository,
       _direct = directRepository,
       _networkStatus = networkStatusService;

  final ChatRepository _supabase;
  final HuggingfaceChatRepository _direct;
  final NetworkStatusService _networkStatus;
  final bool Function() _isSupabaseProxyRunnable;
  final bool Function() _isDirectPolicyAllowed;
  final bool Function() _allowLocalFallback;

  bool get _proxyRunnable => _isSupabaseProxyRunnable();

  /// Direct HF when a client key exists and product/build policy allows it.
  bool get _canUseDirect => _direct.hasApiKey && _isDirectPolicyAllowed();

  bool get _canUseLocalFallback =>
      _allowLocalFallback() && !_proxyRunnable && !_canUseDirect;

  @override
  ChatRemotePath? get chatRemoteTransportHint {
    if (_proxyRunnable) {
      return ChatRemotePath.edgeProxy;
    }
    if (_canUseDirect) {
      return ChatRemotePath.directApi;
    }
    return null;
  }

  bool _shouldEdgeFailureFallbackToDirect(ChatRemoteFailureException e) {
    if (!e.isEdge || !e.retryable) {
      return false;
    }
    return e.code == 'upstream_timeout' || e.code == 'upstream_unavailable';
  }

  Future<ChatResult> _sendSupabase({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) => _supabase.sendMessage(
    pastUserInputs: pastUserInputs,
    generatedResponses: generatedResponses,
    prompt: prompt,
    model: model,
    conversationId: conversationId,
    clientMessageId: clientMessageId,
  );

  Future<ChatResult> _sendViaDirect({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) async {
    try {
      return await _direct.sendMessage(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: model,
        conversationId: conversationId,
        clientMessageId: clientMessageId,
      );
    } on ChatException catch (e) {
      throw mapDirectChatException(e);
    }
  }

  ChatResult _sendViaLocalFallback({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? clientMessageId,
  }) {
    final List<String> nextPastInputs = <String>[...pastUserInputs, prompt];
    const String text = 'Backend disabled on web: using local demo response.';
    final List<String> nextGenerated = <String>[...generatedResponses, text];

    return ChatResult(
      reply: ChatMessage(
        author: ChatAuthor.assistant,
        text: text,
        clientMessageId: clientMessageId,
        createdAt: DateTime.now(),
      ),
      pastUserInputs: nextPastInputs,
      generatedResponses: nextGenerated,
    );
  }

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) async {
    final NetworkStatus connectivity = await _networkStatus.getCurrentStatus();
    final bool offline = connectivity == NetworkStatus.offline;

    if (_canUseLocalFallback) {
      return _sendViaLocalFallback(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        clientMessageId: clientMessageId,
      );
    }

    if (offline) {
      throw const ChatRemoteFailureException(
        'No network route for remote chat.',
        code: 'upstream_unavailable',
        retryable: true,
        isEdge: false,
      );
    }

    if (_proxyRunnable) {
      try {
        return await _sendSupabase(
          pastUserInputs: pastUserInputs,
          generatedResponses: generatedResponses,
          prompt: prompt,
          model: model,
          conversationId: conversationId,
          clientMessageId: clientMessageId,
        );
      } on ChatRemoteFailureException catch (e) {
        if (_canUseDirect && _shouldEdgeFailureFallbackToDirect(e)) {
          return _sendViaDirect(
            pastUserInputs: pastUserInputs,
            generatedResponses: generatedResponses,
            prompt: prompt,
            model: model,
            conversationId: conversationId,
            clientMessageId: clientMessageId,
          );
        }
        rethrow;
      }
    }

    if (_canUseDirect) {
      return _sendViaDirect(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: model,
        conversationId: conversationId,
        clientMessageId: clientMessageId,
      );
    }

    throw const ChatRemoteFailureException(
      'Sign in required for cloud chat, and no direct Hugging Face key is available.',
      code: 'auth_required',
      retryable: false,
      isEdge: false,
    );
  }
}
