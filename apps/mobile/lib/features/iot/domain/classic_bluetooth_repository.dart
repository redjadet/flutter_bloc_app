import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/iot/domain/entities/classic_bt_device.dart';

/// Bluetooth Classic demo port (mock-only in v1).
abstract class ClassicBluetoothRepository {
  Stream<List<ClassicBtDevice>> watchPairedDevices();

  Future<Result<void>> connect(String deviceId);

  Future<void> disconnect();

  Future<Result<void>> send(String deviceId, String message);

  Stream<ClassicBtMessage> watchIncoming(String deviceId);
}
