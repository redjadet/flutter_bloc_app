import 'package:flutter_bloc_app/features/iot/domain/ble_repository.dart'
    show BleRepository;

/// Adapter radio state reported by [BleRepository.watchAdapterStatus].
enum BleAdapterState {
  unknown,
  unavailable,
  unauthorized,
  poweredOff,
  poweredOn,
}

/// Snapshot of the BLE adapter.
class const BleAdapterStatus({
  required final BleAdapterState state,
  final String? message,
}) {
  bool get isReady => state == .poweredOn;
}
