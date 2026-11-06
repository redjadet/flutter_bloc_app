import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_connection_status.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_realtime_client.dart';

/// In-process WS contract stub: toggles connecting → connected without sockets.
class StubCarrierRealtimeClient implements CarrierRealtimeClient {
  new({
    Uri? endpoint,
    this.connectDelay = const Duration(milliseconds: 120),
    TimerService? timerService,
  }) : endpoint = endpoint ?? Uri.parse('wss://line.example.invalid/v1'),
       _timerService = timerService ?? DefaultTimerService();

  @override
  final Uri endpoint;

  final Duration connectDelay;
  final TimerService _timerService;

  final StreamController<CarrierConnectionStatus> _controller =
      StreamController<CarrierConnectionStatus>.broadcast();

  CarrierConnectionStatus _status = CarrierConnectionStatus.disconnected;
  String? _lastError;
  TimerDisposable? _connectTimer;
  Completer<void>? _pendingConnect;

  @override
  Stream<CarrierConnectionStatus> get connectionStates => _controller.stream;

  @override
  CarrierConnectionStatus get currentStatus => _status;

  @override
  String? get lastError => _lastError;

  @override
  Future<void> connect() async {
    if (_status == CarrierConnectionStatus.connected ||
        _status == CarrierConnectionStatus.connecting) {
      return;
    }
    _lastError = null;
    _emit(CarrierConnectionStatus.connecting);
    _connectTimer?.dispose();
    final Completer<void> done = Completer<void>();
    _pendingConnect = done;
    _connectTimer = _timerService.runOnce(connectDelay, () {
      if (_pendingConnect != done) {
        return;
      }
      _emit(CarrierConnectionStatus.connected);
      _completePending();
    });
    await done.future;
  }

  @override
  Future<void> disconnect() async {
    _cancelPendingConnect();
    _lastError = null;
    _emit(CarrierConnectionStatus.disconnected);
  }

  /// Forces an error state for widget/cubit tests.
  void fail(String message) {
    _cancelPendingConnect();
    _lastError = message;
    _emit(CarrierConnectionStatus.error);
  }

  void _emit(CarrierConnectionStatus status) {
    _status = status;
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  void _cancelPendingConnect() {
    _connectTimer?.dispose();
    _connectTimer = null;
    _completePending();
  }

  void _completePending() {
    final Completer<void>? pending = _pendingConnect;
    _pendingConnect = null;
    if (pending != null && !pending.isCompleted) {
      pending.complete();
    }
  }

  @override
  Future<void> dispose() async {
    _cancelPendingConnect();
    await _controller.close();
  }
}
