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
    if (state.activeConversationId == conversationId &&
        state.messages.isNotEmpty) {
      return;
    }

    List<ChatConversation> targetHistory = state.history;

    ChatConversation? conversation;
    final _LoadedConversation? loaded = await _loadConversationFromRepository(
      conversationId,
      existingHistory: targetHistory,
    );
    if (loaded != null) {
      conversation = loaded.conversation;
      targetHistory = loaded.history;
    }

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

    // Keep the selected conversation (potentially hydrated) in memory so subsequent
    // selections and UI rebuilds use the full copy with messages.
    targetHistory = _replaceConversation(conversation, history: targetHistory);

    // If messages are missing but transcripts exist (legacy persisted data),
    // rebuild a minimal message timeline so the UI shows prior content.
    if (conversation.messages.isEmpty &&
        (conversation.pastUserInputs.isNotEmpty ||
            conversation.generatedResponses.isNotEmpty)) {
      final ChatConversation rebuilt = _rebuildFromTranscripts(conversation);
      targetHistory = _replaceConversation(rebuilt, history: targetHistory);
      conversation = rebuilt;
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
    final List<ChatConversation> sourceHistory = refreshed.isNotEmpty
        ? refreshed
        : existingHistory;
    if (sourceHistory.isEmpty) {
      return null;
    }
    final List<ChatConversation> mergedHistory = _sortHistory(sourceHistory);
    final ChatConversation? found = _conversationById(
      mergedHistory,
      conversationId,
    );
    // If nothing matches, don't set an active selection.
    if (found == null) {
      return null;
    }
    return _LoadedConversation(
      conversation: found,
      history: mergedHistory,
    );
  }

  ChatConversation _rebuildFromTranscripts(
    final ChatConversation conversation,
  ) {
    final List<ChatMessage> messages = <ChatMessage>[];
    final int pairs = conversation.pastUserInputs.length;
    final int responses = conversation.generatedResponses.length;
    for (int i = 0; i < pairs; i++) {
      final String userText = conversation.pastUserInputs[i];
      messages.add(
        ChatMessage(
          author: ChatAuthor.user,
          text: userText,
          createdAt: conversation.createdAt.add(Duration(seconds: i * 2)),
        ),
      );
      if (i < responses) {
        final String reply = conversation.generatedResponses[i];
        messages.add(
          ChatMessage(
            author: ChatAuthor.assistant,
            text: reply,
            createdAt: conversation.createdAt.add(Duration(seconds: i * 2 + 1)),
          ),
        );
      }
    }
    return conversation.copyWith(messages: messages);
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
