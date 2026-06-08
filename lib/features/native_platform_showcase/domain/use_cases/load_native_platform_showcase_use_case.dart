import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_platform_info_repository.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';

/// Loads the educational showcase catalog plus live native interop results.
class LoadNativePlatformShowcaseUseCase {
  LoadNativePlatformShowcaseUseCase(this._repository);

  final NativePlatformInfoRepository _repository;

  Future<PlatformShowcaseData> call() => _repository.loadShowcase();
}
