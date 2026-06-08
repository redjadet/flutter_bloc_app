import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';

/// Host-language interop port (Swift / Kotlin).
///
/// Data layer may implement via MethodChannel today and swap to JNI / SwiftGen
/// later without changing repository, use case, or presentation.
abstract class NativeShowcaseHostLanguageService {
  Future<NativeInteropCallResult> invokeSwift();

  Future<NativeInteropCallResult> invokeKotlin();
}
