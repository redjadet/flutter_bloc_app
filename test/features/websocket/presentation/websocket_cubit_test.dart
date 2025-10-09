import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_cubit.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockWebsocketRepository extends Mock implements WebsocketRepository {}

void main() {
  late _MockWebsocketRepository repository;
  late StreamController<WebsocketConnectionState> connectionController;
  late StreamController<WebsocketMessage> messageController;
  final Uri endpoint = Uri.parse('wss://echo.websocket.events');

  setUp(() {
    repository = _MockWebsocketRepository();
    connectionController =
        StreamController<WebsocketConnectionState>.broadcast();
    messageController = StreamController<WebsocketMessage>.broadcast();

    when(() => repository.endpoint).thenReturn(endpoint);
    when(
      () => repository.connectionStates,
    ).thenAnswer((_) => connectionController.stream);
    when(
      () => repository.incomingMessages,
    ).thenAnswer((_) => messageController.stream);
    when(
      () => repository.currentState,
    ).thenReturn(const WebsocketConnectionState.disconnected());
    when(() => repository.disconnect()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await connectionController.close();
    await messageController.close();
  });

  blocTest<WebsocketCubit, WebsocketState>(
    'connect emits connecting then connected states',
    build: () {
      when(() => repository.connect()).thenAnswer((_) async {
        connectionController.add(const WebsocketConnectionState.connected());
      });
      return WebsocketCubit(repository: repository);
    },
    act: (cubit) async {
      await cubit.connect();
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => <WebsocketState>[
      WebsocketState.initial(
        endpoint,
      ).copyWith(status: WebsocketStatus.connecting, clearError: true),
      WebsocketState.initial(
        endpoint,
      ).copyWith(status: WebsocketStatus.connected, clearError: true),
    ],
  );

  blocTest<WebsocketCubit, WebsocketState>(
    'sendMessage appends outgoing and incoming messages',
    build: () {
      when(() => repository.connect()).thenAnswer((_) async {});
      when(() => repository.send(any())).thenAnswer((_) async {
        messageController.add(
          const WebsocketMessage(
            direction: WebsocketMessageDirection.incoming,
            text: 'echo: hi',
          ),
        );
      });
      final WebsocketCubit cubit = WebsocketCubit(repository: repository);
      connectionController.add(const WebsocketConnectionState.connected());
      return cubit;
    },
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.sendMessage('hi');
      await Future<void>.delayed(Duration.zero);
    },
    expect: () {
      final WebsocketMessage outgoing = const WebsocketMessage(
        direction: WebsocketMessageDirection.outgoing,
        text: 'hi',
      );
      final WebsocketMessage incoming = const WebsocketMessage(
        direction: WebsocketMessageDirection.incoming,
        text: 'echo: hi',
      );
      final WebsocketState connected = WebsocketState.initial(
        endpoint,
      ).copyWith(status: WebsocketStatus.connected, clearError: true);
      final WebsocketState sending = connected
          .appendMessage(outgoing)
          .copyWith(
            status: WebsocketStatus.connected,
            isSending: true,
            clearError: true,
          );
      final WebsocketState withIncoming = sending
          .appendMessage(incoming)
          .copyWith(status: WebsocketStatus.connected, isSending: true);
      final WebsocketState completed = withIncoming.copyWith(
        status: WebsocketStatus.connected,
        isSending: false,
      );
      return <WebsocketState>[connected, sending, withIncoming, completed];
    },
    verify: (cubit) {
      verify(() => repository.send('hi')).called(1);
    },
  );

  blocTest<WebsocketCubit, WebsocketState>(
    'incoming error updates error message',
    build: () {
      when(() => repository.connect()).thenAnswer((_) async {});
      final WebsocketCubit cubit = WebsocketCubit(repository: repository);
      connectionController.add(const WebsocketConnectionState.error('boom'));
      return cubit;
    },
    expect: () => <WebsocketState>[
      WebsocketState.initial(
        endpoint,
      ).copyWith(status: WebsocketStatus.error, errorMessage: 'boom'),
    ],
  );
}
