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

class const BleLogEntry({
  required final DateTime timestamp,
  required final BleLogKind kind,
  required final String message,
});
