import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/app/utils/network_error_mapper.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';

class WebsocketCubit extends Cubit<WebsocketState>
    with CubitSubscriptionMixin<WebsocketState> {
  WebsocketCubit({required WebsocketRepository repository})
    : _repository = repository,
      super(WebsocketState.initial(repository.endpoint)) {
    _statusSubscription = _repository.connectionStates.listen(
      _onConnectionState,
      onError: _onStreamError,
    );
    _messageSubscription = _repository.incomingMessages.listen(
      _onIncomingMessage,
      onError: _onStreamError,
    );
    registerSubscription(_statusSubscription);
    registerSubscription(_messageSubscription);
  }

  final WebsocketRepository _repository;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<WebsocketConnectionState>? _statusSubscription;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<WebsocketMessage>? _messageSubscription;

  /// Count of in-flight `repository.send` calls so overlapping sends do not
  /// clear [WebsocketState.isSending] while another send is still pending.
  int _inFlightSends = 0;
  int _messageSequence = 0;

  Future<void> connect() async {
    if (state.isConnected || state.isConnecting) {
      return;
    }
    emit(
      state.copyWith(status: WebsocketStatus.connecting, errorMessage: null),
    );
    await CubitExceptionHandler.executeAsyncVoid(
      operation: _repository.connect,
      isAlive: () => !isClosed,
      onError: (errorMessage) {
        if (isClosed) return;
        _inFlightSends = 0;
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
    var disconnectSucceeded = true;
    await CubitExceptionHandler.executeAsyncVoid(
      operation: _repository.disconnect,
      isAlive: () => !isClosed,
      onSuccess: () {
        disconnectSucceeded = true;
      },
      onError: (errorMessage) {
        disconnectSucceeded = false;
        _emitCommandFailure(errorMessage);
      },
      logContext: 'WebsocketCubit.reconnect.disconnect',
    );
    if (!disconnectSucceeded || isClosed) {
      return;
    }
    await connect();
  }

  Future<void> disconnect() async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: _repository.disconnect,
      isAlive: () => !isClosed,
      onError: _emitCommandFailure,
      logContext: 'WebsocketCubit.disconnect',
    );
  }

  Future<bool> sendMessage(String rawMessage) async {
    final String message = rawMessage.trim();
    if (message.isEmpty || !state.isConnected) {
      return false;
    }
    var sendSucceeded = false;
    _inFlightSends++;
    emit(
      state
          .appendMessage(
            WebsocketMessage(
              sequence: _messageSequence++,
              direction: WebsocketMessageDirection.outgoing,
              text: message,
            ),
          )
          .copyWith(
            isSending: _inFlightSends > 0,
            errorMessage: null,
          ),
    );
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.send(message),
      isAlive: () => !isClosed,
      onSuccess: () {
        if (isClosed) return;
        sendSucceeded = true;
        _decrementInFlightSends();
        emit(state.copyWith(isSending: _inFlightSends > 0));
      },
      onError: (errorMessage) {
        if (isClosed) return;
        _decrementInFlightSends();
        emit(
          state.copyWith(
            isSending: _inFlightSends > 0,
            errorMessage: errorMessage,
          ),
        );
      },
      logContext: 'WebsocketCubit.sendMessage',
    );
    return sendSucceeded;
  }

  void _decrementInFlightSends() {
    if (_inFlightSends > 0) {
      _inFlightSends--;
    }
  }

  void _onIncomingMessage(WebsocketMessage message) {
    if (isClosed) return;
    emit(
      state.appendMessage(
        message.copyWith(sequence: _messageSequence++),
      ),
    );
  }

  void _onConnectionState(WebsocketConnectionState connectionState) {
    if (isClosed) return;
    if (connectionState.status != WebsocketStatus.connected) {
      _inFlightSends = 0;
    }
    emit(
      state.copyWith(
        status: connectionState.status,
        errorMessage: connectionState.errorMessage,
        isSending:
            connectionState.status == WebsocketStatus.connected &&
            _inFlightSends > 0,
      ),
    );
  }

  void _onStreamError(Object error, StackTrace stackTrace) {
    AppLogger.error('WebsocketCubit stream error', error, stackTrace);
    if (isClosed) return;
    _emitCommandFailure(NetworkErrorMapper.getErrorMessage(error));
  }

  void _emitCommandFailure(String errorMessage) {
    if (isClosed) return;
    _inFlightSends = 0;
    emit(
      state.copyWith(
        status: WebsocketStatus.error,
        errorMessage: errorMessage,
        isSending: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    _inFlightSends = 0;
    _statusSubscription = null;
    _messageSubscription = null;
    await CubitExceptionHandler.executeAsyncVoid(
      operation: _repository.disconnect,
      isAlive: () => true,
      onError: (_) {},
      logContext: 'WebsocketCubit.close',
    );
    return super.close();
  }
}
