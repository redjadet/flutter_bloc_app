import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_connection_status.dart';

/// WebSocket-shaped realtime contract for the business line (stub-friendly).
///
/// Mirrors the production websocket demo repository pattern without
/// requiring a live echo server in this demo.
abstract interface class CarrierRealtimeClient {
  Uri get endpoint;

  Stream<CarrierConnectionStatus> get connectionStates;

  CarrierConnectionStatus get currentStatus;

  String? get lastError;

  Future<void> connect();

  Future<void> disconnect();

  Future<void> dispose();
}
