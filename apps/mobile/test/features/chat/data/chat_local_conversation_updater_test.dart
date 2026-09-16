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
  Future<void> save(List<ChatConversation> conversations) async {
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

    test(
      'applyRemoteResult does not restore conversations deleted during sync',
      () async {
        final ChatConversation other = ChatConversation(
          id: 'c-other',
          createdAt: DateTime.utc(2024, 1, 1),
          updatedAt: DateTime.utc(2024, 1, 1),
          messages: const <ChatMessage>[
            ChatMessage(author: ChatAuthor.user, text: 'Other'),
          ],
        );
        await history.save(<ChatConversation>[other]);

        final ChatSyncPayload payload = ChatSyncPayload(
          conversationId: 'c1',
          prompt: 'Hello',
          pastUserInputs: const <String>[],
          generatedResponses: const <String>[],
          model: 'demo',
          clientMessageId: 'm1',
          createdAt: DateTime.utc(2024, 1, 2),
        );

        final ChatLocalConversationState state = await updater
            .ensureUserMessagePersisted(payload);
        expect(
          (await history.load()).map((c) => c.id),
          containsAll(<String>['c-other', 'c1']),
        );

        await history.save(<ChatConversation>[
          (await history.load()).firstWhere((c) => c.id == 'c1'),
        ]);

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
        expect(afterRemote.single.id, 'c1');
        expect(afterRemote.single.messages, hasLength(2));
      },
    );

    test(
      'applyRemoteResult merges assistant reply into fresh conversation state',
      () async {
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

        final ChatConversation beforeRemote = (await history.load()).single;
        final ChatConversation withLocalFollowUp = beforeRemote.copyWith(
          messages: <ChatMessage>[
            ...beforeRemote.messages,
            const ChatMessage(
              author: ChatAuthor.user,
              text: 'Follow up',
              clientMessageId: 'm2',
            ),
          ],
        );
        await history.save(<ChatConversation>[withLocalFollowUp]);

        await updater.applyRemoteResult(
          state: state,
          payload: payload,
          result: ChatResult(
            reply: const ChatMessage(author: ChatAuthor.assistant, text: 'Hi!'),
            pastUserInputs: const <String>['Hello'],
            generatedResponses: const <String>['Hi!'],
          ),
        );

        final ChatConversation afterRemote = (await history.load()).single;
        expect(afterRemote.messages, hasLength(3));
        expect(afterRemote.messages[1].text, 'Follow up');
        expect(afterRemote.messages.last.text, 'Hi!');
      },
    );

    test(
      'applyTerminalSyncFailure preserves fresh conversation state',
      () async {
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
        final ChatConversation beforeFailure = (await history.load()).single;
        await history.save(<ChatConversation>[
          beforeFailure.copyWith(
            messages: <ChatMessage>[
              ...beforeFailure.messages,
              const ChatMessage(
                author: ChatAuthor.user,
                text: 'Follow up',
                clientMessageId: 'm2',
              ),
            ],
          ),
        ]);

        await updater.applyTerminalSyncFailure(
          state: state,
          payload: payload,
          failureCode: 'auth_required',
        );

        final ChatConversation afterFailure = (await history.load()).single;
        expect(afterFailure.messages, hasLength(2));
        expect(
          afterFailure.messages[0].terminalSyncFailureCode,
          'auth_required',
        );
        expect(afterFailure.messages[1].text, 'Follow up');
      },
    );
  });
}
