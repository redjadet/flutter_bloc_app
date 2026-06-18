import 'package:flutter_bloc_app/core/config/iot_ble_runtime_config.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_permission_gateway_impl.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_platform_gateway_impl.dart';
import 'package:flutter_bloc_app/features/iot/data/ble_radio_client.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/mock_classic_bluetooth_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/noop_ble_permission_gateway.dart';
import 'package:flutter_bloc_app/features/iot/data/reactive_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/data/unsupported_ble_repository.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_permission_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/ble_platform_gateway.dart';
import 'package:flutter_bloc_app/features/iot/domain/classic_bluetooth_repository.dart';

void registerIotServices() {
  registerLazySingletonIfAbsent<IotBleRuntimeConfig>(
    IotBleRuntimeConfig.fromEnvironment,
  );
  registerLazySingletonIfAbsent<BlePlatformGateway>(
    () => const BlePlatformGatewayImpl(),
  );
  registerLazySingletonIfAbsent<MockBleRepository>(MockBleRepository.new);
  registerLazySingletonIfAbsent<UnsupportedBleRepository>(
    () => const UnsupportedBleRepository(),
  );
  final BlePlatformGateway gateway = getIt<BlePlatformGateway>();
  if (gateway.supportsRealBle) {
    registerLazySingletonIfAbsent<BlePermissionGateway>(
      () => const BlePermissionGatewayImpl(),
    );
    registerLazySingletonIfAbsent<BleRadioClient>(
      FlutterReactiveBleRadioClient.new,
    );
    registerLazySingletonIfAbsent<ReactiveBleRepository>(
      () => ReactiveBleRepository(
        client: getIt<BleRadioClient>(),
        timerService: getIt<TimerService>(),
        permissionGateway: getIt<BlePermissionGateway>(),
      ),
      dispose: (final repo) => repo.dispose(),
    );
  } else {
    registerLazySingletonIfAbsent<BlePermissionGateway>(
      () => const NoOpBlePermissionGateway(),
    );
  }
  registerLazySingletonIfAbsent<MockClassicBluetoothRepository>(
    MockClassicBluetoothRepository.new,
  );
  registerLazySingletonIfAbsent<ClassicBluetoothRepository>(
    () => getIt<MockClassicBluetoothRepository>(),
  );
}
