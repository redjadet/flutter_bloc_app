/// Domain-level contract for interacting with remote configuration.
abstract class RemoteConfigService {
  Future<void> initialize();
  Future<void> forceFetch();
  Future<void> clearCache();

  bool getBool(String key);
  String getString(String key);
  int getInt(String key);
  double getDouble(String key);
}
