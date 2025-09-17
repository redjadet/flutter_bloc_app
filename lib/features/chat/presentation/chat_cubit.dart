import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository repository,
    required ChatHistoryRepository historyRepository,
    String? initialModel,
    List<String>? supportedModels,
  }) : _repository = repository,
       _historyRepository = historyRepository,
       _models = _buildModelList(initialModel, supportedModels),
       super(
         ChatState.initial(
           currentModel: _resolveInitialModel(initialModel, supportedModels),
         ),
       );

  final ChatRepository _repository;
  final ChatHistoryRepository _historyRepository;
  final List<String> _models;

  List<String> get models => _models;
  String get _currentModel => state.currentModel ?? _models.first;

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

  void clearError() {
    if (state.hasError) {
      emit(state.copyWith(error: null));
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

  static List<String> _buildModelList(
    String? initialModel,
    List<String>? supportedModels,
  ) {
    final LinkedHashSet<String> ordered = LinkedHashSet<String>();
    void add(String? value) {
      if (value == null) return;
      final String trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        ordered.add(trimmed);
      }
    }

    add(initialModel);
    if (supportedModels != null) {
      for (final String candidate in supportedModels) {
        add(candidate);
      }
    }
    add('openai/gpt-oss-20b');
    add('openai/gpt-oss-120b');

    return ordered.toList(growable: false);
  }

  static String _resolveInitialModel(
    String? initialModel,
    List<String>? supportedModels,
  ) {
    final String? trimmed = _normalize(initialModel);
    if (trimmed != null) return trimmed;
    final List<String> models = _buildModelList(initialModel, supportedModels);
    return models.first;
  }

  static String? _normalize(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

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
