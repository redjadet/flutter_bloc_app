import 'dart:async';
import 'dart:io';

import 'package:auth/auth.dart' as core_auth;
import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_auth_session_port_adapter.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_conversation_updater.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_data_source.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/chat/data/offline_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_auth_session_port.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/render_orchestration_hf_token_provider.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:storage/storage.dart';
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
      final ChatMessage userMessage = cubit.state.messages.first;
      final ChatMessage assistantMessage = cubit.state.messages.last;
      expect(userMessage.clientMessageId, isNotNull);
      expect(
        assistantMessage.clientMessageId,
        '${userMessage.clientMessageId}-reply',
      );
      expect(cubit.state.isLoading, false);
    });

    test('emits error when repository throws', () async {
      final ChatCubit cubit = createCubit(
        repository: _ErrorChatRepository(),
        historyRepository: FakeChatHistoryRepository(),
      );

      await cubit.sendMessage('Hi');

      expect(cubit.state.error, isNotNull);
      expect(cubit.state.remoteFailureL10nCode, isNull);
      expect(cubit.state.isLoading, false);
    });

    test('sets remoteFailureL10nCode on ChatRemoteFailureException', () async {
      final ChatCubit cubit = createCubit(
        repository: _RemoteFailureChatRepository(),
        historyRepository: FakeChatHistoryRepository(),
      );

      await cubit.sendMessage('Hi');

      expect(cubit.state.error, isNotNull);
      expect(cubit.state.remoteFailureL10nCode, 'auth_required');
      expect(cubit.state.isLoading, false);
    });

    test('queues message without error when offline enqueue occurs', () async {
      final ChatCubit cubit = createCubit(
        repository: _OfflineQueueingChatRepository(),
        historyRepository: FakeChatHistoryRepository(),
      );

      await cubit.sendMessage('offline');

      expect(cubit.state.error, isNull);
      expect(cubit.state.hasError, isFalse);
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

    test(
      'after direct completion, new cubit plus loadHistory uses hint not sticky direct',
      () async {
        final _ConfigurableTransportChatRepository repo =
            _ConfigurableTransportChatRepository(
              hint: ChatRemotePath.edgeProxy,
              successTransport: ChatRemotePath.directApi,
            );
        final FakeChatHistoryRepository history = FakeChatHistoryRepository();

        final ChatCubit first = ChatCubit(
          repository: repo,
          historyRepository: history,
          initialModel: 'openai/gpt-oss-20b',
        );
        addTearDown(first.close);

        await first.sendMessage('Hi');
        expect(first.state.lastCompletionTransport, ChatRemotePath.directApi);
        expect(first.state.transportForBadge, ChatRemotePath.directApi);

        await first.close();

        final ChatCubit restarted = ChatCubit(
          repository: repo,
          historyRepository: history,
          initialModel: 'openai/gpt-oss-20b',
        );
        addTearDown(restarted.close);

        await restarted.loadHistory();

        expect(restarted.state.lastCompletionTransport, isNull);
        expect(restarted.state.runnableTransportHint, ChatRemotePath.edgeProxy);
        expect(restarted.state.transportForBadge, ChatRemotePath.edgeProxy);
      },
    );

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

      expect(cubit.state.hasError, isTrue);
      expect(cubit.state.error, 'Exception: history-save-failed');
      expect(history.conversations, isEmpty);

      history.setShouldThrow(false);
      await cubit.sendMessage('Recovered');
      await pumpEventQueue();

      expect(history.conversations, isNotEmpty);
      expect(history.conversations.first.messages, isNotEmpty);
      // Error should be cleared on successful write
      expect(cubit.state.hasError, isFalse);
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

      expect(cubit.state.hasError, isTrue);
      expect(cubit.state.error, isNotNull);

      // Recover and verify error is cleared
      history.setShouldThrow(false);
      await cubit.resetConversation();
      await pumpEventQueue();

      // Error should be cleared after successful persistence
      expect(cubit.state.hasError, isFalse);
      expect(cubit.state.error, isNull);
    });

    test(
      'resetConversation keeps prior state when persistence fails',
      () async {
        final FakeChatRepository repo = FakeChatRepository();
        final _ThrowingChatHistoryRepository history =
            _ThrowingChatHistoryRepository();
        history.setShouldThrow(false);
        final ChatCubit cubit = createCubit(
          repository: repo,
          historyRepository: history,
        );

        await cubit.sendMessage('Hello');
        await pumpEventQueue();

        final int priorMessageCount = cubit.state.messages.length;
        final int priorHistoryCount = cubit.state.history.length;
        expect(priorMessageCount, greaterThan(0));

        history.setShouldThrow(true);
        await cubit.resetConversation();
        await pumpEventQueue();

        expect(cubit.state.hasError, isTrue);
        expect(cubit.state.messages.length, priorMessageCount);
        expect(cubit.state.history.length, priorHistoryCount);
      },
    );

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

      test(
        'after queued flush and loadHistory, transport badge follows hint not replay transportUsed',
        () async {
          remoteRepository.shouldFail = true;
          remoteRepository.hint = ChatRemotePath.edgeProxy;
          remoteRepository.successTransport = ChatRemotePath.directApi;
          final ChatCubit cubit = ChatCubit(
            repository: offlineRepository,
            historyRepository: localDataSource,
            initialModel: 'offline-demo',
          );
          addTearDown(cubit.close);

          await cubit.sendMessage('Flush transport');

          List<SyncOperation> queued = await pendingRepository
              .getPendingOperations(now: DateTime.now().toUtc());
          expect(queued, hasLength(1));

          remoteRepository.shouldFail = false;
          await _drainPendingOperations(
            repository: offlineRepository,
            pendingRepository: pendingRepository,
          );

          await cubit.loadHistory();

          expect(cubit.state.messages.length, 2);
          expect(cubit.state.lastCompletionTransport, isNull);
          expect(cubit.state.runnableTransportHint, ChatRemotePath.edgeProxy);
          expect(cubit.state.transportForBadge, ChatRemotePath.edgeProxy);

          queued = await pendingRepository.getPendingOperations(
            now: DateTime.now().toUtc(),
          );
          expect(queued, isEmpty);
        },
      );
    });

    group('auth-driven transport hint refresh', () {
      test('clears HF token cache when Firebase auth emits sign-out', () async {
        final _ControllableCoreAuthRepository auth =
            _ControllableCoreAuthRepository(
              initialUser: const AuthUser(id: 'u1', isAnonymous: false),
            );
        addTearDown(auth.dispose);
        final _SpyHfTokenProvider provider = _SpyHfTokenProvider();
        final ChatCubit cubit = ChatCubit(
          repository: _MutableHintChatRepository(
            hint: ChatRemotePath.edgeProxy,
          ),
          historyRepository: FakeChatHistoryRepository(),
          renderOrchestrationHfTokenProvider: provider,
          authSessionPort: _authSessionPort(firebase: auth),
        );
        addTearDown(cubit.close);

        auth.emitAuthState(null);
        await pumpEventQueue();

        expect(provider.clearCacheCalls, 1);
      });

      test(
        'does not clear HF token cache when Firebase auth emits signed-in user',
        () async {
          final _ControllableCoreAuthRepository auth =
              _ControllableCoreAuthRepository();
          addTearDown(auth.dispose);
          final _SpyHfTokenProvider provider = _SpyHfTokenProvider();
          final ChatCubit cubit = ChatCubit(
            repository: FakeChatRepository(),
            historyRepository: FakeChatHistoryRepository(),
            renderOrchestrationHfTokenProvider: provider,
            authSessionPort: _authSessionPort(firebase: auth),
          );
          addTearDown(cubit.close);

          auth.emitAuthState(
            const AuthUser(id: 'u1', isAnonymous: false, email: 'a@b.c'),
          );
          await pumpEventQueue();

          expect(provider.clearCacheCalls, 0);
        },
      );

      test(
        'refreshes runnableTransportHint when Firebase auth state changes',
        () async {
          final _ControllableCoreAuthRepository auth =
              _ControllableCoreAuthRepository();
          addTearDown(auth.dispose);
          final _MutableHintChatRepository repo = _MutableHintChatRepository(
            hint: ChatRemotePath.edgeProxy,
          );
          final ChatCubit cubit = ChatCubit(
            repository: repo,
            historyRepository: FakeChatHistoryRepository(),
            authSessionPort: _authSessionPort(firebase: auth),
          );
          addTearDown(cubit.close);

          expect(cubit.state.runnableTransportHint, ChatRemotePath.edgeProxy);

          repo.hint = ChatRemotePath.directApi;
          auth.emitAuthState(
            const AuthUser(id: 'u1', isAnonymous: false, email: 'a@b.c'),
          );
          await pumpEventQueue();

          expect(cubit.state.runnableTransportHint, ChatRemotePath.directApi);
        },
      );

      test(
        'refreshes runnableTransportHint when Supabase auth state changes',
        () async {
          final _ControllableSupabaseAuthRepository auth =
              _ControllableSupabaseAuthRepository();
          addTearDown(auth.dispose);
          final _MutableHintChatRepository repo = _MutableHintChatRepository(
            hint: ChatRemotePath.edgeProxy,
          );
          final ChatCubit cubit = ChatCubit(
            repository: repo,
            historyRepository: FakeChatHistoryRepository(),
            authSessionPort: _authSessionPort(supabase: auth),
          );
          addTearDown(cubit.close);

          repo.hint = ChatRemotePath.directApi;
          auth.emitAuthState(
            const AuthUser(id: 'sb1', isAnonymous: false, email: 's@b.c'),
          );
          await pumpEventQueue();

          expect(cubit.state.runnableTransportHint, ChatRemotePath.directApi);
        },
      );
    });
  });
}

ChatAuthSessionPort _authSessionPort({
  core_auth.AuthRepository? firebase,
  SupabaseAuthRepository? supabase,
}) {
  return ChatAuthSessionPortAdapter(
    firebaseAuthRepository: firebase ?? _ControllableCoreAuthRepository(),
    supabaseAuthRepository: supabase ?? _ControllableSupabaseAuthRepository(),
  );
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
  ChatRemotePath? hint;
  ChatRemotePath? successTransport;

  @override
  ChatRemotePath? get chatRemoteTransportHint => hint;

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
      transportUsed: successTransport,
    );
  }
}

/// Remote that reports a stable [hint] and tags successful replies with [successTransport].
class _ConfigurableTransportChatRepository implements ChatRepository {
  _ConfigurableTransportChatRepository({
    required this.hint,
    required this.successTransport,
  });

  final ChatRemotePath hint;
  final ChatRemotePath successTransport;

  @override
  ChatRemotePath? get chatRemoteTransportHint => hint;

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
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'ok'),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, 'ok'],
      transportUsed: successTransport,
    );
  }
}

class _ControllableCoreAuthRepository implements core_auth.AuthRepository {
  _ControllableCoreAuthRepository({this.initialUser})
    : _currentUser = initialUser;

  final AuthUser? initialUser;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  void emitAuthState(final AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  Future<void> dispose() => _controller.close();
}

class _ControllableSupabaseAuthRepository implements SupabaseAuthRepository {
  _ControllableSupabaseAuthRepository({this.initialUser})
    : _currentUser = initialUser;

  final AuthUser? initialUser;
  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  @override
  bool get isConfigured => true;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> get authStateChanges => _controller.stream;

  void emitAuthState(final AuthUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<void> signInWithPassword({
    required final String email,
    required final String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    emitAuthState(null);
  }

  Future<void> dispose() => _controller.close();
}

class _SpyHfTokenProvider implements RenderOrchestrationHfTokenProvider {
  int clearCacheCalls = 0;

  @override
  Future<void> clearRenderOrchestrationTokenCache() async {
    clearCacheCalls++;
  }

  @override
  Future<String?> readHfTokenForUpstream() async => null;
}

class _MutableHintChatRepository implements ChatRepository {
  _MutableHintChatRepository({this.hint});

  ChatRemotePath? hint;

  @override
  ChatRemotePath? get chatRemoteTransportHint => hint;

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
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'ok'),
      pastUserInputs: <String>[...pastUserInputs, prompt],
      generatedResponses: <String>[...generatedResponses, 'ok'],
    );
  }
}

class FakeChatRepository implements ChatRepository {
  @override
  ChatRemotePath? get chatRemoteTransportHint => null;

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
  ChatRemotePath? get chatRemoteTransportHint => null;

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
  _ThrowingChatHistoryRepository() : _shouldThrow = true;

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
  ChatRemotePath? get chatRemoteTransportHint => null;

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

class _RemoteFailureChatRepository implements ChatRepository {
  @override
  ChatRemotePath? get chatRemoteTransportHint => null;

  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) {
    throw const ChatRemoteFailureException(
      'jwt',
      code: 'auth_required',
      retryable: false,
      isEdge: false,
    );
  }
}

class _OfflineQueueingChatRepository implements ChatRepository {
  @override
  ChatRemotePath? get chatRemoteTransportHint => null;

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
