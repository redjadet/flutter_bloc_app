import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';

class WebsocketState extends Equatable {
  const WebsocketState({
    required this.endpoint,
    required this.status,
    required this.messages,
    this.errorMessage,
    this.isSending = false,
  });

  factory WebsocketState.initial(Uri endpoint) {
    return WebsocketState(
      endpoint: endpoint,
      status: WebsocketStatus.disconnected,
      messages: const <WebsocketMessage>[],
    );
  }

  final Uri endpoint;
  final WebsocketStatus status;
  final List<WebsocketMessage> messages;
  final String? errorMessage;
  final bool isSending;

  bool get isConnected => status == WebsocketStatus.connected;
  bool get isConnecting => status == WebsocketStatus.connecting;

  WebsocketState copyWith({
    WebsocketStatus? status,
    List<WebsocketMessage>? messages,
    String? errorMessage,
    bool clearError = false,
    bool? isSending,
  }) {
    return WebsocketState(
      endpoint: endpoint,
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSending: isSending ?? this.isSending,
    );
  }

  WebsocketState appendMessage(WebsocketMessage message) {
    return copyWith(messages: <WebsocketMessage>[...messages, message]);
  }

  static const DeepCollectionEquality _listEquality = DeepCollectionEquality();

  @override
  List<Object?> get props => <Object?>[
    endpoint,
    status,
    isSending,
    errorMessage,
    _listEquality.hash(messages),
  ];
}
