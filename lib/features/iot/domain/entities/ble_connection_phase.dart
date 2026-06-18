/// Connection lifecycle for a peripheral.
enum BleConnectionPhaseKind {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class BleConnectionPhase {
  const BleConnectionPhase({
    required this.deviceId,
    required this.phase,
    this.errorMessage,
  });

  final String deviceId;
  final BleConnectionPhaseKind phase;
  final String? errorMessage;

  bool get isConnected => phase == BleConnectionPhaseKind.connected;
}
