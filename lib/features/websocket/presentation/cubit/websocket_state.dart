import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';

class WebsocketState extends Equatable {
  WebsocketState({
    required this.endpoint,
    required this.status,
    required final List<WebsocketMessage> messages,
    this.errorMessage,
    this.isSending = false,
  }) : _messages = List<WebsocketMessage>.unmodifiable(messages);

  factory WebsocketState.initial(final Uri endpoint) => WebsocketState(
    endpoint: endpoint,
    status: WebsocketStatus.disconnected,
    messages: const <WebsocketMessage>[],
  );

  final Uri endpoint;
  final WebsocketStatus status;
  final List<WebsocketMessage> _messages;
  final String? errorMessage;
  final bool isSending;

  List<WebsocketMessage> get messages => _messages;

  bool get isConnected => status == WebsocketStatus.connected;
  bool get isConnecting => status == WebsocketStatus.connecting;

  WebsocketState copyWith({
    final WebsocketStatus? status,
    final List<WebsocketMessage>? messages,
    final String? errorMessage,
    final bool clearError = false,
    final bool? isSending,
  }) => WebsocketState(
    endpoint: endpoint,
    status: status ?? this.status,
    messages: messages ?? _messages,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    isSending: isSending ?? this.isSending,
  );

  WebsocketState appendMessage(final WebsocketMessage message) =>
      copyWith(messages: <WebsocketMessage>[..._messages, message]);

  static const DeepCollectionEquality _listEquality = DeepCollectionEquality();

  @override
  List<Object?> get props => <Object?>[
    endpoint,
    status,
    isSending,
    errorMessage,
    _listEquality.hash(_messages),
  ];
}
