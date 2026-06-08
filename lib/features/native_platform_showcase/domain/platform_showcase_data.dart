import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_showcase_data.freezed.dart';

@freezed
abstract class PlatformShowcaseData with _$PlatformShowcaseData {
  const factory PlatformShowcaseData({
    required AppPlatformKind platform,
    required List<NativeCapability> capabilities,
    required List<NativeInteropCallResult> interopResults,
  }) = _PlatformShowcaseData;
}
