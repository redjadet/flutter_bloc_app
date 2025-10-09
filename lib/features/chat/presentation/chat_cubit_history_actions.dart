part of 'chat_cubit.dart';

mixin _ChatCubitHistoryActions on _ChatCubitCore, _ChatCubitHelpers {
  Future<void> loadHistory() async {
    final List<ChatConversation> stored = await _historyRepository.load();
    final List<ChatConversation> filtered = stored
        .where((ChatConversation c) => c.hasContent)
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
      if (history.any((ChatConversation c) => c.id == active!.id)) {
        history = _replaceConversation(active, history: history);
        needsPersist = true;
      }
    }

    if (needsPersist) {
      await _persistHistory(history);
    }

    emit(
      state.copyWith(
        history: history,
        activeConversationId: active.id,
        messages: active.messages,
        pastUserInputs: active.pastUserInputs,
        generatedResponses: active.generatedResponses,
        currentModel: resolvedModel,
        status: ChatStatus.success,
      ),
    );
  }

  Future<void> clearHistory() async {
    if (state.history.isEmpty) {
      final ChatConversation fresh = _createEmptyConversation(
        model: _currentModel,
      );
      emit(
        state.copyWith(
          history: const <ChatConversation>[],
          activeConversationId: fresh.id,
          messages: fresh.messages,
          pastUserInputs: fresh.pastUserInputs,
          generatedResponses: fresh.generatedResponses,
          isLoading: false,
          error: null,
          status: ChatStatus.success,
        ),
      );
      return;
    }

    await _historyRepository.save(const <ChatConversation>[]);
    final ChatConversation fresh = _createEmptyConversation(
      model: _currentModel,
    );
    emit(
      state.copyWith(
        history: const <ChatConversation>[],
        activeConversationId: fresh.id,
        messages: fresh.messages,
        pastUserInputs: fresh.pastUserInputs,
        generatedResponses: fresh.generatedResponses,
        isLoading: false,
        error: null,
        status: ChatStatus.success,
      ),
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    final List<ChatConversation> history = List<ChatConversation>.from(
      state.history,
    );
    final int index = history.indexWhere(
      (ChatConversation c) => c.id == conversationId,
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
      emit(
        state.copyWith(
          history: const <ChatConversation>[],
          activeConversationId: fresh.id,
          messages: fresh.messages,
          pastUserInputs: fresh.pastUserInputs,
          generatedResponses: fresh.generatedResponses,
          currentModel: _currentModel,
          status: ChatStatus.success,
        ),
      );
      return;
    }

    final ChatConversation desiredActive =
        state.activeConversationId == conversationId
        ? history.first
        : _conversationById(history, state.activeConversationId) ??
              history.first;
    final String resolvedModel = _resolveModelForConversation(desiredActive);

    emit(
      state.copyWith(
        history: history,
        activeConversationId: desiredActive.id,
        messages: desiredActive.messages,
        pastUserInputs: desiredActive.pastUserInputs,
        generatedResponses: desiredActive.generatedResponses,
        currentModel: resolvedModel,
        status: ChatStatus.success,
      ),
    );
  }

  Future<void> resetConversation() async {
    final ChatConversation conversation = _createEmptyConversation(
      model: _currentModel,
    );
    final List<ChatConversation> history = _replaceConversation(conversation);

    emit(
      state.copyWith(
        messages: conversation.messages,
        isLoading: false,
        error: null,
        pastUserInputs: conversation.pastUserInputs,
        generatedResponses: conversation.generatedResponses,
        history: history,
        activeConversationId: conversation.id,
        status: ChatStatus.success,
      ),
    );

    await _persistHistory(history);
  }
}
