import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';

/// Port to the native security channel (crypto, secure storage, biometric).
abstract class NativeSecurityShowcaseService {
  Future<NativeSecurityOperationResult> run(NativeSecurityOperation operation);
}
