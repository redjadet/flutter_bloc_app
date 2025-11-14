import 'dart:async';

import 'package:flutter_bloc_app/features/websocket/domain/websocket_connection_state.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_repository.dart';
import 'package:flutter_bloc_app/shared/utils/websocket_guard.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef WebSocketConnector = FutureOr<WebSocketChannel> Function(Uri uri);

class EchoWebsocketRepository implements WebsocketRepository {
  EchoWebsocketRepository({
    final Uri? endpoint,
    final WebSocketConnector? connector,
    final Duration? connectionTimeout,
  }) : endpoint = endpoint ?? Uri.parse(_kDefaultEndpoint),
       _connector = connector ?? _defaultConnector,
       _connectionTimeout = connectionTimeout ?? const Duration(seconds: 10) {
    _stateController.add(_state);
  }

  // static const String _kDefaultEndpoint = 'wss://echo.websocket.events';
  static const String _kDefaultEndpoint = 'wss://ws.postman-echo.com/raw';

  @override
  final Uri endpoint;
  final WebSocketConnector _connector;
  final Duration _connectionTimeout;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  Completer<void>? _connectionCompleter;

  final StreamController<WebsocketMessage> _messagesController =
      StreamController<WebsocketMessage>.broadcast();
  final StreamController<WebsocketConnectionState> _stateController =
      StreamController<WebsocketConnectionState>.broadcast();

  WebsocketConnectionState _state =
      const WebsocketConnectionState.disconnected();

  static Future<WebSocketChannel> _defaultConnector(final Uri uri) async =>
      WebSocketChannel.connect(uri);

  @override
  Stream<WebsocketConnectionState> get connectionStates =>
      _stateController.stream;

  @override
  WebsocketConnectionState get currentState => _state;

  @override
  Stream<WebsocketMessage> get incomingMessages => _messagesController.stream;

  @override
  Future<void> connect() async {
    // If already connected, return immediately
    if (_channel != null) {
      return;
    }

    // If connection is in progress, wait for it to complete
    // If it fails, the completer will be cleared and we can retry
    final Completer<void>? existingCompleter = _connectionCompleter;
    if (existingCompleter != null) {
      try {
        return await existingCompleter.future;
      } on Object catch (_) {
        // Connection failed, completer was cleared, retry below
        if (_connectionCompleter == null && _channel == null) {
          // Fall through to start new connection attempt
        } else {
          // Another connection succeeded or is in progress
          return;
        }
      }
    }

    // Start new connection attempt
    final Completer<void> completer = Completer<void>();
    _connectionCompleter = completer;

    _updateState(const WebsocketConnectionState.connecting());
    try {
      final WebSocketChannel channel = await _connectWithTimeout();
      _channel = channel;
      _channelSubscription = channel.stream.listen(
        _handleIncoming,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: true,
      );
      _updateState(const WebsocketConnectionState.connected());
      if (!completer.isCompleted) {
        completer.complete();
      }
      _connectionCompleter = null;
    } on TimeoutException catch (error) {
      _connectionCompleter = null;
      await _handleError(error);
      // Don't complete completer with error - let concurrent calls retry
      // The rethrow will propagate the error to the current caller
      rethrow;
    } on Object catch (error) {
      _connectionCompleter = null;
      await _handleError(error);
      // Don't complete completer with error - let concurrent calls retry
      // The rethrow will propagate the error to the current caller
      rethrow;
    }
  }

  Future<WebSocketChannel> _connectWithTimeout() => WebSocketGuard.connect(
    connect: () async => Future<WebSocketChannel>.value(_connector(endpoint)),
    timeout: _connectionTimeout,
    logContext: 'EchoWebsocketRepository.connect',
  );

  void _handleIncoming(final dynamic data) {
    final String message = data?.toString() ?? '';
    if (_messagesController.isClosed) {
      return;
    }
    _messagesController.add(
      WebsocketMessage(
        direction: WebsocketMessageDirection.incoming,
        text: message,
      ),
    );
  }

  Future<void> _handleError(
    final Object error, [
    final StackTrace? stackTrace,
  ]) async {
    await _cleanupChannel();
    _updateState(WebsocketConnectionState.error(error.toString()));
  }

  Future<void> _handleDone() async {
    await _cleanupChannel();
    _updateState(const WebsocketConnectionState.disconnected());
  }

  Future<void> _cleanupChannel() async {
    final StreamSubscription<dynamic>? subscription = _channelSubscription;
    _channelSubscription = null;
    if (subscription != null) {
      await subscription.cancel();
    }
    _channel = null;
    // Note: Don't complete _connectionCompleter here - it's handled in connect() method
    // This prevents double completion when cleanup is called from error handlers
  }

  void _updateState(final WebsocketConnectionState state) {
    _state = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  @override
  Future<void> disconnect() async {
    // Cancel any pending connection attempt
    _connectionCompleter?.completeError(
      StateError('Connection cancelled due to disconnect'),
    );
    _connectionCompleter = null;

    if (_channel == null) {
      if (_state.status != WebsocketStatus.disconnected) {
        _updateState(const WebsocketConnectionState.disconnected());
      }
      return;
    }
    await _channel!.sink.close();
    await _channelSubscription?.cancel();
    _channel = null;
    _channelSubscription = null;
    _updateState(const WebsocketConnectionState.disconnected());
  }

  @override
  Future<void> send(final String message) async {
    final WebSocketChannel? channel = _channel;
    if (channel == null) {
      throw StateError('WebSocket is not connected');
    }
    channel.sink.add(message);
  }

  @override
  Future<void> dispose() async {
    // Cancel any pending connection attempt
    _connectionCompleter?.completeError(
      StateError('Connection cancelled due to dispose'),
    );
    _connectionCompleter = null;

    await disconnect();
    await _messagesController.close();
    await _stateController.close();
  }
}
