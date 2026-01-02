import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_state.freezed.dart';

@freezed
abstract class WebsocketState with _$WebsocketState {
  const factory WebsocketState({
    required final Uri endpoint,
    required final WebsocketStatus status,
    @Default(<WebsocketMessage>[]) final List<WebsocketMessage> messages,
    final String? errorMessage,
    @Default(false) final bool isSending,
  }) = _WebsocketState;

  const WebsocketState._();

  factory WebsocketState.initial(final Uri endpoint) => WebsocketState(
    endpoint: endpoint,
    status: WebsocketStatus.disconnected,
  );

  bool get isConnected => status == WebsocketStatus.connected;
  bool get isConnecting => status == WebsocketStatus.connecting;

  WebsocketState appendMessage(final WebsocketMessage message) =>
      copyWith(messages: <WebsocketMessage>[...messages, message]);
}
