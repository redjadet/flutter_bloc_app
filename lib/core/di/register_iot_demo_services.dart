import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/mock_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';

/// Registers IoT demo services (mock repository).
void registerIotDemoServices() {
  registerLazySingletonIfAbsent<IotDemoRepository>(
    MockIotDemoRepository.new,
  );
}
