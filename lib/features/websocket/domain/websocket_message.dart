import 'package:equatable/equatable.dart';

/// Represents a message that flows through the WebSocket stream.
class WebsocketMessage extends Equatable {
  const WebsocketMessage({required this.direction, required this.text});

  final WebsocketMessageDirection direction;
  final String text;

  @override
  List<Object?> get props => <Object?>[direction, text];
}

/// Identifies whether a message is incoming, outgoing, or system generated.
enum WebsocketMessageDirection { incoming, outgoing, system }
