import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation_history.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime t1 = DateTime.utc(2026, 1, 1);
  final DateTime t2 = DateTime.utc(2026, 1, 2);
  final DateTime t3 = DateTime.utc(2026, 1, 3);

  ChatConversation conversation({
    required final String id,
    required final DateTime updatedAt,
    final List<ChatMessage> messages = const <ChatMessage>[],
  }) =>
      ChatConversation(
        id: id,
        createdAt: updatedAt,
        updatedAt: updatedAt,
        messages: messages,
      );

  group('sortChatConversationHistory', () {
    test('orders by updatedAt descending', () {
      final List<ChatConversation> sorted = sortChatConversationHistory(
        <ChatConversation>[
          conversation(id: 'a', updatedAt: t1),
          conversation(id: 'c', updatedAt: t3),
          conversation(id: 'b', updatedAt: t2),
        ],
      );

      expect(sorted.map((final c) => c.id), <String>['c', 'b', 'a']);
    });
  });

  group('chatConversationById', () {
    test('returns match or null', () {
      final List<ChatConversation> history = <ChatConversation>[
        conversation(id: 'a', updatedAt: t1),
        conversation(id: 'b', updatedAt: t2),
      ];

      expect(chatConversationById(history, 'b')?.id, 'b');
      expect(chatConversationById(history, 'missing'), isNull);
      expect(chatConversationById(history, null), isNull);
    });
  });

  group('replaceChatConversation', () {
    test('inserts conversation with content and sorts', () {
      final ChatConversation next = conversation(
        id: 'new',
        updatedAt: t3,
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'hi'),
        ],
      );

      final List<ChatConversation> history = replaceChatConversation(
        next,
        history: <ChatConversation>[
          conversation(id: 'old', updatedAt: t1),
        ],
      );

      expect(history.map((final c) => c.id), <String>['new', 'old']);
    });

    test('updates existing conversation in place', () {
      final ChatConversation updated = conversation(
        id: 'a',
        updatedAt: t3,
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'hi'),
        ],
      );

      final List<ChatConversation> history = replaceChatConversation(
        updated,
        history: <ChatConversation>[
          conversation(id: 'a', updatedAt: t1),
          conversation(id: 'b', updatedAt: t2),
        ],
      );

      expect(history.first.id, 'a');
      expect(history.first.updatedAt, t3);
    });

    test('removes empty conversation from history', () {
      final List<ChatConversation> history = replaceChatConversation(
        conversation(id: 'a', updatedAt: t2),
        history: <ChatConversation>[
          conversation(
            id: 'a',
            updatedAt: t1,
            messages: const <ChatMessage>[
              ChatMessage(author: ChatAuthor.user, text: 'hi'),
            ],
          ),
          conversation(id: 'b', updatedAt: t2),
        ],
      );

      expect(history.map((final c) => c.id), <String>['b']);
    });
  });
}
