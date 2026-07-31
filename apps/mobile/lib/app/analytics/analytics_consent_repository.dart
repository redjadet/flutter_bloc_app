/// Persists analytics collection consent. Missing key means disabled.
abstract class AnalyticsConsentRepository {
  Future<bool> load();

  Future<void> save({required bool enabled});
}
