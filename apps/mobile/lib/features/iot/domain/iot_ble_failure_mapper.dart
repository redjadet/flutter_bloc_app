import 'package:flutter_bloc_app/core/domain/failure.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';

/// Maps [Failure] to [IotBleErrorCode] for cubit/UI.
IotBleErrorCode mapFailureToIotBleErrorCode(final Failure failure) {
  return switch (failure) {
    PermissionFailure() => IotBleErrorCode.permissionDenied,
    PlatformFailure() => IotBleErrorCode.unsupportedPlatform,
    TimeoutFailure() => IotBleErrorCode.connect,
    ValidationFailure(:final code) => switch (code) {
      'characteristic_not_found' => IotBleErrorCode.characteristicNotFound,
      'bluetooth_disabled' => IotBleErrorCode.bluetoothDisabled,
      'unsupported_platform' => IotBleErrorCode.unsupportedPlatform,
      _ => IotBleErrorCode.initialize,
    },
    StorageFailure() => IotBleErrorCode.write,
    UnknownFailure(:final message) when message == 'connect_failed' =>
      IotBleErrorCode.connect,
    UnknownFailure(:final message) when message == 'scan_failed' =>
      IotBleErrorCode.scan,
    UnknownFailure(:final message) when message == 'discover_failed' =>
      IotBleErrorCode.discover,
    UnknownFailure(:final message) when message == 'read_failed' =>
      IotBleErrorCode.read,
    UnknownFailure(:final message) when message == 'write_failed' =>
      IotBleErrorCode.write,
    UnknownFailure(:final message) when message == 'subscribe_failed' =>
      IotBleErrorCode.subscribe,
    UnknownFailure() => IotBleErrorCode.initialize,
  };
}
