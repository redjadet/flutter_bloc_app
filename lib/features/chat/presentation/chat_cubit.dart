import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository repository,
    String? initialModel,
    List<String>? supportedModels,
  }) : _repository = repository,
       _models = _buildModelList(initialModel, supportedModels),
       super(
         ChatState(
           currentModel: _resolveInitialModel(initialModel, supportedModels),
         ),
       );

  final ChatRepository _repository;
  final List<String> _models;

  List<String> get models => _models;
  String get _currentModel => state.currentModel ?? _models.first;

  Future<void> sendMessage(String message) async {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final List<ChatMessage> updatedMessages = List<ChatMessage>.from(
      state.messages,
    )..add(ChatMessage(author: ChatAuthor.user, text: trimmed));

    emit(
      state.copyWith(
        messages: updatedMessages,
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final ChatResult result = await _repository.sendMessage(
        pastUserInputs: state.pastUserInputs,
        generatedResponses: state.generatedResponses,
        prompt: trimmed,
        model: _currentModel,
      );

      emit(
        state.copyWith(
          messages: <ChatMessage>[...updatedMessages, result.reply],
          isLoading: false,
          pastUserInputs: result.pastUserInputs,
          generatedResponses: result.generatedResponses,
        ),
      );
    } on ChatException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  void resetConversation() {
    emit(ChatState(currentModel: _currentModel));
  }

  void selectModel(String model) {
    final String? normalized = _normalize(model);
    if (normalized == null ||
        !_models.contains(normalized) ||
        state.currentModel == normalized) {
      return;
    }
    emit(ChatState(currentModel: normalized));
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
}
