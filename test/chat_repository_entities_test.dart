import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ChatException formats message', () {
    const ChatException exception = ChatException('failure');
    expect(exception.toString(), 'ChatException: failure');
  });

  test('ChatResult exposes reply and history', () {
    const ChatMessage reply = ChatMessage(
      author: ChatAuthor.assistant,
      text: 'Hi',
    );
    const ChatResult result = ChatResult(
      reply: reply,
      pastUserInputs: <String>['Hello'],
      generatedResponses: <String>['Hi'],
    );

    expect(result.reply, reply);
    expect(result.pastUserInputs.single, 'Hello');
    expect(result.generatedResponses.single, 'Hi');
  });
}
