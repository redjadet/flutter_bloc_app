/// Domain-level contract for interacting with remote configuration.
abstract class RemoteConfigService {
  Future<void> initialize();
  Future<void> forceFetch();

  bool getBool(String key);
  String getString(String key);
  int getInt(String key);
  double getDouble(String key);
}
