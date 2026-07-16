import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_showcase_service.dart';

class RunNativeSecurityOperationUseCase {
  const RunNativeSecurityOperationUseCase(this._service);

  final NativeSecurityShowcaseService _service;

  Future<NativeSecurityOperationResult> call(
    final NativeSecurityOperation operation,
  ) => _service.run(operation);
}
