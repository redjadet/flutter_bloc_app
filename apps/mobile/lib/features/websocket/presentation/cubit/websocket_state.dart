import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_state.freezed.dart';

@freezed
abstract class WebsocketState with _$WebsocketState {
  const factory WebsocketState({
    required Uri endpoint,
    required WebsocketStatus status,
    @Default(<WebsocketMessage>[]) List<WebsocketMessage> messages,
    String? errorMessage,
    @Default(false) bool isSending,
  }) = _WebsocketState;

  const WebsocketState._();

  factory WebsocketState.initial(Uri endpoint) => WebsocketState(
    endpoint: endpoint,
    status: WebsocketStatus.disconnected,
  );

  bool get isConnected => status == WebsocketStatus.connected;
  bool get isConnecting => status == WebsocketStatus.connecting;

  WebsocketState appendMessage(WebsocketMessage message) =>
      copyWith(messages: <WebsocketMessage>[...messages, message]);
}
