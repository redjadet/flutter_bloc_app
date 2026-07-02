import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_platform_showcase_state.freezed.dart';

enum NativePlatformShowcaseFailureKind { loadFailed }

@freezed
abstract class NativePlatformShowcaseState with _$NativePlatformShowcaseState {
  const factory NativePlatformShowcaseState.initial() = _Initial;

  const factory NativePlatformShowcaseState.loading() = _Loading;

  const factory NativePlatformShowcaseState.loaded(
    final PlatformShowcaseData data, {
    final NativeShowcaseTelemetrySnapshot? telemetry,
  }) = _Loaded;

  const factory NativePlatformShowcaseState.error({
    required final NativePlatformShowcaseFailureKind failure,
  }) = _Error;
}
