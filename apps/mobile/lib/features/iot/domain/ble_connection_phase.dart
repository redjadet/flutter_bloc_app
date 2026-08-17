/// Connection lifecycle for a peripheral.
enum BleConnectionPhaseKind {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class const BleConnectionPhase({
  required final String deviceId,
  required final BleConnectionPhaseKind phase,
  final String? errorMessage,
}) {
  bool get isConnected => phase == .connected;
}
