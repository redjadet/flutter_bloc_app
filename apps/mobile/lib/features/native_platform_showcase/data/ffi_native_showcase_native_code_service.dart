import 'package:flutter_bloc_app/features/native_platform_showcase/data/native_showcase_ffi_stub.dart'
    if (dart.library.ffi) 'package:flutter_bloc_app/features/native_platform_showcase/data/native_showcase_ffi_io.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_native_code_service.dart';

/// FFI implementation of [NativeShowcaseNativeCodeService].
///
/// Preferred long-term path for C/C++ (and future JNI-generated bindings).
class FfiNativeShowcaseNativeCodeService
    implements NativeShowcaseNativeCodeService {
  const FfiNativeShowcaseNativeCodeService();

  @override
  NativeInteropCallResult invokeCpp({
    final int left = 21,
    final int right = 21,
  }) => invokeNativeShowcaseCpp(left: left, right: right);
}
