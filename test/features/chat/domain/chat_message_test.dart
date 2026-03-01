import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage.fromJson', () {
    test('coerces synchronized bool-like values safely', () {
      final ChatMessage fromString = ChatMessage.fromJson(<String, dynamic>{
        'author': 'assistant',
        'text': 'hello',
        'synchronized': 'false',
      });
      final ChatMessage fromNumber = ChatMessage.fromJson(<String, dynamic>{
        'author': 'assistant',
        'text': 'hello',
        'synchronized': 1,
      });

      expect(fromString.synchronized, isFalse);
      expect(fromNumber.synchronized, isTrue);
    });

    test('ignores non-string clientMessageId without throwing', () {
      final ChatMessage message = ChatMessage.fromJson(<String, dynamic>{
        'author': 'assistant',
        'text': 'hello',
        'clientMessageId': 123,
      });

      expect(message.clientMessageId, isNull);
      expect(message.text, 'hello');
    });
  });
}
