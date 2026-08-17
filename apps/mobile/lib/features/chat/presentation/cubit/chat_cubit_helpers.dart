part of 'chat_cubit.dart';

mixin _ChatCubitHelpers on _ChatCubitCore {
  ChatState get _state => currentState;

  String _resolveModelForConversation(ChatConversation conversation) {
    final String? model = conversation.model;
    if (model != null && _models.contains(model)) {
      return model;
    }
    return _currentModel;
  }

  ChatConversation _ensureActiveConversation() {
    final String? activeId = _state.activeConversationId;
    if (activeId != null) {
      final ChatConversation? existing = _conversationById(
        _state.history,
        activeId,
      );
      if (existing != null) {
        return existing;
      }
    }

    final ChatConversation conversation = _createEmptyConversation(
      model: _state.currentModel,
    );

    final List<ChatConversation> history = conversation.hasContent
        ? _replaceConversation(conversation)
        : _state.history;

    _emitConversationSnapshot(
      active: conversation,
      history: history,
      clearLastCompletionTransport: true,
    );
    if (conversation.hasContent) {
      unawaited(_persistHistory(history));
    }

    return conversation;
  }

  ChatConversation _createEmptyConversation({String? model}) {
    final DateTime now = DateTime.now();
    return ChatConversation(
      id: _generateConversationId(now),
      createdAt: now,
      updatedAt: now,
      model: model ?? _currentModel,
    );
  }

  List<ChatConversation> _replaceConversation(
    ChatConversation conversation, {
    List<ChatConversation>? history,
  }) => replaceChatConversation(
    conversation,
    history: history ?? _state.history,
  );

  List<ChatConversation> _sortHistory(
    List<ChatConversation> conversations, {
    bool clone = true,
  }) => sortChatConversationHistory(conversations, clone: clone);

  ChatConversation? _conversationById(
    List<ChatConversation> conversations,
    String? id,
  ) => chatConversationById(conversations, id);

  ChatConversation _currentActiveConversation() {
    final ChatConversation? existing = _conversationById(
      _state.history,
      _state.activeConversationId,
    );
    return existing ?? _createEmptyConversation(model: _state.currentModel);
  }

  /// Clears [ChatState.isLoading] without changing the active conversation view.
  void _clearStuckLoading() {
    if (isClosed || !_state.isLoading) {
      return;
    }
    _emitConversationSnapshot(
      active: _currentActiveConversation(),
      history: _state.history,
      isLoading: false,
    );
  }

  Future<void> _persistHistory(List<ChatConversation> history) async {
    if (isClosed) {
      return;
    }
    final int persistEpoch = capturePersistEpoch();
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (!isPersistEpochCurrent(persistEpoch)) {
          return;
        }
        await _historyRepository.save(history);
      },
      isAlive: () => !isClosed && isPersistEpochCurrent(persistEpoch),
      logContext: 'ChatCubit._persistHistory',
      onSuccess: () {
        // Clear error on successful write to prevent stale error banners
        if (isClosed || !isPersistEpochCurrent(persistEpoch)) {
          return;
        }
        final ChatState current = _state;
        if (current.failure != null) {
          emitState(
            current.copyWith(
              failure: null,
            ),
          );
        }
      },
      onError: (message) {
        AppLogger.error('Chat history persistence failed', message);
        if (isClosed) {
          return;
        }
        final ChatState current = _state;
        emitState(
          current.copyWith(
            failure: current.failure ?? ChatFailure(message: message),
          ),
        );
      },
    );
  }

  String _generateConversationId(DateTime timestamp) =>
      'conversation_${timestamp.microsecondsSinceEpoch}';

  String _generateMessageId(DateTime timestamp) =>
      'message_${timestamp.microsecondsSinceEpoch}';

  void _emitConversationSnapshot({
    required ChatConversation active,
    required List<ChatConversation> history,
    bool? isLoading,
    bool clearError = false,
    String? error,
    String? remoteFailureL10nCode,
    String? currentModel,
    ChatRemotePath? lastCompletionTransport,
    bool clearLastCompletionTransport = false,
  }) {
    // Check if cubit is closed before emitting to prevent errors
    if (isClosed) return;
    final ChatState current = _state;
    final ChatRemotePath? nextCompletion = clearLastCompletionTransport
        ? null
        : (lastCompletionTransport ?? current.lastCompletionTransport);
    final ChatFailure? nextFailure;
    if (clearError) {
      nextFailure = null;
    } else if (error != null) {
      nextFailure = ChatFailure(
        message: error,
        l10nCode: remoteFailureL10nCode,
      );
    } else {
      nextFailure = current.failure;
    }
    emitState(
      current.copyWith(
        history: history,
        activeConversationId: active.id,
        messages: active.messages,
        pastUserInputs: active.pastUserInputs,
        generatedResponses: active.generatedResponses,
        isLoading: isLoading ?? current.isLoading,
        failure: nextFailure,
        currentModel: currentModel ?? current.currentModel,
        runnableTransportHint: _repository.chatRemoteTransportHint,
        lastCompletionTransport: nextCompletion,
      ),
    );
  }
}
