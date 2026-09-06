import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_connection_state.freezed.dart';

enum WebsocketStatus { disconnected, connecting, connected, error }

@freezed
sealed class WebsocketConnectionState with _$WebsocketConnectionState {
  const new _();

  const factory disconnected() = WebsocketConnectionStateDisconnected;

  const factory connecting() = WebsocketConnectionStateConnecting;

  const factory connected() = WebsocketConnectionStateConnected;

  const factory error(String message) = WebsocketConnectionStateError;

  WebsocketStatus get status => when(
    disconnected: () => WebsocketStatus.disconnected,
    connecting: () => WebsocketStatus.connecting,
    connected: () => WebsocketStatus.connected,
    error: (_) => WebsocketStatus.error,
  );

  String? get errorMessage => when(
    disconnected: () => null,
    connecting: () => null,
    connected: () => null,
    error: (m) => m,
  );
}
