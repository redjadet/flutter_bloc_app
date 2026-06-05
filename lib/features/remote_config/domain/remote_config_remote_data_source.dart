import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';

/// Port for the native/Firebase remote-config client used by offline-first sync.
///
/// App code should depend on [RemoteConfigService], not this type.
abstract class RemoteConfigRemoteDataSource {
  Future<void> initialize();

  Future<void> forceFetch();

  bool getBool(final String key);

  String getString(final String key);

  int getInt(final String key);

  double getDouble(final String key);

  Future<void> clearCache();

  Future<void> dispose();
}
