import 'package:flutter_bloc_app/features/features.dart' show BleRepository;
import 'package:flutter_bloc_app/features/iot/domain/ble_repository.dart'
    show BleRepository;
import 'package:flutter_bloc_app/features/iot/iot.dart' show BleRepository;

/// Adapter radio state reported by [BleRepository.watchAdapterStatus].
enum BleAdapterState {
  unknown,
  unavailable,
  unauthorized,
  poweredOff,
  poweredOn,
}

/// Snapshot of the BLE adapter.
class BleAdapterStatus {
  const BleAdapterStatus({
    required this.state,
    this.message,
  });

  final BleAdapterState state;
  final String? message;

  bool get isReady => state == BleAdapterState.poweredOn;
}
