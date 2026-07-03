import 'package:flutter_bloc_app/core/domain/failure.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_error_code.dart';
import 'package:flutter_bloc_app/features/iot/domain/iot_ble_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapFailureToIotBleErrorCode', () {
    test('maps permission and platform failures', () {
      expect(
        mapFailureToIotBleErrorCode(
          const PermissionFailure(PermissionFailureReason.denied),
        ),
        IotBleErrorCode.permissionDenied,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const PlatformFailure(PlatformFailureReason.unavailable),
        ),
        IotBleErrorCode.unsupportedPlatform,
      );
    });

    test('maps validation codes', () {
      expect(
        mapFailureToIotBleErrorCode(
          const ValidationFailure('characteristic_not_found'),
        ),
        IotBleErrorCode.characteristicNotFound,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const ValidationFailure('bluetooth_disabled'),
        ),
        IotBleErrorCode.bluetoothDisabled,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const ValidationFailure('unsupported_platform'),
        ),
        IotBleErrorCode.unsupportedPlatform,
      );
      expect(
        mapFailureToIotBleErrorCode(const ValidationFailure('other')),
        IotBleErrorCode.initialize,
      );
    });

    test('maps operation unknown failures', () {
      expect(
        mapFailureToIotBleErrorCode(
          const UnknownFailure(message: 'scan_failed'),
        ),
        IotBleErrorCode.scan,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const UnknownFailure(message: 'discover_failed'),
        ),
        IotBleErrorCode.discover,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const UnknownFailure(message: 'read_failed'),
        ),
        IotBleErrorCode.read,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const UnknownFailure(message: 'write_failed'),
        ),
        IotBleErrorCode.write,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const UnknownFailure(message: 'subscribe_failed'),
        ),
        IotBleErrorCode.subscribe,
      );
      expect(
        mapFailureToIotBleErrorCode(const UnknownFailure(message: 'other')),
        IotBleErrorCode.initialize,
      );
    });

    test('maps timeout and storage failures', () {
      expect(
        mapFailureToIotBleErrorCode(const TimeoutFailure()),
        IotBleErrorCode.connect,
      );
      expect(
        mapFailureToIotBleErrorCode(
          const StorageFailure(kind: StorageFailureKind.write),
        ),
        IotBleErrorCode.write,
      );
    });
  });
}
