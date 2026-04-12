import 'dart:io';

import 'package:flutter_bloc_app/features/chat/data/chat_local_conversation_updater.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_local_data_source.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/chat/data/offline_first_chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';
import 'package:flutter_bloc_app/shared/storage/hive_key_manager.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _FakeRemoteChatRepository implements ChatRepository {
  _FakeRemoteChatRepository({
    this.shouldFail = false,
    this.replyText = 'Hi!',
    this.failWithRemote,
  });

  bool shouldFail;
  String replyText;
  final ChatRemoteFailureException? failWithRemote;

  @override
  ChatInferenceTransport? get chatRemoteTransportHint => null;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    if (failWithRemote != null) {
      throw failWithRemote!;
    }
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

void main() {
  group('OfflineFirstChatRepository', () {
    late Directory tempDir;
    late HiveService hiveService;
    late ChatHistoryRepository localDataSource;
    late PendingSyncRepository pendingRepository;
    late SyncableRepositoryRegistry registry;
    late ChatSyncOperationFactory syncOperationFactory;
    late ChatLocalConversationUpdater localConversationUpdater;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('offline_chat_repo_');
      Hive.init(tempDir.path);
      hiveService = HiveService(
        keyManager: HiveKeyManager(storage: InMemorySecretStorage()),
      );
      await hiveService.initialize();
      localDataSource = ChatLocalDataSource(hiveService: hiveService);
      pendingRepository = PendingSyncRepository(hiveService: hiveService);
      registry = SyncableRepositoryRegistry();
      syncOperationFactory = ChatSyncOperationFactory(
        entityType: OfflineFirstChatRepository.chatEntity,
      );
      localConversationUpdater = ChatLocalConversationUpdater(
        localDataSource: localDataSource,
      );
    });

    tearDown(() async {
      await pendingRepository.clear();
      await Hive.deleteFromDisk();
      tempDir.deleteSync(recursive: true);
    });

    test(
      'sendMessage delegates to remote and does not enqueue on success',
      () async {
        final _FakeRemoteChatRepository remote = _FakeRemoteChatRepository();
        final OfflineFirstChatRepository repository =
            OfflineFirstChatRepository(
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
              syncOperationFactory: syncOperationFactory,
              localConversationUpdater: localConversationUpdater,
            );

        final ChatResult result = await repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hello',
          conversationId: 'c1',
          clientMessageId: 'm1',
        );

        expect(result.reply.text, 'Hi!');
        final List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        expect(pending, isEmpty);
      },
    );

    test('sendMessage enqueues operation when remote fails', () async {
      final _FakeRemoteChatRepository remote = _FakeRemoteChatRepository(
        shouldFail: true,
      );
      final OfflineFirstChatRepository repository = OfflineFirstChatRepository(
        remoteRepository: remote,
        pendingSyncRepository: pendingRepository,
        registry: registry,
        syncOperationFactory: syncOperationFactory,
        localConversationUpdater: localConversationUpdater,
      );

      await expectLater(
        () => repository.sendMessage(
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          prompt: 'Hello',
          conversationId: 'c2',
          clientMessageId: 'm2',
        ),
        throwsA(isA<ChatOfflineEnqueuedException>()),
      );

      final List<SyncOperation> pending = await pendingRepository
          .getPendingOperations(now: DateTime.now().toUtc());
      expect(pending.length, 1);
      expect(pending.first.entityType, OfflineFirstChatRepository.chatEntity);
      expect(pending.first.payload['prompt'], 'Hello');
    });

    test(
      'processOperation sends to remote and updates local history',
      () async {
        final _FakeRemoteChatRepository remote = _FakeRemoteChatRepository(
          replyText: 'Synced!',
        );
        final OfflineFirstChatRepository repository =
            OfflineFirstChatRepository(
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
              syncOperationFactory: syncOperationFactory,
              localConversationUpdater: localConversationUpdater,
            );

        final ChatConversation conversation = ChatConversation(
          id: 'c3',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
          messages: const <ChatMessage>[
            ChatMessage(
              author: ChatAuthor.user,
              text: 'Queue me',
              clientMessageId: 'm3',
              synchronized: false,
            ),
          ],
          synchronized: false,
        );
        await localDataSource.save(<ChatConversation>[conversation]);

        final SyncOperation operation = SyncOperation.create(
          entityType: OfflineFirstChatRepository.chatEntity,
          payload: <String, dynamic>{
            'conversationId': 'c3',
            'prompt': 'Queue me',
            'pastUserInputs': <String>['Queue me'],
            'generatedResponses': <String>[],
            'model': 'demo',
            'clientMessageId': 'm3',
            'createdAt': DateTime.utc(2024, 1, 1).toIso8601String(),
          },
          idempotencyKey: 'm3',
        );

        await repository.processOperation(operation);

        final List<ChatConversation> restored = await localDataSource.load();
        expect(restored, isNotEmpty);
        final ChatConversation updated = restored.first;
        expect(updated.synchronized, isTrue);
        expect(updated.lastSyncedAt, isNotNull);
        expect(updated.messages.length, 2);
        final ChatMessage reply = updated.messages.last;
        expect(reply.author, ChatAuthor.assistant);
        expect(reply.text, 'Synced!');
        expect(reply.lastSyncedAt, isNotNull);
      },
    );

    test(
      'processOperation persists user message before remote call when missing',
      () async {
        final _FakeRemoteChatRepository remote = _FakeRemoteChatRepository(
          replyText: 'New conversation',
        );
        final OfflineFirstChatRepository repository =
            OfflineFirstChatRepository(
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
              syncOperationFactory: syncOperationFactory,
              localConversationUpdater: localConversationUpdater,
            );

        // No existing conversation
        final SyncOperation operation = SyncOperation.create(
          entityType: OfflineFirstChatRepository.chatEntity,
          payload: <String, dynamic>{
            'conversationId': 'c4',
            'prompt': 'Hello new',
            'pastUserInputs': <String>[],
            'generatedResponses': <String>[],
            'model': 'demo',
            'clientMessageId': 'm4',
            'createdAt': DateTime.utc(2024, 1, 2).toIso8601String(),
          },
          idempotencyKey: 'm4',
        );

        await repository.processOperation(operation);

        final List<ChatConversation> restored = await localDataSource.load();
        expect(restored.length, 1);
        final ChatConversation created = restored.first;
        expect(created.id, 'c4');
        expect(created.messages.length, 2);
        expect(created.messages.first.text, 'Hello new');
        expect(created.messages.first.clientMessageId, 'm4');
        expect(created.messages.last.text, 'New conversation');
        expect(created.synchronized, isTrue);
      },
    );

    test(
      'sendMessage does not enqueue on non-retryable ChatRemoteFailureException',
      () async {
        final _FakeRemoteChatRepository remote = _FakeRemoteChatRepository(
          failWithRemote: const ChatRemoteFailureException(
            'auth',
            code: 'auth_required',
            retryable: false,
            isEdge: true,
          ),
        );
        final OfflineFirstChatRepository repository =
            OfflineFirstChatRepository(
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
              syncOperationFactory: syncOperationFactory,
              localConversationUpdater: localConversationUpdater,
            );

        await expectLater(
          () => repository.sendMessage(
            pastUserInputs: const <String>[],
            generatedResponses: const <String>[],
            prompt: 'Hello',
            conversationId: 'c-term',
            clientMessageId: 'm-term',
          ),
          throwsA(isA<ChatRemoteFailureException>()),
        );

        final List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        expect(pending, isEmpty);
      },
    );

    test(
      'processOperation removes pending op on non-retryable ChatRemoteFailureException',
      () async {
        final _FakeRemoteChatRepository remote = _FakeRemoteChatRepository(
          failWithRemote: const ChatRemoteFailureException(
            'auth',
            code: 'auth_required',
            retryable: false,
            isEdge: true,
          ),
        );
        final OfflineFirstChatRepository repository =
            OfflineFirstChatRepository(
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
              syncOperationFactory: syncOperationFactory,
              localConversationUpdater: localConversationUpdater,
            );

        final ChatConversation conversation = ChatConversation(
          id: 'c-drop',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
          messages: const <ChatMessage>[
            ChatMessage(
              author: ChatAuthor.user,
              text: 'Hi',
              clientMessageId: 'm-drop',
              synchronized: false,
            ),
          ],
          synchronized: false,
        );
        await localDataSource.save(<ChatConversation>[conversation]);

        final SyncOperation operation = SyncOperation.create(
          entityType: OfflineFirstChatRepository.chatEntity,
          payload: <String, dynamic>{
            'conversationId': 'c-drop',
            'prompt': 'Hi',
            'pastUserInputs': <String>['Hi'],
            'generatedResponses': <String>[],
            'model': 'demo',
            'clientMessageId': 'm-drop',
            'createdAt': DateTime.utc(2024, 1, 1).toIso8601String(),
          },
          idempotencyKey: 'm-drop',
        );
        await pendingRepository.enqueue(operation);

        await repository.processOperation(operation);

        final List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        expect(pending, isEmpty);

        final List<ChatConversation> after = await localDataSource.load();
        expect(after, isNotEmpty);
        final ChatMessage userMsg = after.first.messages.firstWhere(
          (final m) => m.clientMessageId == 'm-drop',
        );
        expect(userMsg.terminalSyncFailureCode, 'auth_required');
      },
    );

    test(
      'processOperation removes pending op on forbidden ChatRemoteFailureException (403-class)',
      () async {
        final _FakeRemoteChatRepository remote = _FakeRemoteChatRepository(
          failWithRemote: const ChatRemoteFailureException(
            'forbidden',
            code: 'forbidden',
            retryable: false,
            isEdge: true,
          ),
        );
        final OfflineFirstChatRepository repository =
            OfflineFirstChatRepository(
              remoteRepository: remote,
              pendingSyncRepository: pendingRepository,
              registry: registry,
              syncOperationFactory: syncOperationFactory,
              localConversationUpdater: localConversationUpdater,
            );

        final ChatConversation conversation = ChatConversation(
          id: 'c-forbid',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
          messages: const <ChatMessage>[
            ChatMessage(
              author: ChatAuthor.user,
              text: 'X',
              clientMessageId: 'm-forbid',
              synchronized: false,
            ),
          ],
          synchronized: false,
        );
        await localDataSource.save(<ChatConversation>[conversation]);

        final SyncOperation operation = SyncOperation.create(
          entityType: OfflineFirstChatRepository.chatEntity,
          payload: <String, dynamic>{
            'conversationId': 'c-forbid',
            'prompt': 'X',
            'pastUserInputs': <String>['X'],
            'generatedResponses': <String>[],
            'model': 'demo',
            'clientMessageId': 'm-forbid',
            'createdAt': DateTime.utc(2024, 1, 1).toIso8601String(),
          },
          idempotencyKey: 'm-forbid',
        );
        await pendingRepository.enqueue(operation);

        await repository.processOperation(operation);

        final List<SyncOperation> pending = await pendingRepository
            .getPendingOperations(now: DateTime.now().toUtc());
        expect(pending, isEmpty);
      },
    );
  });
}
