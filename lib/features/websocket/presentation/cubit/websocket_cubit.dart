import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';

class WebsocketCubit extends Cubit<WebsocketState> {
  WebsocketCubit({required final WebsocketRepository repository})
    : _repository = repository,
      super(WebsocketState.initial(repository.endpoint)) {
    _statusSubscription = _repository.connectionStates.listen(
      _onConnectionState,
    );
    _messageSubscription = _repository.incomingMessages.listen(
      _onIncomingMessage,
    );
  }

  final WebsocketRepository _repository;
  StreamSubscription<WebsocketConnectionState>? _statusSubscription;
  StreamSubscription<WebsocketMessage>? _messageSubscription;

  Future<void> connect() async {
    if (state.isConnected || state.isConnecting) {
      return;
    }
    emit(state.copyWith(status: WebsocketStatus.connecting, clearError: true));
    try {
      await _repository.connect();
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: WebsocketStatus.error,
          errorMessage: error.toString(),
          isSending: false,
        ),
      );
    }
  }

  Future<void> reconnect() async {
    await _repository.disconnect();
    await connect();
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
  }

  Future<void> sendMessage(final String rawMessage) async {
    final String message = rawMessage.trim();
    if (message.isEmpty || !state.isConnected) {
      return;
    }
    emit(
      state
          .appendMessage(
            WebsocketMessage(
              direction: WebsocketMessageDirection.outgoing,
              text: message,
            ),
          )
          .copyWith(isSending: true, clearError: true),
    );
    try {
      await _repository.send(message);
    } on Object catch (error) {
      emit(state.copyWith(isSending: false, errorMessage: error.toString()));
      return;
    }
    emit(state.copyWith(isSending: false));
  }

  void _onIncomingMessage(final WebsocketMessage message) {
    emit(state.appendMessage(message));
  }

  void _onConnectionState(final WebsocketConnectionState connectionState) {
    emit(
      state.copyWith(
        status: connectionState.status,
        errorMessage: connectionState.errorMessage,
        clearError: connectionState.errorMessage == null,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _repository.disconnect();
    return super.close();
  }
}
