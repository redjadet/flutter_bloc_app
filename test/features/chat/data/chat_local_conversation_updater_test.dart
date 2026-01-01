import 'package:flutter_bloc_app/features/chat/data/chat_local_conversation_updater.dart';
import 'package:flutter_bloc_app/features/chat/data/chat_sync_payload.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryChatHistoryRepository implements ChatHistoryRepository {
  List<ChatConversation> _store = <ChatConversation>[];

  @override
  Future<List<ChatConversation>> load() async =>
      List<ChatConversation>.from(_store);

  @override
  Future<void> save(final List<ChatConversation> conversations) async {
    _store = List<ChatConversation>.from(conversations);
  }
}

void main() {
  group('ChatLocalConversationUpdater', () {
    late _InMemoryChatHistoryRepository history;
    late ChatLocalConversationUpdater updater;

    setUp(() {
      history = _InMemoryChatHistoryRepository();
      updater = ChatLocalConversationUpdater(localDataSource: history);
    });

    test('persists user message and applies remote result', () async {
      final ChatSyncPayload payload = ChatSyncPayload(
        conversationId: 'c1',
        prompt: 'Hello',
        pastUserInputs: const <String>[],
        generatedResponses: const <String>[],
        model: 'demo',
        clientMessageId: 'm1',
        createdAt: DateTime.utc(2024, 1, 1),
      );

      final ChatLocalConversationState state = await updater
          .ensureUserMessagePersisted(payload);
      final List<ChatConversation> afterUser = await history.load();
      expect(afterUser, hasLength(1));
      expect(afterUser.first.messages, hasLength(1));
      expect(afterUser.first.messages.first.synchronized, isFalse);

      await updater.applyRemoteResult(
        state: state,
        payload: payload,
        result: ChatResult(
          reply: const ChatMessage(author: ChatAuthor.assistant, text: 'Hi!'),
          pastUserInputs: const <String>['Hello'],
          generatedResponses: const <String>['Hi!'],
        ),
      );

      final List<ChatConversation> afterRemote = await history.load();
      expect(afterRemote, hasLength(1));
      expect(afterRemote.first.synchronized, isTrue);
      expect(afterRemote.first.messages, hasLength(2));
      expect(afterRemote.first.messages.last.text, 'Hi!');
    });
  });
}
