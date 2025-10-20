import 'dart:async';

import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';

abstract interface class WebsocketRepository {
  Uri get endpoint;

  Stream<WebsocketConnectionState> get connectionStates;

  Stream<WebsocketMessage> get incomingMessages;

  WebsocketConnectionState get currentState;

  Future<void> connect();

  Future<void> disconnect();

  Future<void> send(final String message);

  Future<void> dispose();
}
