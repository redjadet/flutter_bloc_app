import 'package:equatable/equatable.dart';

enum WebsocketStatus { disconnected, connecting, connected, error }

class WebsocketConnectionState extends Equatable {
  const WebsocketConnectionState({required this.status, this.errorMessage});

  const WebsocketConnectionState.disconnected()
    : this(status: WebsocketStatus.disconnected);

  const WebsocketConnectionState.connecting()
    : this(status: WebsocketStatus.connecting);

  const WebsocketConnectionState.connected()
    : this(status: WebsocketStatus.connected);

  const WebsocketConnectionState.error(final String message)
    : this(status: WebsocketStatus.error, errorMessage: message);

  final WebsocketStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[status, errorMessage];
}
