import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';

NativeInteropCallResult invokeNativeShowcaseCpp({
  required final int left,
  required final int right,
}) {
  return const NativeInteropCallResult(
    kind: NativeInteropBridgeKind.cpp,
    status: NativeInteropStatus.unavailable,
    message: 'dart:ffi is not available on web.',
  );
}
