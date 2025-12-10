import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

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
  // ignore: cancel_subscriptions - Subscription is properly cancelled in close() method
  StreamSubscription<WebsocketConnectionState>? _statusSubscription;
  // ignore: cancel_subscriptions - Subscription is properly cancelled in close() method
  StreamSubscription<WebsocketMessage>? _messageSubscription;

  Future<void> connect() async {
    if (state.isConnected || state.isConnecting) {
      return;
    }
    emit(state.copyWith(status: WebsocketStatus.connecting, clearError: true));
    await CubitExceptionHandler.executeAsyncVoid(
      operation: _repository.connect,
      onError: (final String errorMessage) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: WebsocketStatus.error,
            errorMessage: errorMessage,
            isSending: false,
          ),
        );
      },
      logContext: 'WebsocketCubit.connect',
    );
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
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.send(message),
      onSuccess: () {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
      onError: (final String errorMessage) {
        if (isClosed) return;
        emit(state.copyWith(isSending: false, errorMessage: errorMessage));
      },
      logContext: 'WebsocketCubit.sendMessage',
    );
  }

  void _onIncomingMessage(final WebsocketMessage message) {
    if (isClosed) return;
    emit(state.appendMessage(message));
  }

  void _onConnectionState(final WebsocketConnectionState connectionState) {
    if (isClosed) return;
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
    // Nullify references before canceling to prevent race conditions
    final StreamSubscription<WebsocketConnectionState>? statusSub =
        _statusSubscription;
    _statusSubscription = null;
    final StreamSubscription<WebsocketMessage>? messageSub =
        _messageSubscription;
    _messageSubscription = null;

    await statusSub?.cancel();
    await messageSub?.cancel();
    await _repository.disconnect();
    return super.close();
  }
}
