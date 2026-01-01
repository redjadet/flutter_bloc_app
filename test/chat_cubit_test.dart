import 'dart:io';

import 'package:flutter_bloc_app/features/chat/data/chat_local_data_source.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_conversation_updater.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/chat/data/offline_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

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

    test('queues message without error when offline enqueue occurs', () async {
      final ChatCubit cubit = createCubit(
        repository: _OfflineQueueingChatRepository(),
        historyRepository: FakeChatHistoryRepository(),
      );

      await cubit.sendMessage('offline');

      expect(cubit.state.error, isNull);
      expect(cubit.state.status, anyOf(ViewStatus.success, ViewStatus.initial));
      expect(cubit.state.messages.length, 1);
      final ChatMessage message = cubit.state.messages.single;
      expect(message.author, ChatAuthor.user);
      expect(message.synchronized, isFalse);
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

    test('selectModel does nothing for invalid model', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      cubit.selectModel('invalid-model');

      expect(cubit.state.currentModel, 'openai/gpt-oss-20b');
    });

    test('selectModel does nothing for same model', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      cubit.selectModel('openai/gpt-oss-20b');

      expect(cubit.state.currentModel, 'openai/gpt-oss-20b');
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
      expect(history.conversations.first.messages, isNotEmpty);
      expect(history.conversations.first.pastUserInputs, isNotEmpty);
    });

    test('sendMessage surfaces error when history persistence fails', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final _ThrowingChatHistoryRepository history =
          _ThrowingChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.sendMessage('Hello');
      await pumpEventQueue();

      expect(cubit.state.status, ViewStatus.error);
      expect(cubit.state.error, 'Exception: history-save-failed');
      expect(history.conversations, isEmpty);

      history.setShouldThrow(false);
      await cubit.sendMessage('Recovered');
      await pumpEventQueue();

      expect(history.conversations, isNotEmpty);
      expect(history.conversations.first.messages, isNotEmpty);
      // Error should be cleared on successful write
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.error, isNull);
    });

    test('persistHistory clears error on successful write', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final _ThrowingChatHistoryRepository history =
          _ThrowingChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      // Trigger a persistence failure
      await cubit.sendMessage('Test');
      await pumpEventQueue();

      expect(cubit.state.status, ViewStatus.error);
      expect(cubit.state.error, isNotNull);

      // Recover and verify error is cleared
      history.setShouldThrow(false);
      await cubit.resetConversation();
      await pumpEventQueue();

      // Error should be cleared after successful persistence
      expect(cubit.state.status, ViewStatus.success);
      expect(cubit.state.error, isNull);
    });

    test('sendMessage ignores re-entrant calls while loading', () async {
      final _DelayedChatRepository repo = _DelayedChatRepository(
        const Duration(milliseconds: 50),
      );
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      final Future<void> firstCall = cubit.sendMessage('Hello');
      await Future<void>.delayed(Duration.zero);

      await cubit.sendMessage('Second');

      expect(repo.callCount, 1);
      expect(cubit.state.messages.length, 1);
      expect(cubit.state.messages.single.text, 'Hello');
      expect(cubit.state.isLoading, isTrue);

      await firstCall;

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.messages.length, 2);
      expect(cubit.state.messages.last.text, 'assistant: Hello');
      expect(history.conversations.single.messages.length, 2);
    });

    test('loadHistory removes empty conversations from storage', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      history.conversations = <ChatConversation>[
        ChatConversation(
          id: 'empty',
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
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

    test(
      'clearHistory resets state without persisting when already empty',
      () async {
        final FakeChatRepository repo = FakeChatRepository();
        final _TrackingChatHistoryRepository history =
            _TrackingChatHistoryRepository();
        final ChatCubit cubit = createCubit(
          repository: repo,
          historyRepository: history,
        );

        await cubit.clearHistory();

        expect(history.saveCallCount, 0);
        expect(cubit.state.history, isEmpty);
        expect(cubit.state.activeConversationId, isNotNull);
        expect(cubit.state.messages, isEmpty);
      },
    );

    test('deleteConversation promotes next available conversation', () async {
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
      expect(cubit.state.activeConversationId, 'newer');

      await cubit.deleteConversation('newer');

      expect(cubit.state.history.length, 1);
      expect(cubit.state.history.single.id, 'older');
      expect(cubit.state.activeConversationId, 'older');
    });

    test(
      'deleteConversation resets to fresh conversation when history empties',
      () async {
        final FakeChatRepository repo = FakeChatRepository();
        final FakeChatHistoryRepository history = FakeChatHistoryRepository();
        final ChatConversation only = ChatConversation(
          id: 'only',
          messages: const <ChatMessage>[
            ChatMessage(author: ChatAuthor.user, text: 'Hi'),
            ChatMessage(author: ChatAuthor.assistant, text: 'Hello'),
          ],
          pastUserInputs: const <String>['Hi'],
          generatedResponses: const <String>['Hello'],
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 1),
          model: 'openai/gpt-oss-20b',
        );
        history.conversations = <ChatConversation>[only];

        final ChatCubit cubit = createCubit(
          repository: repo,
          historyRepository: history,
        );

        await cubit.loadHistory();
        final String previousActiveId = cubit.state.activeConversationId!;

        await cubit.deleteConversation(previousActiveId);

        expect(cubit.state.history, isEmpty);
        expect(cubit.state.activeConversationId, isNot(previousActiveId));
        expect(cubit.state.messages, isEmpty);
        expect(history.conversations, isEmpty);
      },
    );

    test('loadHistory normalizes model and persists updated history', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final _TrackingChatHistoryRepository history =
          _TrackingChatHistoryRepository();
      final ChatConversation legacy = ChatConversation(
        id: 'legacy',
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'Hi'),
        ],
        pastUserInputs: const <String>['Hi'],
        generatedResponses: const <String>['Hello'],
        createdAt: DateTime(2024, 1, 1, 8, 0),
        updatedAt: DateTime(2024, 1, 1, 8, 1),
        model: 'unsupported-model',
      );
      history.conversations = <ChatConversation>[legacy];

      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.loadHistory();

      expect(history.saveCallCount, greaterThan(0));
      expect(cubit.state.history.single.model, cubit.state.currentModel);
    });

    test('selectConversation updates the active conversation', () async {
      final FakeChatRepository repo = FakeChatRepository();
      final FakeChatHistoryRepository history = FakeChatHistoryRepository();
      final ChatConversation conversation1 = ChatConversation(
        id: 'conv-1',
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'Hi'),
        ],
        pastUserInputs: const <String>['Hi'],
        generatedResponses: const <String>['Hello'],
        createdAt: DateTime(2024, 1, 1, 12, 0),
        updatedAt: DateTime(2024, 1, 1, 12, 1),
        model: 'openai/gpt-oss-20b',
      );
      final ChatConversation conversation2 = ChatConversation(
        id: 'conv-2',
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'Howdy'),
        ],
        pastUserInputs: const <String>['Howdy'],
        generatedResponses: const <String>['Welcome'],
        createdAt: DateTime(2024, 1, 2, 8, 0),
        updatedAt: DateTime(2024, 1, 2, 8, 30),
        model: 'openai/gpt-oss-120b',
      );
      history.conversations = <ChatConversation>[conversation1, conversation2];

      final ChatCubit cubit = createCubit(
        repository: repo,
        historyRepository: history,
      );

      await cubit.loadHistory();
      await cubit.selectConversation('conv-1');

      expect(cubit.state.activeConversationId, 'conv-1');
      expect(cubit.state.currentModel, 'openai/gpt-oss-20b');
    });

    test(
      'selectConversation does nothing if conversation is already active',
      () async {
        final FakeChatRepository repo = FakeChatRepository();
        final FakeChatHistoryRepository history = FakeChatHistoryRepository();
        final ChatConversation conversation1 = ChatConversation(
          id: 'conv-1',
          messages: const <ChatMessage>[
            ChatMessage(author: ChatAuthor.user, text: 'Hi'),
          ],
          pastUserInputs: const <String>['Hi'],
          generatedResponses: const <String>['Hello'],
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 1),
          model: 'openai/gpt-oss-20b',
        );
        history.conversations = <ChatConversation>[conversation1];

        final ChatCubit cubit = createCubit(
          repository: repo,
          historyRepository: history,
        );

        await cubit.loadHistory();
        final initialState = cubit.state;
        await cubit.selectConversation('conv-1');

        expect(cubit.state, initialState);
      },
    );

    test(
      'selectConversation does nothing if conversation is not found',
      () async {
        final FakeChatRepository repo = FakeChatRepository();
        final FakeChatHistoryRepository history = FakeChatHistoryRepository();
        final ChatCubit cubit = createCubit(
          repository: repo,
          historyRepository: history,
        );

        await cubit.loadHistory();
        final initialState = cubit.state;
        await cubit.selectConversation('not-found');

        expect(cubit.state, initialState);
      },
    );

    test(
      'selectConversation hydrates active conversation when messages are empty',
      () async {
        final FakeChatRepository repo = FakeChatRepository();
        final ChatConversation fullConversation = ChatConversation(
          id: 'conv-1',
          messages: const <ChatMessage>[
            ChatMessage(author: ChatAuthor.user, text: 'Hi'),
            ChatMessage(author: ChatAuthor.assistant, text: 'Hello'),
          ],
          pastUserInputs: const <String>['Hi'],
          generatedResponses: const <String>['Hello'],
          createdAt: DateTime(2024, 1, 1, 12, 0),
          updatedAt: DateTime(2024, 1, 1, 12, 1),
        );
        final _HydratingHistoryRepository history = _HydratingHistoryRepository(
          fullConversation,
        );

        final ChatCubit cubit = createCubit(
          repository: repo,
          historyRepository: history,
        );

        await cubit.loadHistory();
        expect(cubit.state.messages, isEmpty);

        await cubit.selectConversation('conv-1');

        expect(cubit.state.messages.length, 2);
        expect(cubit.state.messages.last.text, 'Hello');
      },
    );

    group('offline-first integration', () {
      late Directory tempDir;
      late HiveService hiveService;
      late ChatLocalDataSource localDataSource;
      late PendingSyncRepository pendingRepository;
      late SyncableRepositoryRegistry registry;
      late _FlakyRemoteChatRepository remoteRepository;
      late OfflineFirstChatRepository offlineRepository;
      late ChatSyncOperationFactory syncOperationFactory;
      late ChatLocalConversationUpdater localConversationUpdater;

      setUp(() async {
        tempDir = Directory.systemTemp.createTempSync('chat_cubit_offline_');
        Hive.init(tempDir.path);
        hiveService = HiveService(
          keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
        );
        await hiveService.initialize();
        localDataSource = ChatLocalDataSource(hiveService: hiveService);
        pendingRepository = PendingSyncRepository(hiveService: hiveService);
        registry = SyncableRepositoryRegistry();
        remoteRepository = _FlakyRemoteChatRepository();
        syncOperationFactory = ChatSyncOperationFactory(
          entityType: OfflineFirstChatRepository.chatEntity,
        );
        localConversationUpdater = ChatLocalConversationUpdater(
          localDataSource: localDataSource,
        );
        offlineRepository = OfflineFirstChatRepository(
          remoteRepository: remoteRepository,
          pendingSyncRepository: pendingRepository,
          registry: registry,
          syncOperationFactory: syncOperationFactory,
          localConversationUpdater: localConversationUpdater,
        );
      });

      tearDown(() async {
        await pendingRepository.clear();
        await Hive.deleteFromDisk();
        tempDir.deleteSync(recursive: true);
      });

      test(
        'pending messages flip to synced after coordinator-style flush',
        () async {
          remoteRepository.shouldFail = true;
          final ChatCubit cubit = ChatCubit(
            repository: offlineRepository,
            historyRepository: localDataSource,
            initialModel: 'offline-demo',
          );
          addTearDown(cubit.close);

          await cubit.sendMessage('Queue me while offline');

          expect(cubit.state.messages.length, 1);
          final ChatMessage pending = cubit.state.messages.single;
          expect(pending.synchronized, isFalse);

          List<SyncOperation> queued = await pendingRepository
              .getPendingOperations(now: DateTime.now().toUtc());
          expect(queued, hasLength(1));

          remoteRepository.shouldFail = false;
          await _drainPendingOperations(
            repository: offlineRepository,
            pendingRepository: pendingRepository,
          );
          await cubit.loadHistory();

          expect(
            cubit.state.messages.where((ChatMessage m) => !m.synchronized),
            isEmpty,
          );
          expect(cubit.state.messages.length, 2);
          expect(cubit.state.messages.last.author, ChatAuthor.assistant);
          queued = await pendingRepository.getPendingOperations(
            now: DateTime.now().toUtc(),
          );
          expect(queued, isEmpty);
        },
      );
    });
  });
}

Future<void> _drainPendingOperations({
  required OfflineFirstChatRepository repository,
  required PendingSyncRepository pendingRepository,
}) async {
  final List<SyncOperation> operations = await pendingRepository
      .getPendingOperations(now: DateTime.now().toUtc());
  for (final SyncOperation op in operations) {
    await repository.processOperation(op);
    await pendingRepository.markCompleted(op.id);
  }
}

class _FlakyRemoteChatRepository implements ChatRepository {
  _FlakyRemoteChatRepository();

  bool shouldFail = false;
  String replyText = 'Synced';

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) async {
    if (shouldFail) {
      throw const ChatException('offline');
    }
    return ChatResult(
      reply: ChatMessage(author: ChatAuthor.assistant, text: replyText),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, replyText],
    );
  }
}

class FakeChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) async {
    return ChatResult(
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'Hi there!'),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, 'Hi there!'],
    );
  }
}

class _DelayedChatRepository implements ChatRepository {
  _DelayedChatRepository(this.delay);

  final Duration delay;
  int callCount = 0;

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) {
    callCount++;
    return Future<ChatResult>.delayed(
      delay,
      () => ChatResult(
        reply: ChatMessage(
          author: ChatAuthor.assistant,
          text: 'assistant: $prompt',
        ),
        pastUserInputs: <String>[...pastUserInputs, prompt],
        generatedResponses: <String>[
          ...generatedResponses,
          'assistant: $prompt',
        ],
      ),
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

class _TrackingChatHistoryRepository extends FakeChatHistoryRepository {
  int saveCallCount = 0;

  @override
  Future<void> save(List<ChatConversation> conversations) async {
    saveCallCount++;
    await super.save(conversations);
  }
}

class _ThrowingChatHistoryRepository extends FakeChatHistoryRepository {
  _ThrowingChatHistoryRepository({bool shouldThrow = true})
    : _shouldThrow = shouldThrow;

  bool _shouldThrow;

  void setShouldThrow(final bool value) {
    _shouldThrow = value;
  }

  @override
  Future<void> save(List<ChatConversation> conversations) async {
    if (_shouldThrow) {
      throw Exception('history-save-failed');
    }
    await super.save(conversations);
  }
}

class _HydratingHistoryRepository implements ChatHistoryRepository {
  _HydratingHistoryRepository(this._full);

  final ChatConversation _full;
  bool _returnedTrimmed = false;

  @override
  Future<List<ChatConversation>> load() async {
    if (_returnedTrimmed) {
      return <ChatConversation>[_full];
    }
    _returnedTrimmed = true;
    return <ChatConversation>[_full.copyWith(messages: const <ChatMessage>[])];
  }

  @override
  Future<void> save(List<ChatConversation> conversations) async {}
}

class _ErrorChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) {
    throw const ChatException('fail');
  }
}

class _OfflineQueueingChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) {
    throw const ChatOfflineEnqueuedException();
  }
}
