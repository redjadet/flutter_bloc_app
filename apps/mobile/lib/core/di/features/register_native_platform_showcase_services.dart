import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/event_channel_native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/ffi_native_showcase_native_code_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/method_channel_native_showcase_host_language_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/native_platform_info_repository_impl.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/runtime_platform_probe.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_platform_info_repository.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_host_language_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_native_code_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/watch_native_showcase_telemetry_use_case.dart';

void registerNativePlatformShowcaseServices() {
  registerLazySingletonIfAbsent<NativeShowcaseHostLanguageService>(
    MethodChannelNativeShowcaseHostLanguageService.new,
  );
  registerLazySingletonIfAbsent<NativeShowcaseNativeCodeService>(
    FfiNativeShowcaseNativeCodeService.new,
  );
  registerLazySingletonIfAbsent<NativePlatformInfoRepository>(
    () => NativePlatformInfoRepositoryImpl(
      hostLanguageService: getIt<NativeShowcaseHostLanguageService>(),
      nativeCodeService: getIt<NativeShowcaseNativeCodeService>(),
      probe: const RuntimePlatformProbe(),
    ),
  );
  registerLazySingletonIfAbsent<LoadNativePlatformShowcaseUseCase>(
    () => LoadNativePlatformShowcaseUseCase(
      getIt<NativePlatformInfoRepository>(),
    ),
  );
  registerLazySingletonIfAbsent<NativeShowcaseTelemetryService>(
    EventChannelNativeShowcaseTelemetryService.new,
  );
  registerLazySingletonIfAbsent<WatchNativeShowcaseTelemetryUseCase>(
    () => WatchNativeShowcaseTelemetryUseCase(
      getIt<NativeShowcaseTelemetryService>(),
    ),
  );
}
