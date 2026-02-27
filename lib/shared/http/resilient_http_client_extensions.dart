import 'dart:async';

import 'package:flutter_bloc_app/shared/http/resilient_http_client.dart';
import 'package:flutter_bloc_app/shared/utils/http_request_failure.dart';
import 'package:flutter_bloc_app/shared/utils/network_error_mapper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Extension methods for convenient HTTP client usage with error mapping
extension ResilientHttpClientExtensions on ResilientHttpClient {
  static final List<DateFormat> _retryAfterDateFormats = <DateFormat>[
    DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US'),
    DateFormat("EEEE, dd-MMM-yy HH:mm:ss 'GMT'", 'en_US'),
    DateFormat('EEE MMM d HH:mm:ss yyyy', 'en_US'),
  ];

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
        final int? retryAfterSeconds = _parseRetryAfterSeconds(
          response.headers['retry-after'],
        );
        throw HttpRequestFailure(
          response.statusCode,
          errorMessage ?? 'HTTP ${response.statusCode}',
          retryAfterSeconds: retryAfterSeconds,
        );
      }

      return response;
    } on TimeoutException {
      throw http.ClientException('Request timed out', url);
    }
  }

  int? _parseRetryAfterSeconds(final String? headerValue) {
    if (headerValue case final String value when value.trim().isNotEmpty) {
      final String trimmed = value.trim();
      final int? seconds = int.tryParse(trimmed);
      if (seconds != null) {
        return seconds < 0 ? 0 : seconds;
      }

      final DateTime? retryAt = DateTime.tryParse(trimmed);
      final DateTime? retryAfterDateTime =
          retryAt ?? _tryParseHttpDate(trimmed);
      if (retryAfterDateTime == null) {
        return null;
      }

      final Duration difference = retryAfterDateTime.toUtc().difference(
        DateTime.now().toUtc(),
      );
      if (difference <= Duration.zero) {
        return 0;
      }

      return (difference.inMilliseconds / Duration.millisecondsPerSecond)
          .ceil();
    }

    return null;
  }

  DateTime? _tryParseHttpDate(final String value) {
    for (final DateFormat format in _retryAfterDateFormats) {
      try {
        return format.parseUtc(value);
      } on FormatException {
        // Try next supported format.
      }
    }
    return null;
  }
}
