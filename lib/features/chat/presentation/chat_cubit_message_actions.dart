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
    final String clientMessageId = _generateMessageId(now);

    final ChatConversation withUser = baseConversation.copyWith(
      messages: <ChatMessage>[
        ...baseConversation.messages,
        ChatMessage(
          author: ChatAuthor.user,
          text: trimmed,
          clientMessageId: clientMessageId,
          createdAt: now,
          synchronized: false,
        ),
      ],
      pastUserInputs: <String>[...baseConversation.pastUserInputs, trimmed],
      updatedAt: now,
      model: _currentModel,
    );

    final List<ChatConversation> historyAfterUser = _replaceConversation(
      withUser,
    );

    _emitConversationSnapshot(
      active: withUser,
      history: historyAfterUser,
      isLoading: true,
      clearError: true,
      status: ViewStatus.loading,
    );

    await _persistHistory(historyAfterUser);

    await CubitExceptionHandler.executeAsync(
      operation: () => _repository.sendMessage(
        pastUserInputs: withUser.pastUserInputs,
        generatedResponses: withUser.generatedResponses,
        prompt: trimmed,
        model: _currentModel,
        conversationId: withUser.id,
        clientMessageId: clientMessageId,
      ),
      onSuccess: (final ChatResult result) {
        final DateTime replyTimestamp = DateTime.now();
        final ChatMessage replyWithMetadata = ChatMessage(
          author: result.reply.author,
          text: result.reply.text,
          createdAt: replyTimestamp,
          lastSyncedAt: replyTimestamp,
        );
        final ChatConversation withAssistant = withUser.copyWith(
          messages: <ChatMessage>[...withUser.messages, replyWithMetadata],
          pastUserInputs: result.pastUserInputs,
          generatedResponses: result.generatedResponses,
          updatedAt: DateTime.now(),
        );

        final List<ChatConversation> finalHistory = _replaceConversation(
          withAssistant,
        );

        _emitConversationSnapshot(
          active: withAssistant,
          history: finalHistory,
          isLoading: false,
        );

        unawaited(_persistHistory(finalHistory));
      },
      onError: (final String errorMessage) {
        _emitConversationSnapshot(
          active: withUser,
          history: historyAfterUser,
          isLoading: false,
          error: errorMessage,
          status: ViewStatus.error,
        );
      },
      logContext: 'ChatCubit.sendMessage',
      specificExceptionHandlers: {
        ChatException: (final error, final stackTrace) {
          final ChatException exception = error as ChatException;
          _emitConversationSnapshot(
            active: withUser,
            history: historyAfterUser,
            isLoading: false,
            error: exception.message,
            status: ViewStatus.error,
          );
        },
        ChatOfflineEnqueuedException: (final error, final stackTrace) {
          AppLogger.info('Chat message queued for offline sync');
          _emitConversationSnapshot(
            active: withUser,
            history: historyAfterUser,
            isLoading: false,
          );
        },
      },
    );
  }
}
