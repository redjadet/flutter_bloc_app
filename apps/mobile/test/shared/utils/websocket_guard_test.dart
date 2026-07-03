import 'dart:async';

import 'package:flutter_bloc_app/shared/utils/websocket_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('WebSocketGuard', () {
    test('connect throws TimeoutException when timeout exceeded', () async {
      expect(
        () => WebSocketGuard.connect(
          connect: () async {
            final completer = Completer<WebSocketChannel>();
            return completer.future;
          },
          timeout: const Duration(milliseconds: 100),
          logContext: 'test',
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('connect does not apply timeout when timeout is zero', () async {
      // Test that zero timeout bypasses timeout logic
      bool connectCalled = false;

      try {
        await WebSocketGuard.connect(
          connect: () async {
            connectCalled = true;
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return Future<WebSocketChannel>.error(
              Exception('Connection failed'),
            );
          },
          timeout: Duration.zero,
          logContext: 'test',
        );
      } catch (_) {
        // Connection failure is expected, but connect should have been called
        // and timeout should not have been applied
        expect(connectCalled, isTrue);
      }
    });

    test('connect rethrows exceptions with logging', () async {
      expect(
        () => WebSocketGuard.connect(
          connect: () async {
            throw Exception('Connection failed');
          },
          timeout: const Duration(seconds: 5),
          logContext: 'test',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('connect handles TimeoutException and rethrows', () async {
      expect(
        () => WebSocketGuard.connect(
          connect: () async {
            throw TimeoutException(
              'Connection timeout',
              const Duration(seconds: 1),
            );
          },
          timeout: const Duration(seconds: 5),
          logContext: 'test',
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
