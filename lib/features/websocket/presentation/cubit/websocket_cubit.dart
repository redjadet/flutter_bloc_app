import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

class WebsocketCubit extends Cubit<WebsocketState>
    with CubitSubscriptionMixin<WebsocketState> {
  WebsocketCubit({required final WebsocketRepository repository})
    : _repository = repository,
      super(WebsocketState.initial(repository.endpoint)) {
    _statusSubscription = _repository.connectionStates.listen(
      _onConnectionState,
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'WebsocketCubit connection state stream error',
          error,
          stackTrace,
        );
      },
    );
    _messageSubscription = _repository.incomingMessages.listen(
      _onIncomingMessage,
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'WebsocketCubit incoming messages stream error',
          error,
          stackTrace,
        );
      },
    );
    registerSubscription(_statusSubscription);
    registerSubscription(_messageSubscription);
  }

  final WebsocketRepository _repository;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<WebsocketConnectionState>? _statusSubscription;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<WebsocketMessage>? _messageSubscription;

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
      onError: (final errorMessage) {
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
          .copyWith(isSending: true, errorMessage: null),
    );
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.send(message),
      isAlive: () => !isClosed,
      onSuccess: () {
        if (isClosed) return;
        emit(state.copyWith(isSending: false));
      },
      onError: (final errorMessage) {
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
      ),
    );
  }

  @override
  Future<void> close() async {
    _statusSubscription = null;
    _messageSubscription = null;
    await _repository.disconnect();
    return super.close();
  }
}
