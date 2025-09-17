import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required ChatRepository repository})
    : _repository = repository,
      super(const ChatState());

  final ChatRepository _repository;

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
    emit(const ChatState());
  }
}
