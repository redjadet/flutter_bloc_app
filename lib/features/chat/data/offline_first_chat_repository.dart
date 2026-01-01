import 'package:flutter_bloc_app/features/chat/data/chat_local_conversation_updater.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_operation_factory.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_payload.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstChatRepository implements ChatRepository, SyncableRepository {
  OfflineFirstChatRepository({
    required final ChatRepository remoteRepository,
    required final PendingSyncRepository pendingSyncRepository,
    required final SyncableRepositoryRegistry registry,
    required final ChatSyncOperationFactory syncOperationFactory,
    required final ChatLocalConversationUpdater localConversationUpdater,
  }) : _remoteRepository = remoteRepository,
       _pendingSyncRepository = pendingSyncRepository,
       _registry = registry,
       _syncOperationFactory = syncOperationFactory,
       _localConversationUpdater = localConversationUpdater {
    _registry.register(this);
  }

  static const String chatEntity = chatSyncEntityType;

  final ChatRepository _remoteRepository;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;
  final ChatSyncOperationFactory _syncOperationFactory;
  final ChatLocalConversationUpdater _localConversationUpdater;

  @override
  String get entityType => chatEntity;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
  }) async {
    final String convoId =
        conversationId ?? _syncOperationFactory.generateConversationId();
    final String changeId =
        clientMessageId ?? _syncOperationFactory.generateChangeId();
    final DateTime createdAt = DateTime.now().toUtc();
    try {
      return await _remoteRepository.sendMessage(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: model,
        conversationId: convoId,
        clientMessageId: changeId,
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'OfflineFirstChatRepository.sendMessage failed, queuing operation',
        error,
        stackTrace,
      );
      final SyncOperation operation = _syncOperationFactory.createOperation(
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        prompt: prompt,
        model: model,
        conversationId: convoId,
        clientMessageId: changeId,
        createdAt: createdAt,
      );
      await _pendingSyncRepository.enqueue(operation);
      throw const ChatOfflineEnqueuedException();
    }
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    final ChatSyncPayload payload = _syncOperationFactory.readPayload(
      operation,
    );
    final ChatLocalConversationState localState =
        await _localConversationUpdater.ensureUserMessagePersisted(payload);

    final ChatResult result = await _remoteRepository.sendMessage(
      pastUserInputs: payload.pastUserInputs,
      generatedResponses: payload.generatedResponses,
      prompt: payload.prompt,
      model: payload.model,
      conversationId: payload.conversationId,
      clientMessageId: payload.clientMessageId,
    );

    await _localConversationUpdater.applyRemoteResult(
      state: localState,
      payload: payload,
      result: result,
    );
  }

  @override
  Future<void> pullRemote() async {
    // No remote pull channel for chat today. Left as a hook for future
    // bi-directional sync or conversation refresh.
  }

  // No local helpers: delegated to ChatSyncOperationFactory and updater.
}
