import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:http/http.dart' as http;

/// Example REST-backed implementation of [CounterRepository].
///
/// This is a scaffold with TODOs. Wire endpoints, auth and models as needed.
class RestCounterRepository implements CounterRepository {
  RestCounterRepository({
    required final String baseUrl,
    final http.Client? client,
    final Map<String, String>? defaultHeaders,
    final Duration requestTimeout = const Duration(seconds: 10),
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
  bool _hasResolvedInitialValue = false;

  Uri get _counterUri => _baseUri.resolve('counter');

  Map<String, String> _headers({final Map<String, String>? overrides}) => {
    ..._defaultHeaders,
    if (overrides != null) ...overrides,
  };

  Future<http.Response> _sendRequest({
    required final String operation,
    required final Future<http.Response> Function() request,
    required final CounterError Function({
      Object? originalError,
      String? message,
    })
    errorFactory,
    CounterError Function(http.Response response)? onHttpFailure,
  }) async {
    try {
      final http.Response response = await request().timeout(_requestTimeout);
      if (_isSuccess(response.statusCode)) {
        return response;
      }
      _logHttpError(operation, response);
      throw onHttpFailure?.call(response) ??
          errorFactory(
            originalError: http.ClientException(
              'REST $operation failed (HTTP ${response.statusCode})',
              response.request?.url ?? _counterUri,
            ),
            message: 'REST $operation failed (HTTP ${response.statusCode}).',
          );
    } on CounterError {
      rethrow;
    } on Exception catch (error, stackTrace) {
      AppLogger.error(
        'RestCounterRepository.$operation failed',
        error,
        stackTrace,
      );
      throw errorFactory(originalError: error);
    }
  }

  bool _isSuccess(final int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  CounterSnapshot _storeSnapshot(final CounterSnapshot snapshot) {
    final CounterSnapshot normalized = _normalizeSnapshot(snapshot);
    _latestSnapshot = normalized;
    _hasResolvedInitialValue = true;
    return normalized;
  }

  CounterSnapshot _parseSnapshot(final String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw CounterError.load(
          message: 'REST payload was not a JSON object.',
          originalError: decoded,
        );
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
    } on CounterError {
      rethrow;
    } on FormatException catch (error) {
      throw CounterError.load(
        message: 'Malformed REST counter payload.',
        originalError: error,
      );
    }
  }

  void _logHttpError(final String operation, final http.Response response) {
    AppLogger.error(
      'RestCounterRepository.$operation non-success: ${response.statusCode}',
      'Response body omitted for privacy',
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
    final http.Response response = await _sendRequest(
      operation: 'load',
      request: () => _client.get(_counterUri, headers: _headers()),
      errorFactory: CounterError.load,
      onHttpFailure: (final http.Response res) => CounterError.load(
        message: 'REST load failed (HTTP ${res.statusCode}).',
      ),
    );
    final CounterSnapshot snapshot = _parseSnapshot(response.body);
    return _storeSnapshot(snapshot);
  }

  @override
  Future<void> save(final CounterSnapshot snapshot) async {
    final CounterSnapshot normalized = _normalizeSnapshot(snapshot);
    await _sendRequest(
      operation: 'save',
      request: () => _client.post(
        _counterUri,
        headers: _headers(
          overrides: const {'Content-Type': 'application/json'},
        ),
        body: jsonEncode(<String, dynamic>{
          'userId': normalized.userId,
          'count': normalized.count,
          'last_changed': normalized.lastChanged?.millisecondsSinceEpoch,
        }),
      ),
      errorFactory: CounterError.save,
      onHttpFailure: (final http.Response res) => CounterError.save(
        originalError: http.ClientException(
          'Counter save failed (HTTP ${res.statusCode})',
          _counterUri,
        ),
        message: 'Save failed with status ${res.statusCode}',
      ),
    );
    _emitSnapshot(normalized);
  }

  @override
  Stream<CounterSnapshot> watch() {
    _watchController ??= StreamController<CounterSnapshot>.broadcast(
      onListen: _triggerInitialLoadIfNeeded,
      onCancel: _handleWatchCancel,
    );

    final Stream<CounterSnapshot> sourceStream = _watchController!.stream;
    return Stream<CounterSnapshot>.multi((final multi) {
      if (_hasResolvedInitialValue) {
        multi.add(_latestSnapshot);
      }
      final StreamSubscription<CounterSnapshot> subscription = sourceStream
          .listen(multi.add, onError: multi.addError);
      multi.onCancel = subscription.cancel;
    });
  }

  CounterSnapshot _normalizeSnapshot(final CounterSnapshot snapshot) {
    final String? userId = snapshot.userId;
    if (userId == null || userId.isEmpty) {
      return snapshot.copyWith(userId: _emptySnapshot.userId);
    }
    return snapshot;
  }

  void _emitSnapshot(final CounterSnapshot snapshot) {
    final CounterSnapshot normalized = _storeSnapshot(snapshot);
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
    _startInitialLoad(completer);
  }

  void _startInitialLoad(final Completer<void> completer) {
    Future<void> run() async {
      try {
        final CounterSnapshot snapshot = await load();
        _emitSnapshot(snapshot);
      } on CounterError catch (error, stackTrace) {
        AppLogger.error(
          'RestCounterRepository.initialLoad failed',
          error,
          stackTrace,
        );
        _watchController?.addError(error, stackTrace);
      } finally {
        completer.complete();
        _initialLoadCompleter = null;
      }
    }

    unawaited(run());
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
