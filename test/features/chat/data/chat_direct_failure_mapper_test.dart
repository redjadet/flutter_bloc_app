import 'package:flutter_bloc_app/features/chat/data/chat_direct_failure_mapper.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapDirectChatException', () {
    test('HTTP 401 substring maps to auth_required', () {
      final ChatRemoteFailureException e = mapDirectChatException(
        const ChatException('upstream said HTTP 401 Unauthorized'),
      );
      expect(e.code, 'auth_required');
      expect(e.retryable, isFalse);
      expect(e.isEdge, isFalse);
    });

    test('HTTP 403 substring maps to forbidden', () {
      final ChatRemoteFailureException e = mapDirectChatException(
        const ChatException('upstream said HTTP 403 Forbidden'),
      );
      expect(e.code, 'forbidden');
      expect(e.retryable, isFalse);
      expect(e.isEdge, isFalse);
    });

    test('authentication failed maps to auth_required', () {
      final ChatRemoteFailureException e = mapDirectChatException(
        const ChatException('Authentication failed for token'),
      );
      expect(e.code, 'auth_required');
      expect(e.retryable, isFalse);
    });

    test('regex HTTP 401 maps to auth_required', () {
      final ChatRemoteFailureException e = mapDirectChatException(
        const ChatException('Request failed with HTTP 401'),
      );
      expect(e.code, 'auth_required');
    });

    test('regex HTTP 403 maps to forbidden', () {
      final ChatRemoteFailureException e = mapDirectChatException(
        const ChatException('Request failed with HTTP 403'),
      );
      expect(e.code, 'forbidden');
    });

    test('timeout message maps to upstream_timeout', () {
      final ChatRemoteFailureException e = mapDirectChatException(
        const ChatException('Chat service timed out.'),
      );
      expect(e.code, 'upstream_timeout');
      expect(e.retryable, isTrue);
      expect(e.isEdge, isFalse);
    });

    test('HTTP 404 maps to invalid_request', () {
      final ChatRemoteFailureException e = mapDirectChatException(
        const ChatException('Chat service error (HTTP 404): model missing'),
      );
      expect(e.code, 'invalid_request');
      expect(e.retryable, isFalse);
      expect(e.isEdge, isFalse);
    });
  });
}
