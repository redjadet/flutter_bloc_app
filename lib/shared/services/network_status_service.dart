import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:flutter_bloc_app/shared/utils/timer_handle_manager.dart';

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
  final TimerHandleManager _timerHandles = TimerHandleManager();
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
    final NetworkStatus next = _mapConnectivityRaw(raw);
    _latest = next;
    return next;
  }

  void _onListen() {
    if (_connectivitySubscription != null) {
      return;
    }
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (final results) {
        _handleConnectivityResults(results);
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
    _timerHandles.unregister(_debounceTimer);
    _debounceTimer = null;
    unawaited(_connectivitySubscription?.cancel());
    _connectivitySubscription = null;
  }

  void _handleConnectivityResults(final List<ConnectivityResult> results) {
    final NetworkStatus next = _mapConnectivityList(results);
    if (next == _latest) {
      return;
    }
    _latest = next;
    _debounceTimer?.dispose();
    _timerHandles.unregister(_debounceTimer);
    late final TimerDisposable handle;
    handle = _timerService.runOnce(_debounce, () {
      _timerHandles.unregister(handle);
      if (identical(_debounceTimer, handle)) {
        _debounceTimer = null;
      }
      if (_controller.isClosed) {
        return;
      }
      _controller.add(next);
    });
    _debounceTimer = handle;
    _timerHandles.register(handle);
  }

  NetworkStatus _mapConnectivityRaw(final dynamic raw) {
    if (raw is List<ConnectivityResult>) {
      return _mapConnectivityList(raw);
    }
    if (raw is ConnectivityResult) {
      return _mapConnectivity(raw);
    }
    AppLogger.warning(
      'ConnectivityNetworkStatusService.checkConnectivity returned '
      'unexpected type: ${raw.runtimeType}',
    );
    return NetworkStatus.unknown;
  }

  NetworkStatus _mapConnectivityList(final List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return NetworkStatus.offline;
    }
    if (results.any(_isOnlineConnectivity)) {
      return NetworkStatus.online;
    }
    if (results.every((final result) => result == ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }
    return NetworkStatus.unknown;
  }

  bool _isOnlineConnectivity(final ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
      case ConnectivityResult.vpn:
      case ConnectivityResult.satellite:
        return true;
      case ConnectivityResult.none:
      case ConnectivityResult.other:
        return false;
    }
  }

  NetworkStatus _mapConnectivity(final ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.bluetooth:
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
      case ConnectivityResult.vpn:
      case ConnectivityResult.satellite:
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
    _timerHandles.unregister(_debounceTimer);
    _debounceTimer = null;
    await _timerHandles.dispose();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    await _controller.close();
  }
}
