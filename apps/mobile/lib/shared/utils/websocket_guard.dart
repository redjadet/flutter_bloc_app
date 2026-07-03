import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Utility helper to wrap WebSocket connections with consistent timeout and
/// logging behaviour.
class WebSocketGuard {
  WebSocketGuard._();

  /// Executes [connect] and returns the established [WebSocketChannel].
  ///
  /// If [timeout] is greater than zero, the connection attempt is bounded by
  /// that duration. Timeout and other exceptions are logged using [logContext]
  /// before being rethrown.
  static Future<WebSocketChannel> connect({
    required final Future<WebSocketChannel> Function() connect,
    required final Duration timeout,
    required final String logContext,
  }) async {
    try {
      final Future<WebSocketChannel> future = connect();
      if (timeout.inMilliseconds > 0) {
        return await future.timeout(timeout);
      }
      return await future;
    } on TimeoutException catch (error, stackTrace) {
      AppLogger.error('$logContext timeout', error, stackTrace);
      rethrow;
    } on Exception catch (error, stackTrace) {
      AppLogger.error('$logContext failed', error, stackTrace);
      rethrow;
    }
  }
}
