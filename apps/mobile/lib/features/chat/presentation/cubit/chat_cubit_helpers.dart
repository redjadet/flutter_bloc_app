part of 'chat_cubit.dart';

mixin _ChatCubitHelpers on _ChatCubitCore {
  ChatState get _state => currentState;

  int _compareByUpdatedAt(final ChatConversation a, final ChatConversation b) =>
      b.updatedAt.compareTo(a.updatedAt);

  String _resolveModelForConversation(final ChatConversation conversation) {
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

  ChatConversation _createEmptyConversation({final String? model}) {
    final DateTime now = DateTime.now();
    return ChatConversation(
      id: _generateConversationId(now),
      createdAt: now,
      updatedAt: now,
      model: model ?? _currentModel,
    );
  }

  List<ChatConversation> _replaceConversation(
    final ChatConversation conversation, {
    final List<ChatConversation>? history,
  }) {
    final List<ChatConversation> updated = List<ChatConversation>.from(
      history ?? _state.history,
    );
    final int index = updated.indexWhere(
      (final c) => c.id == conversation.id,
    );

    if (index >= 0) {
      if (conversation.hasContent) {
        updated[index] = conversation;
      } else {
        updated.removeAt(index);
      }
    } else if (conversation.hasContent) {
      updated.add(conversation);
    }

    return _sortHistory(updated, clone: false);
  }

  List<ChatConversation> _sortHistory(
    final List<ChatConversation> conversations, {
    final bool clone = true,
  }) {
    final List<ChatConversation> target =
        (clone ? List<ChatConversation>.from(conversations) : conversations)
          ..sort(_compareByUpdatedAt);
    return target;
  }

  ChatConversation? _conversationById(
    final List<ChatConversation> conversations,
    final String? id,
  ) {
    if (id == null) return null;
    for (final ChatConversation conversation in conversations) {
      if (conversation.id == id) {
        return conversation;
      }
    }
    return null;
  }

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

  Future<void> _persistHistory(final List<ChatConversation> history) async {
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
      onError: (final message) {
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

  String _generateConversationId(final DateTime timestamp) =>
      'conversation_${timestamp.microsecondsSinceEpoch}';

  String _generateMessageId(final DateTime timestamp) =>
      'message_${timestamp.microsecondsSinceEpoch}';

  void _emitConversationSnapshot({
    required final ChatConversation active,
    required final List<ChatConversation> history,
    final bool? isLoading,
    final bool clearError = false,
    final String? error,
    final String? remoteFailureL10nCode,
    final String? currentModel,
    final ChatRemotePath? lastCompletionTransport,
    final bool clearLastCompletionTransport = false,
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
