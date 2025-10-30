part of 'chat_cubit.dart';

mixin _ChatCubitHistoryActions on _ChatCubitCore, _ChatCubitHelpers {
  Future<void> loadHistory() async {
    final List<ChatConversation> stored = await _historyRepository.load();
    final List<ChatConversation> filtered = stored
        .where((final ChatConversation c) => c.hasContent)
        .toList();
    List<ChatConversation> history = _sortHistory(filtered);
    bool needsPersist = filtered.length != stored.length;

    ChatConversation? active = _conversationById(
      history,
      state.activeConversationId,
    );

    active ??= history.isNotEmpty ? history.first : null;

    active ??= _createEmptyConversation(model: state.currentModel);

    final String resolvedModel = _resolveModelForConversation(active);
    if (active.model != resolvedModel) {
      active = active.copyWith(model: resolvedModel);
      if (history.any((final ChatConversation c) => c.id == active!.id)) {
        history = _replaceConversation(active, history: history);
        needsPersist = true;
      }
    }

    if (needsPersist) {
      await _persistHistory(history);
    }

    _emitConversationSnapshot(
      active: active,
      history: history,
      currentModel: resolvedModel,
    );
  }

  Future<void> clearHistory() async {
    if (state.history.isEmpty) {
      final ChatConversation fresh = _createEmptyConversation(
        model: _currentModel,
      );
      _emitConversationSnapshot(
        active: fresh,
        history: const <ChatConversation>[],
        isLoading: false,
        clearError: true,
      );
      return;
    }

    await _historyRepository.save(const <ChatConversation>[]);
    final ChatConversation fresh = _createEmptyConversation(
      model: _currentModel,
    );
    _emitConversationSnapshot(
      active: fresh,
      history: const <ChatConversation>[],
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> deleteConversation(final String conversationId) async {
    final List<ChatConversation> history = List<ChatConversation>.from(
      state.history,
    );
    final int index = history.indexWhere(
      (final ChatConversation c) => c.id == conversationId,
    );
    if (index < 0) {
      return;
    }

    history.removeAt(index);
    await _historyRepository.save(history);

    if (history.isEmpty) {
      final ChatConversation fresh = _createEmptyConversation(
        model: _currentModel,
      );
      _emitConversationSnapshot(
        active: fresh,
        history: const <ChatConversation>[],
        currentModel: _currentModel,
      );
      return;
    }

    final ChatConversation desiredActive =
        state.activeConversationId == conversationId
        ? history.first
        : _conversationById(history, state.activeConversationId) ??
              history.first;
    final String resolvedModel = _resolveModelForConversation(desiredActive);

    _emitConversationSnapshot(
      active: desiredActive,
      history: history,
      currentModel: resolvedModel,
    );
  }

  Future<void> resetConversation() async {
    final ChatConversation conversation = _createEmptyConversation(
      model: _currentModel,
    );
    final List<ChatConversation> history = _replaceConversation(conversation);

    _emitConversationSnapshot(
      active: conversation,
      history: history,
      isLoading: false,
      clearError: true,
    );

    await _persistHistory(history);
  }
}
