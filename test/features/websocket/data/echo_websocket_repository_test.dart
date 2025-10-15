import 'dart:async';

import 'package:flutter_bloc_app/features/websocket/data/echo_websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _MockWebSocketChannel extends Mock implements WebSocketChannel {}

class _MockWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  group('EchoWebsocketRepository', () {
    test('connects, relays messages, and disconnects cleanly', () async {
      final _MockWebSocketChannel channel = _MockWebSocketChannel();
      final _MockWebSocketSink sink = _MockWebSocketSink();
      final StreamController<dynamic> controller =
          StreamController<dynamic>.broadcast();
      when(() => channel.stream).thenAnswer((_) => controller.stream);
      when(() => channel.sink).thenReturn(sink);
      when(() => sink.add(any<dynamic>())).thenReturn(null);
      when(() => sink.close()).thenAnswer((_) async {});

      final EchoWebsocketRepository repository = EchoWebsocketRepository(
        endpoint: Uri.parse('wss://echo.websocket.events'),
        connector: (_) => channel,
        connectionTimeout: Duration.zero,
      );
      final List<WebsocketConnectionState> states =
          <WebsocketConnectionState>[];
      final List<WebsocketMessage> messages = <WebsocketMessage>[];
      final StreamSubscription<WebsocketConnectionState> stateSub = repository
          .connectionStates
          .listen(states.add);
      final StreamSubscription<WebsocketMessage> messageSub = repository
          .incomingMessages
          .listen(messages.add);

      await repository.connect();
      controller.add('hello');
      await Future<void>.delayed(Duration.zero);
      await repository.send('ping');
      await repository.disconnect();
      await Future<void>.delayed(Duration.zero);

      expect(
        states.map((state) => state.status),
        contains(WebsocketStatus.connected),
      );
      expect(states.last.status, WebsocketStatus.disconnected);
      expect(messages.single.text, 'hello');
      expect(messages.single.direction, WebsocketMessageDirection.incoming);
      verify(() => sink.add('ping')).called(1);
      verify(() => sink.close()).called(1);

      await stateSub.cancel();
      await messageSub.cancel();
      await controller.close();
      await repository.dispose();
    });

    test('emits error state when connector throws', () async {
      final EchoWebsocketRepository repository = EchoWebsocketRepository(
        connector: (_) => throw Exception('unable to connect'),
        connectionTimeout: Duration.zero,
      );
      WebsocketConnectionState? lastState;
      final StreamSubscription<WebsocketConnectionState> stateSub = repository
          .connectionStates
          .listen((event) {
            lastState = event;
          });

      await expectLater(repository.connect(), throwsException);
      await Future<void>.delayed(Duration.zero);
      expect(lastState?.status, WebsocketStatus.error);
      expect(lastState?.errorMessage, contains('unable to connect'));

      await repository.dispose();
      await stateSub.cancel();
    });
  });
}
