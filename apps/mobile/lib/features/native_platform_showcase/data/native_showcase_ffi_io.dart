import 'package:flutter_bloc_app/features/native_platform_showcase/data/native_showcase_ffi_bindings.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';

NativeInteropCallResult invokeNativeShowcaseCpp({
  required final int left,
  required final int right,
}) {
  try {
    final NativeShowcaseFfiBindings bindings = NativeShowcaseFfiBindings.open();
    final String greeting = bindings.greeting();
    final int sum = bindings.add(left: left, right: right);
    return NativeInteropCallResult(
      kind: NativeInteropBridgeKind.cpp,
      status: NativeInteropStatus.success,
      message: '$greeting ($left + $right = $sum)',
    );
  } on Object catch (error) {
    return NativeInteropCallResult(
      kind: NativeInteropBridgeKind.cpp,
      status: NativeInteropStatus.failed,
      message: error.toString(),
    );
  }
}
