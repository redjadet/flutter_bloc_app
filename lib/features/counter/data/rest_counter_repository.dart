import 'dart:convert';

import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

/// Example REST-backed implementation of [CounterRepository].
///
/// This is a scaffold with TODOs. Wire endpoints, auth and models as needed.
class RestCounterRepository implements CounterRepository {
  RestCounterRepository({
    required String baseUrl,
    http.Client? client,
    Map<String, String>? defaultHeaders,
    Duration requestTimeout = const Duration(seconds: 10),
  }) : _baseUri = Uri.parse(baseUrl),
       _client = client ?? http.Client(),
       _defaultHeaders = {if (defaultHeaders != null) ...defaultHeaders},
       _requestTimeout = requestTimeout,
       _ownsClient = client == null;

  final Uri _baseUri;
  final http.Client _client;
  final Map<String, String> _defaultHeaders;
  final Duration _requestTimeout;
  final bool _ownsClient;
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(
    userId: 'rest',
    count: 0,
  );

  Uri get _counterUri => _baseUri.resolve('counter');

  Map<String, String> _headers({Map<String, String>? overrides}) => {
    ..._defaultHeaders,
    if (overrides != null) ...overrides,
  };

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  CounterSnapshot _parseSnapshot(String body) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      AppLogger.error(
        'RestCounterRepository.load invalid payload',
        decoded,
        StackTrace.current,
      );
      return _emptySnapshot;
    }
    final Map<String, dynamic> json = decoded;
    final int count = (json['count'] as num?)?.toInt() ?? 0;
    final int? changedMs = (json['last_changed'] as num?)?.toInt();
    final DateTime? lastChanged = changedMs != null
        ? DateTime.fromMillisecondsSinceEpoch(changedMs)
        : null;
    final String userId =
        json['userId'] as String? ?? json['id'] as String? ?? 'rest';
    return CounterSnapshot(
      userId: userId,
      count: count,
      lastChanged: lastChanged,
    );
  }

  void _logHttpError(String operation, http.Response response) {
    AppLogger.error(
      'RestCounterRepository.$operation non-success: ${response.statusCode}',
      response.body,
      StackTrace.current,
    );
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  @override
  Future<CounterSnapshot> load() async {
    try {
      final res = await _client
          .get(_counterUri, headers: _headers())
          .timeout(_requestTimeout);
      if (!_isSuccess(res.statusCode)) {
        _logHttpError('load', res);
        return _emptySnapshot;
      }
      return _parseSnapshot(res.body);
    } catch (e, s) {
      AppLogger.error('RestCounterRepository.load failed', e, s);
      return _emptySnapshot;
    }
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    try {
      final res = await _client
          .post(
            _counterUri,
            headers: _headers(
              overrides: const {'Content-Type': 'application/json'},
            ),
            body: jsonEncode(<String, dynamic>{
              'userId': snapshot.userId,
              'count': snapshot.count,
              'last_changed': snapshot.lastChanged?.millisecondsSinceEpoch,
            }),
          )
          .timeout(_requestTimeout);
      if (!_isSuccess(res.statusCode)) {
        _logHttpError('save', res);
      }
    } catch (e, s) {
      AppLogger.error('RestCounterRepository.save failed', e, s);
    }
  }
}
