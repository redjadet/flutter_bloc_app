import 'dart:async';
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
  StreamController<CounterSnapshot>? _watchController;
  CounterSnapshot _latestSnapshot = _emptySnapshot;
  Completer<void>? _initialLoadCompleter;

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
    _watchController?.close();
    _watchController = null;
  }

  @override
  Future<CounterSnapshot> load() async {
    try {
      final res = await _client
          .get(_counterUri, headers: _headers())
          .timeout(_requestTimeout);
      if (!_isSuccess(res.statusCode)) {
        _logHttpError('load', res);
        _latestSnapshot = _emptySnapshot;
        return _emptySnapshot;
      }
      final CounterSnapshot snapshot = _parseSnapshot(res.body);
      final CounterSnapshot normalized = _normalizeSnapshot(snapshot);
      _latestSnapshot = normalized;
      return normalized;
    } on Exception catch (e, s) {
      AppLogger.error('RestCounterRepository.load failed', e, s);
      _latestSnapshot = _emptySnapshot;
      return _emptySnapshot;
    }
  }

  @override
  Future<void> save(CounterSnapshot snapshot) async {
    final CounterSnapshot normalized = _normalizeSnapshot(snapshot);
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
    } on Exception catch (e, s) {
      AppLogger.error('RestCounterRepository.save failed', e, s);
    } finally {
      _emitSnapshot(normalized);
    }
  }

  @override
  Stream<CounterSnapshot> watch() {
    _watchController ??= StreamController<CounterSnapshot>.broadcast(
      onListen: _triggerInitialLoadIfNeeded,
      onCancel: _handleWatchCancel,
    );

    final Stream<CounterSnapshot> sourceStream = _watchController!.stream;
    return Stream<CounterSnapshot>.multi((multi) {
      multi.add(_latestSnapshot);
      final StreamSubscription<CounterSnapshot> subscription = sourceStream
          .listen(multi.add, onError: multi.addError);
      multi.onCancel = subscription.cancel;
    });
  }

  CounterSnapshot _normalizeSnapshot(CounterSnapshot snapshot) {
    final String? userId = snapshot.userId;
    if (userId == null || userId.isEmpty) {
      return snapshot.copyWith(userId: _emptySnapshot.userId);
    }
    return snapshot;
  }

  void _emitSnapshot(CounterSnapshot snapshot) {
    final CounterSnapshot normalized = _normalizeSnapshot(snapshot);
    _latestSnapshot = normalized;
    final StreamController<CounterSnapshot>? controller = _watchController;
    if (controller != null && !controller.isClosed) {
      controller.add(normalized);
    }
  }

  void _triggerInitialLoadIfNeeded() {
    if (_watchController == null) {
      return;
    }
    if (_initialLoadCompleter != null) {
      return;
    }
    final Completer<void> completer = Completer<void>();
    _initialLoadCompleter = completer;
    unawaited(() async {
      try {
        final CounterSnapshot snapshot = await load();
        _emitSnapshot(snapshot);
      } finally {
        completer.complete();
        _initialLoadCompleter = null;
      }
    }());
  }

  Future<void> _handleWatchCancel() async {
    final StreamController<CounterSnapshot>? controller = _watchController;
    if (controller == null) {
      return;
    }
    if (controller.hasListener) {
      return;
    }
    _watchController = null;
    await controller.close();
  }
}
