/// Domain-level contract for interacting with remote configuration.
abstract class RemoteConfigService {
  /// Initializes the remote config client and fetches values.
  Future<void> initialize();

  /// Forces a fetch from the remote config server, bypassing cache.
  Future<void> forceFetch();

  /// Clears in-memory and disk cache for remote config values.
  Future<void> clearCache();

  /// Returns the boolean value for [key], or false if unset.
  bool getBool(final String key);

  /// Returns the string value for [key], or empty string if unset.
  String getString(final String key);

  /// Returns the int value for [key], or 0 if unset.
  int getInt(final String key);

  /// Returns the double value for [key], or 0.0 if unset.
  double getDouble(final String key);
}
