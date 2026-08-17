import 'package:feature_flags/feature_flags.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';

/// Fake remote config client for tests and web smoke overrides.
class FakeRemoteConfigRemoteDataSource implements RemoteConfigRemoteDataSource {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  String getString(String key) {
    if (key == RemoteConfigKeys.productionDemoVariant) {
      return 'control';
    }
    return '';
  }

  @override
  bool getBool(String key) {
    if (key == RemoteConfigKeys.productionDemoEnabled) {
      return true;
    }
    return false;
  }

  @override
  int getInt(String key) => 0;

  @override
  double getDouble(String key) => 0;

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> dispose() async {}
}
