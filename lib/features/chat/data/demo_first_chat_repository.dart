import 'package:flutter_bloc_app/features/chat/data/chat_direct_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_model_ids.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';

/// Tries the Render orchestration repository first, then the composite
/// repository on retryable Render failures (unless strict). Resolves `auto`
/// for composite to 20B.
class DemoFirstChatRepository implements ChatRepository {
  DemoFirstChatRepository({
    required final ChatRepository renderRepository,
    required final ChatRepository compositeRepository,
    required final bool Function() isRenderAttemptedFirst,
    required final bool Function() isRenderStrict,
  }) : _render = renderRepository,
       _composite = compositeRepository,
       _isRenderAttemptedFirst = isRenderAttemptedFirst,
       _isRenderStrict = isRenderStrict;

  final ChatRepository _render;
  final ChatRepository _composite;
  final bool Function() _isRenderAttemptedFirst;
  final bool Function() _isRenderStrict;

  @override
  ChatInferenceTransport? get chatRemoteTransportHint {
    if (_isRenderAttemptedFirst()) {
      return ChatInferenceTransport.renderOrchestration;
    }
    return _composite.chatRemoteTransportHint;
  }

  String? _compositeModel(final String? model) {
    final String? trimmed = model?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    if (trimmed == kChatOrchestrationAutoModelId) {
      return 'openai/gpt-oss-20b';
    }
    return trimmed;
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
    if (!_isRenderAttemptedFirst()) {
      return _composite.sendMessage(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: _compositeModel(model),
        conversationId: conversationId,
        clientMessageId: clientMessageId,
      );
    }

    try {
      return await _render.sendMessage(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: model,
        conversationId: conversationId,
        clientMessageId: clientMessageId,
      );
    } on ChatRemoteFailureException catch (e) {
      if (_isRenderStrict() || !e.retryable) {
        rethrow;
      }
      return _composite.sendMessage(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: _compositeModel(model),
        conversationId: conversationId,
        clientMessageId: clientMessageId,
      );
    } on ChatException catch (e) {
      if (_isRenderStrict()) {
        rethrow;
      }
      final ChatRemoteFailureException mapped = mapDirectChatException(e);
      if (!mapped.retryable) {
        throw mapped;
      }
      return _composite.sendMessage(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: _compositeModel(model),
        conversationId: conversationId,
        clientMessageId: clientMessageId,
      );
    }
  }
}
