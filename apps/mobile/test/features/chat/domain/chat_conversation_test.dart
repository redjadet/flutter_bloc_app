import 'package:flutter_bloc_app/features/chat/data/chat_conversation_dto.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatConversationDto.fromJson', () {
    test('coerces synchronized bool-like values safely', () {
      final ChatConversation conversation =
          ChatConversationDto.fromJson(<String, dynamic>{
            'id': 'c1',
            'createdAt': '2025-01-01T00:00:00.000Z',
            'updatedAt': '2025-01-01T00:00:00.000Z',
            'synchronized': '0',
          }).toDomain();

      expect(conversation.synchronized, isFalse);
    });

    test('throws FormatException when messages is not a list', () {
      expect(
        () => ChatConversationDto.fromJson(<String, dynamic>{
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
