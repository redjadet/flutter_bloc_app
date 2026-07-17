import 'package:flutter_bloc_app/features/chat/data/chat_message_dto.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessageDto.fromJson', () {
    test('coerces synchronized bool-like values safely', () {
      final ChatMessage fromString = ChatMessageDto.fromJson(<String, dynamic>{
        'author': 'assistant',
        'text': 'hello',
        'synchronized': 'false',
      }).toDomain();
      final ChatMessage fromNumber = ChatMessageDto.fromJson(<String, dynamic>{
        'author': 'assistant',
        'text': 'hello',
        'synchronized': 1,
      }).toDomain();

      expect(fromString.synchronized, isFalse);
      expect(fromNumber.synchronized, isTrue);
    });

    test('ignores non-string clientMessageId without throwing', () {
      final ChatMessage message = ChatMessageDto.fromJson(<String, dynamic>{
        'author': 'assistant',
        'text': 'hello',
        'clientMessageId': 123,
      }).toDomain();

      expect(message.clientMessageId, isNull);
      expect(message.text, 'hello');
    });
  });
}
