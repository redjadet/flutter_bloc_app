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

  Future<void> selectConversation(final String conversationId) async {
    if (state.activeConversationId == conversationId) {
      return;
    }

    List<ChatConversation> targetHistory = state.history;

    final _LoadedConversation? loaded = await _loadConversationFromRepository(
      conversationId,
      existingHistory: targetHistory,
    );
    ChatConversation? conversation = loaded?.conversation;
    targetHistory = loaded?.history ?? targetHistory;

    conversation ??= _conversationById(targetHistory, conversationId);
    if (conversation == null) {
      return;
    }

    final String resolvedModel = _resolveModelForConversation(conversation);

    // Re-hydrate the conversation from storage if the in-memory copy has empty messages
    // (can happen when history list is built from trimmed snapshots or after app restart).
    // This ensures we load the full conversation data from persistent storage.
    if (conversation.messages.isEmpty && conversation.hasContent) {
      final List<ChatConversation> refreshed = await _historyRepository.load();
      final ChatConversation? hydrated = _conversationById(
        refreshed,
        conversationId,
      );
      if (hydrated != null && hydrated.messages.isNotEmpty) {
        conversation = hydrated;
        targetHistory = _replaceConversation(hydrated, history: refreshed);
      } else if (hydrated != null) {
        // Use hydrated version even if messages are still empty, to ensure consistency
        conversation = hydrated;
        targetHistory = _replaceConversation(hydrated, history: refreshed);
      }
    } else if (conversation.messages.isEmpty) {
      // Even if hasContent is false, try to re-hydrate in case storage has the data
      final List<ChatConversation> refreshed = await _historyRepository.load();
      final ChatConversation? hydrated = _conversationById(
        refreshed,
        conversationId,
      );
      if (hydrated != null && hydrated.messages.isNotEmpty) {
        conversation = hydrated;
        targetHistory = _replaceConversation(hydrated, history: refreshed);
      }
    }

    _emitConversationSnapshot(
      active: conversation,
      history: targetHistory,
      currentModel: resolvedModel,
      clearError: true,
      isLoading: false,
    );
  }

  Future<_LoadedConversation?> _loadConversationFromRepository(
    final String conversationId, {
    required final List<ChatConversation> existingHistory,
  }) async {
    final List<ChatConversation> refreshed = await _historyRepository.load();
    // Use refreshed if available, otherwise fall back to existingHistory
    final List<ChatConversation> sourceHistory =
        refreshed.isNotEmpty ? refreshed : existingHistory;
    if (sourceHistory.isEmpty) {
      return null;
    }
    final List<ChatConversation> mergedHistory = _sortHistory(sourceHistory);
    final ChatConversation? found = _conversationById(
      mergedHistory,
      conversationId,
    );
    if (found == null) {
      return null;
    }
    return _LoadedConversation(
      conversation: found,
      history: mergedHistory,
    );
  }
}

class _LoadedConversation {
  _LoadedConversation({
    required this.conversation,
    required this.history,
  });

  final ChatConversation conversation;
  final List<ChatConversation> history;
}
