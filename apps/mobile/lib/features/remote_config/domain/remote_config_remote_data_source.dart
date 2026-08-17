import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';

/// Port for the native/Firebase remote-config client used by offline-first sync.
///
/// App code should depend on [RemoteConfigService], not this type.
abstract class RemoteConfigRemoteDataSource {
  Future<void> initialize();

  Future<void> forceFetch();

  bool getBool(String key);

  String getString(String key);

  int getInt(String key);

  double getDouble(String key);

  Future<void> clearCache();

  Future<void> dispose();
}
