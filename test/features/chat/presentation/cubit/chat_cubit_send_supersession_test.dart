import 'dart:async';

import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryHistoryRepository implements ChatHistoryRepository {
  _MemoryHistoryRepository([List<ChatConversation>? seed])
    : _conversations = List<ChatConversation>.from(
        seed ?? <ChatConversation>[],
      );

  List<ChatConversation> _conversations;

  @override
  Future<List<ChatConversation>> load() async =>
      List<ChatConversation>.from(_conversations);

  @override
  Future<void> save(final List<ChatConversation> conversations) async {
    _conversations = List<ChatConversation>.from(conversations);
  }
}

class _DelayedChatRepository implements ChatRepository {
  _DelayedChatRepository();

  final Completer<void> releaseSend = Completer<void>();

  @override
  ChatRemotePath? get chatRemoteTransportHint => null;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    await releaseSend.future;
    return ChatResult(
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'assistant'),
      pastUserInputs: pastUserInputs,
      generatedResponses: <String>['assistant'],
    );
  }
}

void main() {
  test(
    'sendMessage clears loading when superseded by loadHistory after success',
    () async {
      final _DelayedChatRepository repository = _DelayedChatRepository();
      final _MemoryHistoryRepository history = _MemoryHistoryRepository();
      final ChatCubit cubit = ChatCubit(
        repository: repository,
        historyRepository: history,
      );
      addTearDown(cubit.close);

      final Future<void> send = cubit.sendMessage('hello');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isLoading, isTrue);

      await cubit.loadHistory();
      repository.releaseSend.complete();
      await send;

      expect(cubit.state.isLoading, isFalse);
    },
  );

  test(
    'sendMessage persists assistant reply when superseded but conversation remains active',
    () async {
      final _DelayedChatRepository repository = _DelayedChatRepository();
      final _MemoryHistoryRepository history = _MemoryHistoryRepository();
      final ChatCubit cubit = ChatCubit(
        repository: repository,
        historyRepository: history,
      );
      addTearDown(cubit.close);

      final Future<void> send = cubit.sendMessage('hello');
      await Future<void>.delayed(Duration.zero);
      final String conversationId = cubit.state.activeConversationId!;
      expect(cubit.state.isLoading, isTrue);

      await cubit.loadHistory();
      repository.releaseSend.complete();
      await send;

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.activeConversationId, conversationId);
      expect(
        cubit.state.messages.any(
          (final message) =>
              message.author == ChatAuthor.assistant &&
              message.text == 'assistant',
        ),
        isTrue,
      );
    },
  );

  test(
    'sendMessage clears loading when superseded by deleteConversation',
    () async {
      final _DelayedChatRepository repository = _DelayedChatRepository();
      final _MemoryHistoryRepository history = _MemoryHistoryRepository();
      final ChatCubit cubit = ChatCubit(
        repository: repository,
        historyRepository: history,
      );
      addTearDown(cubit.close);

      final Future<void> send = cubit.sendMessage('hello');
      await Future<void>.delayed(Duration.zero);
      final String conversationId = cubit.state.activeConversationId!;
      expect(cubit.state.isLoading, isTrue);

      await cubit.deleteConversation(conversationId);
      repository.releaseSend.complete();
      await send;
      await pumpEventQueue();

      expect(cubit.state.isLoading, isFalse);
    },
  );

  test(
    'clearHistory is not undone by stale sendMessage assistant persist',
    () async {
      final _DelayedChatRepository repository = _DelayedChatRepository();
      final _MemoryHistoryRepository history = _MemoryHistoryRepository();
      final ChatCubit cubit = ChatCubit(
        repository: repository,
        historyRepository: history,
      );
      addTearDown(cubit.close);

      final Future<void> send = cubit.sendMessage('hello');
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isLoading, isTrue);
      expect((await history.load()).isNotEmpty, isTrue);

      await cubit.clearHistory();
      expect(await history.load(), isEmpty);

      repository.releaseSend.complete();
      await send;
      await pumpEventQueue();

      expect(await history.load(), isEmpty);
    },
  );

  test(
    'deleteConversation is not undone by stale sendMessage assistant persist',
    () async {
      final _DelayedChatRepository repository = _DelayedChatRepository();
      final _MemoryHistoryRepository history = _MemoryHistoryRepository();
      final ChatCubit cubit = ChatCubit(
        repository: repository,
        historyRepository: history,
      );
      addTearDown(cubit.close);

      final Future<void> send = cubit.sendMessage('hello');
      await Future<void>.delayed(Duration.zero);
      final String conversationId = cubit.state.activeConversationId!;
      expect(cubit.state.isLoading, isTrue);

      await cubit.deleteConversation(conversationId);
      expect(await history.load(), isEmpty);

      repository.releaseSend.complete();
      await send;
      await pumpEventQueue();

      expect(await history.load(), isEmpty);
    },
  );
}
