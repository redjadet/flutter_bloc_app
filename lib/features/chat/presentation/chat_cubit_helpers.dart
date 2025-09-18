part of 'chat_cubit.dart';

mixin _ChatCubitHelpers on _ChatCubitCore {
  String _resolveModelForConversation(ChatConversation conversation) {
    final String? model = conversation.model;
    if (model != null && _models.contains(model)) {
      return model;
    }
    return _currentModel;
  }

  ChatConversation _ensureActiveConversation() {
    final String? activeId = state.activeConversationId;
    if (activeId != null) {
      final ChatConversation? existing = _conversationById(
        state.history,
        activeId,
      );
      if (existing != null) {
        return existing;
      }
    }

    final ChatConversation conversation = _createEmptyConversation(
      model: state.currentModel,
    );

    final List<ChatConversation> history = conversation.hasContent
        ? _replaceConversation(conversation)
        : state.history;

    emit(
      state.copyWith(
        history: history,
        activeConversationId: conversation.id,
        messages: conversation.messages,
        pastUserInputs: conversation.pastUserInputs,
        generatedResponses: conversation.generatedResponses,
      ),
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
  }) {
    final List<ChatConversation> updated = List<ChatConversation>.from(
      history ?? state.history,
    );
    final int index = updated.indexWhere(
      (ChatConversation c) => c.id == conversation.id,
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

    updated.sort(
      (ChatConversation a, ChatConversation b) =>
          b.updatedAt.compareTo(a.updatedAt),
    );
    return updated;
  }

  List<ChatConversation> _sortHistory(List<ChatConversation> conversations) {
    final List<ChatConversation> sorted = List<ChatConversation>.from(
      conversations,
    );
    sorted.sort(
      (ChatConversation a, ChatConversation b) =>
          b.updatedAt.compareTo(a.updatedAt),
    );
    return sorted;
  }

  ChatConversation? _conversationById(
    List<ChatConversation> conversations,
    String? id,
  ) {
    if (id == null) return null;
    for (final ChatConversation conversation in conversations) {
      if (conversation.id == id) {
        return conversation;
      }
    }
    return null;
  }

  Future<void> _persistHistory(List<ChatConversation> history) {
    return _historyRepository.save(history);
  }

  String _generateConversationId(DateTime timestamp) =>
      'conversation_${timestamp.microsecondsSinceEpoch}';
}
