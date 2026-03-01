import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatConversation.fromJson', () {
    test('coerces synchronized bool-like values safely', () {
      final ChatConversation conversation =
          ChatConversation.fromJson(<String, dynamic>{
            'id': 'c1',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-01T00:00:00.000Z',
            'synchronized': '0',
          });

      expect(conversation.synchronized, isFalse);
    });

    test('throws FormatException when messages is not a list', () {
      expect(
        () => ChatConversation.fromJson(<String, dynamic>{
          'id': 'c1',
          'createdAt': '2025-01-01T00:00:00.000Z',
          'updatedAt': '2025-01-01T00:00:00.000Z',
          'messages': <String, dynamic>{'not': 'a-list'},
        }),
        throwsFormatException,
      );
    });
  });
}
