import 'dart:math';

import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class OfflineFirstChatRepository implements ChatRepository, SyncableRepository {
  OfflineFirstChatRepository({
    required ChatRepository remoteRepository,
    required ChatHistoryRepository localDataSource,
    required PendingSyncRepository pendingSyncRepository,
    required SyncableRepositoryRegistry registry,
  }) : _remoteRepository = remoteRepository,
       _localDataSource = localDataSource,
       _pendingSyncRepository = pendingSyncRepository,
       _registry = registry {
    _registry.register(this);
  }

  static const String chatEntity = chatSyncEntityType;

  final ChatRepository _remoteRepository;
  final ChatHistoryRepository _localDataSource;
  final PendingSyncRepository _pendingSyncRepository;
  final SyncableRepositoryRegistry _registry;

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
    final String convoId = conversationId ?? _generateConversationId();
    final String changeId = clientMessageId ?? _generateChangeId();
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
      final SyncOperation operation = SyncOperation.create(
        entityType: entityType,
        payload: <String, dynamic>{
          'conversationId': convoId,
          'prompt': prompt,
          'pastUserInputs': pastUserInputs,
          'generatedResponses': generatedResponses,
          'model': model,
          'clientMessageId': changeId,
          'createdAt': createdAt.toIso8601String(),
        },
        idempotencyKey: changeId,
      );
      await _pendingSyncRepository.enqueue(operation);
      throw const ChatOfflineEnqueuedException();
    }
  }

  @override
  Future<void> processOperation(final SyncOperation operation) async {
    final Map<String, dynamic> payload = operation.payload;
    final String conversationId = (payload['conversationId'] ?? '').toString();
    final String prompt = (payload['prompt'] ?? '').toString();
    final List<String> pastUserInputs = _readStringList(
      payload['pastUserInputs'],
    );
    final List<String> generatedResponses = _readStringList(
      payload['generatedResponses'],
    );
    final String? model = payload['model'] as String?;
    final String clientMessageId =
        (payload['clientMessageId'] ?? _generateChangeId()).toString();
    final DateTime createdAt =
        DateTime.tryParse((payload['createdAt'] ?? '').toString()) ??
        DateTime.now().toUtc();

    // Load existing conversation and ensure user message is persisted locally
    // before attempting remote call, so we don't lose the user's message if sync fails
    final List<ChatConversation> existing = await _localDataSource.load();
    final int index = existing.indexWhere(
      (final ChatConversation c) => c.id == conversationId,
    );
    final DateTime now = DateTime.now().toUtc();
    ChatConversation conversation = index >= 0
        ? existing[index]
        : ChatConversation(
            id: conversationId,
            createdAt: createdAt,
            updatedAt: createdAt,
          );

    final List<ChatMessage> messages = List<ChatMessage>.from(
      conversation.messages,
    );
    final bool hasUserMessage = messages.any(
      (final ChatMessage m) => m.clientMessageId == clientMessageId,
    );
    if (!hasUserMessage) {
      messages.add(
        ChatMessage(
          author: ChatAuthor.user,
          text: prompt,
          clientMessageId: clientMessageId,
          createdAt: createdAt,
          synchronized: false,
        ),
      );
      conversation = conversation.copyWith(
        messages: messages,
        pastUserInputs: pastUserInputs,
        generatedResponses: generatedResponses,
        updatedAt: now,
        model: model,
      );
      // Persist user message before remote call
      final List<ChatConversation> withUserMessage = index >= 0
          ? (<ChatConversation>[
              ...existing.sublist(0, index),
              conversation,
              ...existing.sublist(index + 1),
            ])
          : (<ChatConversation>[...existing, conversation]);
      await _localDataSource.save(withUserMessage);
    }

    // Attempt remote call - coordinator will handle retries if this throws
    final ChatResult result = await _remoteRepository.sendMessage(
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
      prompt: prompt,
      model: model,
      conversationId: conversationId,
      clientMessageId: clientMessageId,
    );

    // Mark the user's message as synchronized now that the remote call succeeded
    for (int i = 0; i < messages.length; i++) {
      final ChatMessage message = messages[i];
      if (message.clientMessageId == clientMessageId) {
        messages[i] = ChatMessage(
          author: message.author,
          text: message.text,
          clientMessageId: message.clientMessageId,
          createdAt: message.createdAt,
          lastSyncedAt: now,
        );
        break;
      }
    }

    // Update with assistant reply and mark as synchronized
    messages.add(
      ChatMessage(
        author: result.reply.author,
        text: result.reply.text,
        createdAt: now,
        lastSyncedAt: now,
      ),
    );

    final ChatConversation updated = conversation.copyWith(
      messages: messages,
      pastUserInputs: result.pastUserInputs,
      generatedResponses: result.generatedResponses,
      updatedAt: now,
      lastSyncedAt: now,
      synchronized: true,
      changeId: clientMessageId,
    );

    final List<ChatConversation> merged = index >= 0
        ? (<ChatConversation>[
            ...existing.sublist(0, index),
            updated,
            ...existing.sublist(index + 1),
          ])
        : (<ChatConversation>[...existing, updated]);

    await _localDataSource.save(merged);
  }

  @override
  Future<void> pullRemote() async {
    // No remote pull channel for chat today. Left as a hook for future
    // bi-directional sync or conversation refresh.
  }

  List<String> _readStringList(final dynamic raw) {
    if (raw is List) {
      return raw.map((final dynamic item) => item.toString()).toList();
    }
    return const <String>[];
  }

  static String _generateChangeId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
      Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');

  static String _generateConversationId() =>
      'conversation_${DateTime.now().microsecondsSinceEpoch}';
}
