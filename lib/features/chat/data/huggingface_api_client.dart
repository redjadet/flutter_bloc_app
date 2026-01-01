import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/isolate_json.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/network_guard.dart';
import 'package:http/http.dart' as http;

typedef JsonMap = Map<String, dynamic>;

/// Thin wrapper around [http.Client] that centralizes Hugging Face specific
/// headers, error handling and JSON parsing.
class HuggingFaceApiClient {
  HuggingFaceApiClient({
    final http.Client? httpClient,
    final String? apiKey,
    final Duration requestTimeout = const Duration(seconds: 30),
  }) : _client = httpClient ?? http.Client(),
       _apiKey = _clean(apiKey),
       _requestTimeout = requestTimeout,
       _ownsClient = httpClient == null;

  final http.Client _client;
  final String? _apiKey;
  final Duration _requestTimeout;
  final bool _ownsClient;

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
    final http.Response response = await NetworkGuard.execute<ChatException>(
      request: () => _client.post(
        uri,
        headers: _headers(),
        // check-ignore: small payload (<8KB) - request body is small
        body: jsonEncode(payload),
      ),
      timeout: _requestTimeout,
      isSuccess: (final int statusCode) => statusCode < 400,
      logContext: 'HuggingFaceApiClient.$context',
      onHttpFailure: (final http.Response res) {
        if (res.statusCode == 429) {
          return const ChatException(
            'Hugging Face rate limit hit. Please wait before trying again.',
          );
        }
        final String message = formatError(res);
        return ChatException(message);
      },
      onException: (final Object error) =>
          const ChatException('Failed to contact chat service.'),
      onFailureLog: (final http.Response res) {
        AppLogger.error(
          'HuggingFaceApiClient.$context non-success (HTTP ${res.statusCode})',
          'Response body omitted for privacy',
          StackTrace.current,
        );
      },
    );

    final String contentType =
        response.headers['content-type']?.toLowerCase() ?? '';
    if (!contentType.contains('application/json')) {
      AppLogger.error(
        'HuggingFaceApiClient.$context failed',
        'Unexpected content-type: $contentType (payload omitted)',
        StackTrace.current,
      );
      throw const ChatException('Chat service returned unsupported content.');
    }

    try {
      return await decodeJsonMap(response.body);
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
    if (_ownsClient) {
      _client.close();
    }
  }

  static String? _clean(final String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String formatError(final http.Response response) {
    final int code = response.statusCode;
    final String body = response.body;
    String? detail;

    try {
      // check-ignore: small payload (error response bodies are typically <1KB)
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        detail = (decoded['error'] ?? decoded['message']) as String?;
      }
    } on FormatException {
      if (body.isNotEmpty && body != 'null') {
        detail = body;
      }
    }

    if (code == 401 || code == 403 || code == 404) {
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
}
