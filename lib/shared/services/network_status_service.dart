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
  /// Increments when a new connectivity listen cycle starts (after all prior
  /// `statusStream` listeners cancelled) and when `dispose` runs, so in-flight
  /// initial `checkConnectivity` work can ignore stale completions.
  int _listenSession = 0;
  /// When true, the connectivity stream has applied an update; a late initial
  /// `checkConnectivity` completion must not overwrite latest status or emit a
  /// stale value.
  bool _hasStreamConnectivityUpdate = false;
  bool _disposed = false;

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream.distinct();

  @override
  Future<NetworkStatus> getCurrentStatus() async {
    final NetworkStatus next = await _statusFromPluginCheck();
    _latest = next;
    return next;
  }

  Future<NetworkStatus> _statusFromPluginCheck() async {
    final dynamic raw = await _connectivity.checkConnectivity();
    return _mapConnectivityRaw(raw);
  }

  void _onListen() {
    if (_connectivitySubscription != null) {
      return;
    }
    _listenSession++;
    final int session = _listenSession;
    _hasStreamConnectivityUpdate = false;
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
      _statusFromPluginCheck()
          .then((status) {
            if (session != _listenSession) {
              return;
            }
            if (_hasStreamConnectivityUpdate) {
              return;
            }
            _latest = status;
            if (_controller.hasListener && !_controller.isClosed) {
              _controller.add(status);
            }
          })
          .catchError((final Object error, final StackTrace stackTrace) {
            if (session != _listenSession) {
              return;
            }
            AppLogger.error(
              'ConnectivityNetworkStatusService initial checkConnectivity failed',
              error,
              stackTrace,
            );
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
    _hasStreamConnectivityUpdate = true;
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
    _listenSession++;
    _debounceTimer?.dispose();
    _timerHandles.unregister(_debounceTimer);
    _debounceTimer = null;
    await _timerHandles.dispose();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    await _controller.close();
  }
}
