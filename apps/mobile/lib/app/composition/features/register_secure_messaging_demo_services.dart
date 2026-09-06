import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/data/ffi_secure_core_repository.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_repository.dart';
import 'package:secure_core_bridge/secure_core_bridge.dart';

void registerSecureMessagingDemoServices() {
  registerLazySingletonIfAbsent<SecureCoreNativeApi>(
    createSecureCoreNativeApi,
  );
  registerLazySingletonIfAbsent<SecureCoreRepository>(
    () => FfiSecureCoreRepository(getIt<SecureCoreNativeApi>()),
  );
}
