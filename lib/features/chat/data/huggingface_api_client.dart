import 'dart:convert';

import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

typedef JsonMap = Map<String, dynamic>;

/// Thin wrapper around [http.Client] that centralizes Hugging Face specific
/// headers, error handling and JSON parsing.
class HuggingFaceApiClient {
  HuggingFaceApiClient({http.Client? httpClient, String? apiKey})
    : _client = httpClient ?? http.Client(),
      _apiKey = apiKey;

  final http.Client _client;
  final String? _apiKey;

  bool get hasApiKey => _apiKey != null;

  Map<String, String> _headers() {
    return <String, String>{
      'Content-Type': 'application/json',
      if (_apiKey != null) 'Authorization': 'Bearer $_apiKey',
    };
  }

  Future<JsonMap> postJson({
    required Uri uri,
    required JsonMap payload,
    required String context,
  }) async {
    try {
      final http.Response response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      );

      final int statusCode = response.statusCode;
      if (statusCode == 429) {
        throw const ChatException('Hugging Face rate limit hit. Please wait before trying again.');
      }

      if (statusCode >= 400) {
        final String friendly = formatError(response);
        AppLogger.error(
          'HuggingfaceChatRepository.$context non-success',
          'HTTP $statusCode => ${response.body}',
          StackTrace.current,
        );
        throw ChatException(friendly);
      }

      return jsonDecode(response.body) as JsonMap;
    } catch (error, stackTrace) {
      if (error is ChatException) rethrow;
      AppLogger.error('HuggingfaceChatRepository.$context failed', error, stackTrace);
      throw const ChatException('Failed to contact chat service.');
    }
  }

  static String formatError(http.Response response) {
    final int code = response.statusCode;
    final String body = response.body;
    String? detail;

    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        detail = (decoded['error'] ?? decoded['message']) as String?;
      }
    } catch (_) {
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
