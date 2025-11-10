import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_snapshot.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/network_guard.dart';
import 'package:http/http.dart' as http;

part 'rest_counter_repository_internal.dart';
part 'rest_counter_repository_watch.dart';

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
       _ownsClient = client == null {
    _watchController = StreamController<CounterSnapshot>.broadcast(
      onListen: () => _triggerInitialLoadIfNeeded(this),
      onCancel: () => _handleWatchCancel(this),
    );
  }

  final Uri _baseUri;
  final http.Client _client;
  final Map<String, String> _defaultHeaders;
  final Duration _requestTimeout;
  final bool _ownsClient;
  static const CounterSnapshot _emptySnapshot = CounterSnapshot(
    userId: 'rest',
    count: 0,
  );
  late final StreamController<CounterSnapshot> _watchController;
  CounterSnapshot _latestSnapshot = _emptySnapshot;
  Completer<void>? _initialLoadCompleter;
  bool _hasResolvedInitialValue = false;

  Uri get _counterUri => _baseUri.resolve('counter');

  @override
  Future<CounterSnapshot> load() => _restCounterRepositoryLoad(this);

  @override
  Future<void> save(final CounterSnapshot snapshot) =>
      _restCounterRepositorySave(this, snapshot);

  @override
  Stream<CounterSnapshot> watch() => _restCounterRepositoryWatch(this);

  Future<void> dispose() async {
    if (_ownsClient) {
      _client.close();
    }
    if (!_watchController.isClosed) {
      await _watchController.close();
    }
  }
}
