import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatCubit', () {
    ChatCubit createCubit({
      ChatRepository? repository,
      ChatHistoryRepository? historyRepository,
      String initialModel = 'openai/gpt-oss-20b',
    }) {
      final ChatCubit cubit = ChatCubit(
        repository: repository ?? FakeChatRepository(),
        historyRepository: historyRepository ?? FakeChatHistoryRepository(),
        initialModel: initialModel,
      );
      addTearDown(cubit.close);
      return cubit;
    }

    test('appends user and assistant messages on success', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.sendMessage('Hello');

      expect(cubit.state.messages.length, 2);
      expect(cubit.state.messages.first.author, ChatAuthor.user);
      expect(cubit.state.messages.last.author, ChatAuthor.assistant);
      expect(cubit.state.isLoading, false);
    });

    test('emits error when repository throws', () async {
      final ChatCubit cubit = createCubit(
        repository: _ErrorChatRepository(),
        historyRepository: FakeChatHistoryRepository(),
      );

      await cubit.sendMessage('Hi');

      expect(cubit.state.error, isNotNull);
      expect(cubit.state.isLoading, false);
    });

    test('selectModel resets conversation and updates currentModel', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.sendMessage('Hello');
      expect(cubit.state.messages, isNotEmpty);

      cubit.selectModel('openai/gpt-oss-120b');

      expect(cubit.state.currentModel, 'openai/gpt-oss-120b');
      expect(cubit.state.messages, isEmpty);
      expect(cubit.models.contains('openai/gpt-oss-120b'), isTrue);
    });

    test('loadHistory restores stored conversation', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatConversation storedConversation = ChatConversation(
        id: 'conv-1',
        messages: <ChatMessage>[
          const ChatMessage(author: ChatAuthor.user, text: 'Hi'),
          const ChatMessage(author: ChatAuthor.assistant, text: 'Hello!'),
        ],
        pastUserInputs: const <String>['Hi'],
        generatedResponses: const <String>['Hello!'],
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 1),
        model: 'openai/gpt-oss-20b',
      );
      history.conversations = <ChatConversation>[storedConversation];

      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.loadHistory();

      expect(cubit.state.messages.length, 2);
      expect(cubit.state.history.length, 1);
      expect(cubit.state.activeConversationId, storedConversation.id);
      expect(history.conversations.length, 1);
    });

    test('loadHistory orders conversations by most recent update', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatConversation older = ChatConversation(
        id: 'older',
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'Hi'),
          ChatMessage(author: ChatAuthor.assistant, text: 'Hello'),
        ],
        pastUserInputs: const <String>['Hi'],
        generatedResponses: const <String>['Hello'],
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 5),
        model: 'openai/gpt-oss-20b',
      );
      final ChatConversation newer = ChatConversation(
        id: 'newer',
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'Howdy'),
          ChatMessage(author: ChatAuthor.assistant, text: 'Welcome'),
        ],
        pastUserInputs: const <String>['Howdy'],
        generatedResponses: const <String>['Welcome'],
        createdAt: DateTime(2024, 1, 2, 8, 0),
        updatedAt: DateTime(2024, 1, 2, 8, 30),
        model: 'openai/gpt-oss-20b',
      );
      history.conversations = <ChatConversation>[older, newer];

      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.loadHistory();

      expect(cubit.state.history.first.id, 'newer');
      expect(cubit.state.history.map((ChatConversation c) => c.id), <String>[
        'newer',
        'older',
      ]);
    });

    test('sendMessage persists conversation to history', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.sendMessage('Hello');

      expect(history.conversations, isNotEmpty);
      expect(history.conversations.first.messages.length, 2);
      expect(history.conversations.first.pastUserInputs, isNotEmpty);
    });

    test('loadHistory removes empty conversations from storage', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      history.conversations = <ChatConversation>[
        ChatConversation(id: 'empty', createdAt: DateTime(2024, 1, 1)),
      ];

      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.loadHistory();

      expect(cubit.state.history, isEmpty);
      expect(history.conversations, isEmpty);
      expect(cubit.state.messages, isEmpty);
    });

    test(
      'clearHistory removes stored conversations and resets state',
      () async {
        final FakeChatRepository repo = FakeChatRepository();
        final FakeChatHistoryRepository history = FakeChatHistoryRepository();
        final ChatCubit cubit = createCubit(
          repository: repo,
          historyRepository: history,
        );

        await cubit.sendMessage('Hello');
        final String previousActiveId = cubit.state.activeConversationId!;

        await cubit.clearHistory();

        expect(cubit.state.history, isEmpty);
        expect(history.conversations, isEmpty);
        expect(cubit.state.messages, isEmpty);
        expect(cubit.state.activeConversationId, isNot(previousActiveId));
      },
    );
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

class FakeChatHistoryRepository implements ChatHistoryRepository {
  List<ChatConversation> conversations = <ChatConversation>[];

  @override
  Future<List<ChatConversation>> load() async => conversations;

  @override
  Future<void> save(List<ChatConversation> conversations) async {
    this.conversations = List<ChatConversation>.from(conversations);
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
