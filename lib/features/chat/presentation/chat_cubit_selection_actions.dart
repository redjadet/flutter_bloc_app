part of 'chat_cubit.dart';

mixin _ChatCubitSelectionActions on _ChatCubitCore, _ChatCubitHelpers {
  void selectModel(final String model) {
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

    _emitConversationSnapshot(
      active: conversation,
      history: history,
      currentModel: normalized,
      isLoading: false,
      clearError: true,
    );

    unawaited(_persistHistory(history));
  }

  void selectConversation(final String conversationId) {
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

    _emitConversationSnapshot(
      active: conversation,
      history: state.history,
      currentModel: resolvedModel,
    );
  }
}
