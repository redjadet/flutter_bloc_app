import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Represents simplified connectivity states for offline-first coordination.
enum NetworkStatus { unknown, online, offline }

abstract class NetworkStatusService {
  Stream<NetworkStatus> get statusStream;
  Future<NetworkStatus> getCurrentStatus();
  Future<void> dispose();
}

class ConnectivityNetworkStatusService implements NetworkStatusService {
  ConnectivityNetworkStatusService({
    final Connectivity? connectivity,
    final Duration debounce = const Duration(milliseconds: 250),
    final TimerService? timerService,
  }) : _connectivity = connectivity ?? Connectivity(),
       _debounce = debounce,
       _timerService = timerService ?? DefaultTimerService() {
    _controller = StreamController<NetworkStatus>.broadcast(
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }

  final Connectivity _connectivity;
  final Duration _debounce;
  final TimerService _timerService;
  late final StreamController<NetworkStatus> _controller;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  TimerDisposable? _debounceTimer;
  NetworkStatus _latest = NetworkStatus.unknown;
  bool _disposed = false;

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream.distinct();

  @override
  Future<NetworkStatus> getCurrentStatus() async {
    final dynamic raw = await _connectivity.checkConnectivity();
    final ConnectivityResult result = raw is List<ConnectivityResult>
        ? (raw.isNotEmpty ? raw.first : ConnectivityResult.none)
        : raw as ConnectivityResult;
    final NetworkStatus next = _mapConnectivity(result);
    _latest = next;
    return next;
  }

  void _onListen() {
    if (_connectivitySubscription != null) {
      return;
    }
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (final results) {
        final ConnectivityResult result = results.isNotEmpty
            ? results.first
            : ConnectivityResult.none;
        _handleConnectivityResult(result);
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'ConnectivityNetworkStatusService.listen failed',
          error,
          stackTrace,
        );
      },
    );
    unawaited(
      getCurrentStatus().then((final status) {
        if (_controller.hasListener && !_controller.isClosed) {
          _controller.add(status);
        }
      }),
    );
  }

  void _onCancel() {
    if (_controller.hasListener) {
      return;
    }
    _debounceTimer?.dispose();
    _debounceTimer = null;
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }

  void _handleConnectivityResult(final ConnectivityResult result) {
    final NetworkStatus next = _mapConnectivity(result);
    if (next == _latest) {
      return;
    }
    _latest = next;
    _debounceTimer?.dispose();
    _debounceTimer = _timerService.runOnce(_debounce, () {
      if (_controller.isClosed) {
        return;
      }
      _controller.add(next);
    });
  }

  NetworkStatus _mapConnectivity(final ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
      case ConnectivityResult.vpn:
        return NetworkStatus.online;
      case ConnectivityResult.none:
        return NetworkStatus.offline;
      case ConnectivityResult.other:
        return NetworkStatus.unknown;
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _debounceTimer?.dispose();
    _debounceTimer = null;
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    await _controller.close();
  }
}
