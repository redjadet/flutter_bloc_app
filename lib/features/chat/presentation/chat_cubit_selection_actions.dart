part of 'chat_cubit.dart';

mixin _ChatCubitSelectionActions on _ChatCubitCore, _ChatCubitHelpers {
  void selectModel(String model) {
    final String? normalized = _normalize(model);
    if (normalized == null ||
        !_models.contains(normalized) ||
        state.currentModel == normalized) {
      return;
    }

    final ChatConversation conversation = _createEmptyConversation(
      model: normalized,
    );
    final List<ChatConversation> history = _replaceConversation(conversation);

    emit(
      state.copyWith(
        currentModel: normalized,
        messages: conversation.messages,
        pastUserInputs: conversation.pastUserInputs,
        generatedResponses: conversation.generatedResponses,
        history: history,
        activeConversationId: conversation.id,
        isLoading: false,
        error: null,
        status: ChatStatus.success,
      ),
    );

    unawaited(_persistHistory(history));
  }

  void selectConversation(String conversationId) {
    if (state.activeConversationId == conversationId) {
      return;
    }

    final ChatConversation? conversation = _conversationById(
      state.history,
      conversationId,
    );
    if (conversation == null) {
      return;
    }

    final String resolvedModel = _resolveModelForConversation(conversation);

    emit(
      state.copyWith(
        activeConversationId: conversation.id,
        messages: conversation.messages,
        pastUserInputs: conversation.pastUserInputs,
        generatedResponses: conversation.generatedResponses,
        currentModel: resolvedModel,
        status: ChatStatus.success,
      ),
    );
  }
}
