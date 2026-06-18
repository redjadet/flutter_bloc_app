/// Diagnostic log entry shown in the BLE event log panel.
enum BleLogKind {
  info,
  scan,
  connect,
  disconnect,
  read,
  write,
  notify,
  error,
}

class BleLogEntry {
  const BleLogEntry({
    required this.timestamp,
    required this.kind,
    required this.message,
  });

  final DateTime timestamp;
  final BleLogKind kind;
  final String message;
}
