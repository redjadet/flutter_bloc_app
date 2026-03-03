import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/persistent_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';

/// Registers IoT demo services (Hive-backed persistent repository).
void registerIotDemoServices() {
  registerLazySingletonIfAbsent<IotDemoRepository>(
    () => PersistentIotDemoRepository(hiveService: getIt<HiveService>()),
  );
}
