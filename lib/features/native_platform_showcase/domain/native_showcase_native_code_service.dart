import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';

/// Native code interop port (C/C++ and future JNI bindings).
///
/// Prefer FFI (or generated bindings) over MethodChannel for performance-critical
/// native code; repository depends only on this contract.
abstract class NativeShowcaseNativeCodeService {
  NativeInteropCallResult invokeCpp({int left = 21, int right = 21});
}
