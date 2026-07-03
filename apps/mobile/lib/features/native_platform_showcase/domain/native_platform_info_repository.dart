import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';

abstract interface class NativePlatformInfoRepository {
  Future<PlatformShowcaseData> loadShowcase();
}
