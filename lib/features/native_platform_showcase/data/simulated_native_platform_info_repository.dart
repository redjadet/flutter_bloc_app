import 'package:flutter_bloc_app/features/native_platform_showcase/data/platform_showcase_mapper.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/data/runtime_platform_probe.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_platform_info_repository.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';

class SimulatedNativePlatformInfoRepository
    implements NativePlatformInfoRepository {
  SimulatedNativePlatformInfoRepository({
    final RuntimePlatformProbe? probe,
  }) : _probe = probe ?? const RuntimePlatformProbe();

  final RuntimePlatformProbe _probe;

  @override
  Future<PlatformShowcaseData> loadShowcase() async {
    final AppPlatformKind platform = _probe.resolve();
    return mapShowcase(platform);
  }
}
