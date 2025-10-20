part of 'chat_cubit.dart';

mixin _ChatCubitMessageActions on _ChatCubitCore, _ChatCubitHelpers {
  Future<void> sendMessage(final String message) async {
    if (state.isLoading) {
      return;
    }
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
        status: ChatStatus.loading,
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
          status: ChatStatus.success,
        ),
      );

      await _persistHistory(finalHistory);
    } on ChatException catch (error, stackTrace) {
      AppLogger.error('ChatCubit.sendMessage failed', error, stackTrace);
      emit(
        state.copyWith(
          isLoading: false,
          error: error.message,
          status: ChatStatus.error,
        ),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error('ChatCubit.sendMessage failed', error, stackTrace);
      emit(
        state.copyWith(
          isLoading: false,
          error: error.toString(),
          status: ChatStatus.error,
        ),
      );
    }
  }
}
