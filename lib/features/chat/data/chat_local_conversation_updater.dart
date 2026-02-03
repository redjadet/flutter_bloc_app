import 'package:flutter_bloc_app/features/chat/data/chat_sync_payload.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';

class ChatLocalConversationState {
  ChatLocalConversationState({
    required this.conversation,
    required this.messages,
    required this.existing,
    required this.index,
    required this.now,
  });

  final ChatConversation conversation;
  final List<ChatMessage> messages;
  final List<ChatConversation> existing;
  final int index;
  final DateTime now;
}

class ChatLocalConversationUpdater {
  ChatLocalConversationUpdater({
    required final ChatHistoryRepository localDataSource,
  }) : _localDataSource = localDataSource;

  final ChatHistoryRepository _localDataSource;

  Future<ChatLocalConversationState> ensureUserMessagePersisted(
    final ChatSyncPayload payload,
  ) async {
    final List<ChatConversation> existing = await _localDataSource.load();
    final int index = existing.indexWhere(
      (final c) => c.id == payload.conversationId,
    );
    final DateTime now = DateTime.now().toUtc();
    ChatConversation conversation = index >= 0
        ? existing[index]
        : ChatConversation(
            id: payload.conversationId,
            createdAt: payload.createdAt,
            updatedAt: payload.createdAt,
          );

    final List<ChatMessage> messages = List<ChatMessage>.from(
      conversation.messages,
    );
    final bool hasUserMessage = messages.any(
      (final m) => m.clientMessageId == payload.clientMessageId,
    );
    if (!hasUserMessage) {
      messages.add(payload.userMessage(promptText: payload.prompt));
      conversation = conversation.copyWith(
        messages: messages,
        pastUserInputs: payload.pastUserInputs,
        generatedResponses: payload.generatedResponses,
        updatedAt: now,
        model: payload.model,
      );
      final List<ChatConversation> withUserMessage = _mergeConversationIntoList(
        existing,
        conversation,
        index,
      );
      await _localDataSource.save(withUserMessage);
    }

    return ChatLocalConversationState(
      conversation: conversation,
      messages: messages,
      existing: existing,
      index: index,
      now: now,
    );
  }

  Future<void> applyRemoteResult({
    required final ChatLocalConversationState state,
    required final ChatSyncPayload payload,
    required final ChatResult result,
  }) async {
    final List<ChatMessage> messages = List<ChatMessage>.from(state.messages);
    for (int i = 0; i < messages.length; i++) {
      final ChatMessage message = messages[i];
      if (message.clientMessageId == payload.clientMessageId) {
        messages[i] = ChatMessage(
          author: message.author,
          text: message.text,
          clientMessageId: message.clientMessageId,
          createdAt: message.createdAt,
          lastSyncedAt: state.now,
        );
        break;
      }
    }

    messages.add(
      ChatMessage(
        author: result.reply.author,
        text: result.reply.text,
        createdAt: state.now,
        lastSyncedAt: state.now,
      ),
    );

    final ChatConversation updated = state.conversation.copyWith(
      messages: messages,
      pastUserInputs: result.pastUserInputs,
      generatedResponses: result.generatedResponses,
      updatedAt: state.now,
      lastSyncedAt: state.now,
      synchronized: true,
      changeId: payload.clientMessageId,
    );

    final List<ChatConversation> merged = _mergeConversationIntoList(
      state.existing,
      updated,
      state.index,
    );

    await _localDataSource.save(merged);
  }

  List<ChatConversation> _mergeConversationIntoList(
    final List<ChatConversation> existing,
    final ChatConversation conversation,
    final int index,
  ) {
    if (index >= 0 && index < existing.length) {
      return <ChatConversation>[
        ...existing.sublist(0, index),
        conversation,
        ...existing.sublist(index + 1),
      ];
    }
    return <ChatConversation>[...existing, conversation];
  }
}
