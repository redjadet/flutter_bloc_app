import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:ilkersevim_safe_parse/ilkersevim_safe_parse.dart';

/// Maps Render/FastAPI + Dio failures to [ChatRemoteFailureException] (`isEdge: false`).
ChatRemoteFailureException mapRenderChatFailure(Object error) =>
    switch (error) {
      final ChatRemoteFailureException alreadyMapped => alreadyMapped,
      final DioException dio => _fromDio(dio),
      _ => ChatRemoteFailureException(
        error.toString(),
        code: 'upstream_unavailable',
        retryable: true,
        isEdge: false,
      ),
    };

ChatRemoteFailureException _fromDio(DioException e) {
  final int? status = e.response?.statusCode;
  final Map<String, dynamic>? data = mapFromDynamic(e.response?.data);

  if (status != null && data != null) {
    final String? code = stringFromDynamic(data['code']);
    final bool retryable = boolFromDynamic(data['retryable'], fallback: false);
    final String message =
        stringFromDynamic(data['message']) ??
        e.message ??
        'Chat request failed.';
    if (code != null && code.isNotEmpty) {
      return ChatRemoteFailureException(
        message,
        code: code,
        retryable: retryable,
        isEdge: false,
      );
    }
  }

  final String? fallbackMessageFromBody = stringFromDynamicTrimmed(
    e.response?.data,
  );

  if (status case final int code) {
    final ChatRemoteFailureException? fromStatus = switch (code) {
      401 => ChatRemoteFailureException(
        fallbackMessageFromBody ?? e.message ?? 'Unauthorized.',
        code: 'auth_required',
        retryable: false,
        isEdge: false,
      ),
      403 => ChatRemoteFailureException(
        fallbackMessageFromBody ?? e.message ?? 'Forbidden.',
        code: 'forbidden',
        retryable: false,
        isEdge: false,
      ),
      413 || 422 => ChatRemoteFailureException(
        fallbackMessageFromBody ?? e.message ?? 'Invalid request.',
        code: 'invalid_request',
        retryable: false,
        isEdge: false,
      ),
      429 => ChatRemoteFailureException(
        fallbackMessageFromBody ?? e.message ?? 'Rate limited.',
        code: 'rate_limited',
        retryable: false,
        isEdge: false,
      ),
      >= 400 && < 500 => ChatRemoteFailureException(
        fallbackMessageFromBody ?? e.message ?? 'Invalid request.',
        code: 'invalid_request',
        retryable: false,
        isEdge: false,
      ),
      >= 500 => ChatRemoteFailureException(
        fallbackMessageFromBody ?? e.message ?? 'Upstream error.',
        code: 'upstream_unavailable',
        retryable: true,
        isEdge: false,
      ),
      _ => null,
    };
    if (fromStatus != null) {
      return fromStatus;
    }
  }

  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => ChatRemoteFailureException(
      e.message ?? 'Timeout.',
      code: 'upstream_timeout',
      retryable: true,
      isEdge: false,
    ),
    DioExceptionType.connectionError ||
    DioExceptionType.unknown => ChatRemoteFailureException(
      e.message ?? 'Connection error.',
      code: 'upstream_unavailable',
      retryable: true,
      isEdge: false,
    ),
    _ => ChatRemoteFailureException(
      e.message ?? 'Chat request failed.',
      code: 'upstream_unavailable',
      retryable: true,
      isEdge: false,
    ),
  };
}
