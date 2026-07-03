import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_capability.freezed.dart';

@freezed
abstract class NativeCapability with _$NativeCapability {
  const factory NativeCapability({
    required NativeCapabilityKind kind,
    required String platformDetail,
  }) = _NativeCapability;
}
