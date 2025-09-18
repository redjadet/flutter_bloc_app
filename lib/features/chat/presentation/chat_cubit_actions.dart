part of 'chat_cubit.dart';

mixin _ChatCubitActions on _ChatCubitCore, _ChatCubitHelpers {
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
      ),
    );
  }

  Future<void> sendMessage(String message) async {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final ChatConversation baseConversation = _ensureActiveConversation();
    final DateTime now = DateTime.now();

    final ChatConversation withUser = baseConversation.copyWith(
      messages: <ChatMessage>[
        ...baseConversation.messages,
        ChatMessage(author: ChatAuthor.user, text: trimmed),
      ],
      pastUserInputs: <String>[...baseConversation.pastUserInputs, trimmed],
      updatedAt: now,
      model: _currentModel,
    );

    final List<ChatConversation> historyAfterUser = _replaceConversation(
      withUser,
    );

    emit(
      state.copyWith(
        messages: withUser.messages,
        isLoading: true,
        error: null,
        pastUserInputs: withUser.pastUserInputs,
        generatedResponses: withUser.generatedResponses,
        history: historyAfterUser,
        activeConversationId: withUser.id,
      ),
    );

    await _persistHistory(historyAfterUser);

    try {
      final ChatResult result = await _repository.sendMessage(
        pastUserInputs: withUser.pastUserInputs,
        generatedResponses: withUser.generatedResponses,
        prompt: trimmed,
        model: _currentModel,
      );

      final ChatConversation withAssistant = withUser.copyWith(
        messages: <ChatMessage>[...withUser.messages, result.reply],
        pastUserInputs: result.pastUserInputs,
        generatedResponses: result.generatedResponses,
        updatedAt: DateTime.now(),
      );

      final List<ChatConversation> finalHistory = _replaceConversation(
        withAssistant,
      );

      emit(
        state.copyWith(
          messages: withAssistant.messages,
          isLoading: false,
          pastUserInputs: withAssistant.pastUserInputs,
          generatedResponses: withAssistant.generatedResponses,
          history: finalHistory,
          activeConversationId: withAssistant.id,
        ),
      );

      await _persistHistory(finalHistory);
    } on ChatException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
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
      ),
    );

    await _persistHistory(history);
  }

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
      ),
    );
  }
}
