import 'dart:async';
import 'dart:convert';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:ilkersevim_json_isolate/ilkersevim_json_isolate.dart';
import 'package:networking/networking.dart';

typedef JsonMap = Map<String, dynamic>;

/// Thin wrapper around [Dio] that centralizes Hugging Face specific
/// headers, error handling and JSON parsing.
class HuggingFaceApiClient {
  HuggingFaceApiClient({
    required this.dio,
    final String? apiKey,
    this._requestTimeout = const Duration(seconds: 30),
  }) : _apiKey = _clean(apiKey);

  final Dio dio;
  final String? _apiKey;
  final Duration _requestTimeout;

  bool get hasApiKey => _apiKey != null;

  Map<String, String> _headers() => <String, String>{
    'Content-Type': 'application/json',
    if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
  };

  Future<JsonMap> postJson({
    required final Uri uri,
    required final JsonMap payload,
    required final String context,
  }) async {
    final Response<List<int>>
    response = await NetworkGuard.executeDio<List<int>, ChatException>(
      request: () => dio.post<List<int>>(
        uri.toString(),
        // check-ignore: small payload (<8KB) - request body is small
        data: jsonEncode(payload),
        options: Options(
          headers: _headers(),
          responseType: ResponseType.bytes,
        ),
      ),
      timeout: _requestTimeout,
      isSuccess: (final statusCode) => statusCode < 400,
      logContext: 'HuggingFaceApiClient.$context',
      onHttpFailure: (final res) {
        if (res.statusCode == 429) {
          return const ChatException(
            'Hugging Face rate limit hit. Please wait before trying again.',
          );
        }
        final String message = formatError(res);
        return ChatException(message);
      },
      onException: (final error) {
        if (_looksLikeTimeout(error)) {
          return const ChatException('Chat service timed out.');
        }
        return const ChatException('Failed to contact chat service.');
      },
      onFailureLog: (final res) {
        AppLogger.error(
          'HuggingFaceApiClient.$context non-success (HTTP ${res.statusCode})',
          'Response body omitted for privacy',
          StackTrace.current,
        );
      },
    );

    final String? contentTypeHeader = response.headers
        .value('content-type')
        ?.toLowerCase();
    final String contentType = contentTypeHeader ?? '';
    if (!contentType.contains('application/json')) {
      AppLogger.error(
        'HuggingFaceApiClient.$context failed',
        'Unexpected content-type: $contentType (payload omitted)',
        StackTrace.current,
      );
      throw const ChatException('Chat service returned unsupported content.');
    }

    final List<int>? bodyBytes = response.data;
    if (bodyBytes == null || bodyBytes.isEmpty) {
      AppLogger.error(
        'HuggingFaceApiClient.$context failed',
        'Empty response body',
        StackTrace.current,
      );
      throw const ChatException('Chat service returned invalid response.');
    }

    try {
      return await decodeJsonMapFromBytes(bodyBytes);
    } on FormatException catch (e, stackTrace) {
      if (e.message == 'Expected a JSON object') {
        AppLogger.error(
          'HuggingFaceApiClient.$context failed',
          'Unexpected payload structure: ${e.message}',
          stackTrace,
        );
        throw const ChatException('Chat service returned unexpected payload.');
      }
      AppLogger.error(
        'HuggingFaceApiClient.$context failed',
        'Invalid JSON response: ${e.message}',
        stackTrace,
      );
      throw const ChatException(
        'Chat service returned invalid response format.',
      );
    }
  }

  void dispose() {
    // Injected Dio lifetime is owned by composition / test harness.
  }

  static String? _clean(final String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Formats an error message from a Dio [Response].
  static String formatError(final Response<dynamic> response) {
    final int code = response.statusCode ?? 0;
    final String body = _responseDataAsString(response.data);
    return _formatErrorFromStatusAndBody(code, body);
  }

  static String _responseDataAsString(final Object? data) {
    if (data == null) {
      return '';
    }
    if (data is String) {
      return data;
    }
    if (data is List<int>) {
      try {
        return utf8.decode(data);
      } on FormatException {
        return '';
      }
    }
    return '';
  }

  static String _formatErrorFromStatusAndBody(
    final int code,
    final String body,
  ) {
    String? detail;

    try {
      // check-ignore: small payload (error response bodies are typically <1KB)
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final dynamic err = decoded['error'] ?? decoded['message'];
        detail = err is String ? err : err?.toString();
      }
    } on FormatException {
      if (body.isNotEmpty && body != 'null') {
        detail = body;
      }
    }

    if (code == 401 || code == 403) {
      if (detail == null) {
        return 'Chat service authentication failed (HTTP $code). '
            'Check your Hugging Face token or model.';
      }
      return 'Chat service authentication failed (HTTP $code): '
          '$detail. Verify your Hugging Face token/model access.';
    }

    if (detail == null || detail.isEmpty) {
      return 'Chat service error (HTTP $code).';
    }
    return 'Chat service error (HTTP $code): $detail';
  }

  static bool _looksLikeTimeout(final Object error) {
    if (error is TimeoutException) {
      return true;
    }
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout;
    }
    return false;
  }
}
