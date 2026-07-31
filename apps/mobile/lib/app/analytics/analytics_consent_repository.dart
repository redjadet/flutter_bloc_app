/// Persists analytics collection consent. Missing key means disabled.
abstract class AnalyticsConsentRepository {
  Future<bool> load();

  /// Persists [enabled]. Returns `true` only when storage write succeeds.
  /// Callers must not enable collection or update UI consent until this is true.
  Future<bool> save({required bool enabled});

  /// Emits after a successful [save] so Settings and demo UIs stay in sync.
  Stream<bool> get changes;
}
