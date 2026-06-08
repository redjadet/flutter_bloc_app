import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'native_interop_call_result.freezed.dart';

@freezed
abstract class NativeInteropCallResult with _$NativeInteropCallResult {
  const factory NativeInteropCallResult({
    required NativeInteropBridgeKind kind,
    required NativeInteropStatus status,
    required String message,
  }) = _NativeInteropCallResult;
}
