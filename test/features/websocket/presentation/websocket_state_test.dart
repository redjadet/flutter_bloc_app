import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';

void main() {
  final Uri endpoint = Uri.parse('wss://example.com');

  test('messages list is unmodifiable', () {
    final WebsocketState state = WebsocketState.initial(endpoint);
    expect(
      () => state.messages.add(
        const WebsocketMessage(
          direction: WebsocketMessageDirection.incoming,
          text: 'hello',
        ),
      ),
      throwsUnsupportedError,
    );
  });

  test('appendMessage does not mutate previous state', () {
    final WebsocketState state = WebsocketState.initial(endpoint);
    final WebsocketMessage message = const WebsocketMessage(
      direction: WebsocketMessageDirection.outgoing,
      text: 'ping',
    );

    final WebsocketState nextState = state.appendMessage(message);

    expect(state.messages, isEmpty);
    expect(nextState.messages, <WebsocketMessage>[message]);
  });
}
