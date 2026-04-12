import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/safe_parse_utils.dart';

/// Maps Render/FastAPI + Dio failures to [ChatRemoteFailureException] (`isEdge: false`).
ChatRemoteFailureException mapRenderChatFailure(final Object error) {
  if (error is ChatRemoteFailureException) {
    return error;
  }
  if (error is DioException) {
    return _fromDio(error);
  }
  return ChatRemoteFailureException(
    error.toString(),
    code: 'upstream_unavailable',
    retryable: true,
    isEdge: false,
  );
}

ChatRemoteFailureException _fromDio(final DioException e) {
  final int? status = e.response?.statusCode;
  final Object? data = e.response?.data;

  if (status != null && data is Map<String, dynamic>) {
    final String? code = stringFromDynamic(data['code']);
    final bool retryable = boolFromDynamic(data['retryable'], fallback: false);
    final String message =
        stringFromDynamic(data['message']) ?? e.message ?? 'Chat request failed.';
    if (code != null && code.isNotEmpty) {
      return ChatRemoteFailureException(
        message,
        code: code,
        retryable: retryable,
        isEdge: false,
      );
    }
  }

  if (status == 401) {
    return ChatRemoteFailureException(
      e.message ?? 'Unauthorized.',
      code: 'auth_required',
      retryable: false,
      isEdge: false,
    );
  }
  if (status == 403) {
    return ChatRemoteFailureException(
      e.message ?? 'Forbidden.',
      code: 'forbidden',
      retryable: false,
      isEdge: false,
    );
  }
  if (status == 413 || status == 422) {
    return ChatRemoteFailureException(
      e.message ?? 'Invalid request.',
      code: 'invalid_request',
      retryable: false,
      isEdge: false,
    );
  }
  if (status == 429) {
    return ChatRemoteFailureException(
      e.message ?? 'Rate limited.',
      code: 'rate_limited',
      retryable: false,
      isEdge: false,
    );
  }
  if (status != null && status >= 500) {
    return ChatRemoteFailureException(
      e.message ?? 'Upstream error.',
      code: 'upstream_unavailable',
      retryable: true,
      isEdge: false,
    );
  }

  final DioExceptionType type = e.type;
  if (type == DioExceptionType.connectionTimeout ||
      type == DioExceptionType.sendTimeout ||
      type == DioExceptionType.receiveTimeout) {
    return ChatRemoteFailureException(
      e.message ?? 'Timeout.',
      code: 'upstream_timeout',
      retryable: true,
      isEdge: false,
    );
  }
  if (type == DioExceptionType.connectionError || type == DioExceptionType.unknown) {
    return ChatRemoteFailureException(
      e.message ?? 'Connection error.',
      code: 'upstream_unavailable',
      retryable: true,
      isEdge: false,
    );
  }

  return ChatRemoteFailureException(
    e.message ?? 'Chat request failed.',
    code: 'upstream_unavailable',
    retryable: true,
    isEdge: false,
  );
}
