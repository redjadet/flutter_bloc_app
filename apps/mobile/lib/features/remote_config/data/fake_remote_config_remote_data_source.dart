import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_remote_data_source.dart';

/// Fake remote config client for tests and web smoke overrides.
class FakeRemoteConfigRemoteDataSource implements RemoteConfigRemoteDataSource {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> forceFetch() async {}

  @override
  String getString(final String key) => '';

  @override
  bool getBool(final String key) => false;

  @override
  int getInt(final String key) => 0;

  @override
  double getDouble(final String key) => 0;

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> dispose() async {}
}
