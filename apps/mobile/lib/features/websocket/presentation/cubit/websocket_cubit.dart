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
      onError: (final errorMessage) {
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
    await _repository.disconnect();
    await connect();
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
  }

  Future<bool> sendMessage(final String rawMessage) async {
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
      onError: (final errorMessage) {
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

  void _onIncomingMessage(final WebsocketMessage message) {
    if (isClosed) return;
    emit(
      state.appendMessage(
        message.copyWith(sequence: _messageSequence++),
      ),
    );
  }

  void _onConnectionState(final WebsocketConnectionState connectionState) {
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

  @override
  Future<void> close() async {
    _inFlightSends = 0;
    _statusSubscription = null;
    _messageSubscription = null;
    await _repository.disconnect();
    return super.close();
  }
}
