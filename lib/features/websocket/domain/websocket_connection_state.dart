import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_connection_state.freezed.dart';

enum WebsocketStatus { disconnected, connecting, connected, error }

@freezed
sealed class WebsocketConnectionState with _$WebsocketConnectionState {
  const WebsocketConnectionState._();

  const factory WebsocketConnectionState.disconnected() =
      WebsocketConnectionStateDisconnected;

  const factory WebsocketConnectionState.connecting() =
      WebsocketConnectionStateConnecting;

  const factory WebsocketConnectionState.connected() =
      WebsocketConnectionStateConnected;

  const factory WebsocketConnectionState.error(final String message) =
      WebsocketConnectionStateError;

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
    error: (final m) => m,
  );
}
