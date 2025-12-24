/// Domain-level contract for interacting with remote configuration.
abstract class RemoteConfigService {
  Future<void> initialize();
  Future<void> forceFetch();
  Future<void> clearCache();

  bool getBool(final String key);
  String getString(final String key);
  int getInt(final String key);
  double getDouble(final String key);
}
