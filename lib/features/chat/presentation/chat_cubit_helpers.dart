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
      (final ChatConversation c) => c.id == conversation.id,
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

  Future<void> _persistHistory(final List<ChatConversation> history) async {
    if (isClosed) {
      return;
    }
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _historyRepository.save(history),
      logContext: 'ChatCubit._persistHistory',
      onSuccess: () {
        // Clear error on successful write to prevent stale error banners
        if (isClosed) {
          return;
        }
        final ChatState current = _state;
        if (current.status == ViewStatus.error || current.error != null) {
          emitState(
            current.copyWith(
              error: null,
              status: ViewStatus.success,
            ),
          );
        }
      },
      onError: (final String message) {
        AppLogger.error('Chat history persistence failed: $message');
        if (isClosed) {
          return;
        }
        final ChatState current = _state;
        emitState(
          current.copyWith(
            error: current.error ?? message,
            status: ViewStatus.error,
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
    final ViewStatus status = ViewStatus.success,
    final bool? isLoading,
    final bool clearError = false,
    final String? error,
    final String? currentModel,
  }) {
    // Check if cubit is closed before emitting to prevent errors
    if (isClosed) return;
    final ChatState current = _state;
    emitState(
      current.copyWith(
        history: history,
        activeConversationId: active.id,
        messages: active.messages,
        pastUserInputs: active.pastUserInputs,
        generatedResponses: active.generatedResponses,
        status: status,
        isLoading: isLoading ?? current.isLoading,
        error: clearError ? null : error ?? current.error,
        currentModel: currentModel ?? current.currentModel,
      ),
    );
  }
}
