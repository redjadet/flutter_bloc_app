import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_host_language_service.dart';

class TriggerNativeShowcaseHapticUseCase {
  TriggerNativeShowcaseHapticUseCase(this._hostLanguageService);

  final NativeShowcaseHostLanguageService _hostLanguageService;

  Future<NativeInteropCallResult> call() =>
      _hostLanguageService.triggerHaptic();
}
