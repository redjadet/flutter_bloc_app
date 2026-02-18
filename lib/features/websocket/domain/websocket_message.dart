import 'package:freezed_annotation/freezed_annotation.dart';

part 'websocket_message.freezed.dart';

/// Identifies whether a message is incoming, outgoing, or system generated.
enum WebsocketMessageDirection { incoming, outgoing, system }

/// Represents a message that flows through the WebSocket stream.
@freezed
abstract class WebsocketMessage with _$WebsocketMessage {
  const factory WebsocketMessage({
    required final WebsocketMessageDirection direction,
    required final String text,
  }) = _WebsocketMessage;
}
