/// Persists analytics collection consent. Missing key means disabled.
abstract class AnalyticsConsentRepository {
  Future<bool> load();

  Future<void> save({required bool enabled});

  /// Emits after a successful [save] so Settings and demo UIs stay in sync.
  Stream<bool> get changes;
}
