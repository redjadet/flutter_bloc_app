import 'dart:async';

import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/utils/network_error_mapper.dart';
import 'package:http/http.dart' as http;

/// Extension methods for convenient HTTP client usage with error mapping
extension ResilientHttpClientExtensions on ResilientHttpClient {
  /// Send a GET request and map errors using NetworkErrorMapper
  Future<http.Response> getMapped(
    final Uri url, {
    final Map<String, String>? headers,
    final Duration timeout = const Duration(seconds: 30),
  }) => _sendMappedRequest(
    method: 'GET',
    url: url,
    headers: headers,
    timeout: timeout,
  );

  /// Send a POST request and map errors using NetworkErrorMapper
  Future<http.Response> postMapped(
    final Uri url, {
    final Map<String, String>? headers,
    final Object? body,
    final Duration timeout = const Duration(seconds: 30),
  }) => _sendMappedRequest(
    method: 'POST',
    url: url,
    headers: headers,
    body: body,
    timeout: timeout,
  );

  /// Common method to send HTTP requests with error mapping
  Future<http.Response> _sendMappedRequest({
    required final String method,
    required final Uri url,
    required final Duration timeout,
    final Map<String, String>? headers,
    final Object? body,
  }) async {
    try {
      final http.Request request = http.Request(method, url);
      if (headers != null) {
        request.headers.addAll(headers);
      }
      if (body != null) {
        request.body = body.toString();
      }
      final Future<http.Response> responseFuture = send(request).then(
        http.Response.fromStream,
      );
      final http.Response response = await responseFuture.timeout(timeout);

      if (response.statusCode >= 400) {
        final String? errorMessage = NetworkErrorMapper.getMessageForStatusCode(
          response.statusCode,
        );
        throw http.ClientException(
          errorMessage ?? 'HTTP ${response.statusCode}',
          url,
        );
      }

      return response;
    } on TimeoutException {
      throw http.ClientException('Request timed out', url);
    }
  }
}
