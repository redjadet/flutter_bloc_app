import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatCubit', () {
    test('appends user and assistant messages on success', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final ChatCubit cubit = ChatCubit(
        repository: repo,
        initialModel: 'openai/gpt-oss-20b',
      );

      await cubit.sendMessage('Hello');

      expect(cubit.state.messages.length, 2);
      expect(cubit.state.messages.first.author, ChatAuthor.user);
      expect(cubit.state.messages.last.author, ChatAuthor.assistant);
      expect(cubit.state.isLoading, false);
    });

    test('emits error when repository throws', () async {
      final ChatCubit cubit = ChatCubit(
        repository: _ErrorChatRepository(),
        initialModel: 'openai/gpt-oss-20b',
      );

      await cubit.sendMessage('Hi');

      expect(cubit.state.error, isNotNull);
      expect(cubit.state.isLoading, false);
    });

    test('selectModel resets conversation and updates currentModel', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final ChatCubit cubit = ChatCubit(
        repository: repo,
        initialModel: 'openai/gpt-oss-20b',
      );

      await cubit.sendMessage('Hello');
      expect(cubit.state.messages, isNotEmpty);

      cubit.selectModel('openai/gpt-oss-120b');

      expect(cubit.state.currentModel, 'openai/gpt-oss-120b');
      expect(cubit.state.messages, isEmpty);
      expect(cubit.models.contains('openai/gpt-oss-120b'), isTrue);
    });
  });
}

class FakeChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
  }) async {
    return ChatResult(
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'Hi there!'),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, 'Hi there!'],
    );
  }
}

class _ErrorChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
  }) {
    throw const ChatException('fail');
  }
}
