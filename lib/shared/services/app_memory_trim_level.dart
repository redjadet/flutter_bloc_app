/// App-scoped memory trim severity.
enum AppMemoryTrimLevel {
  /// Light trim used when the app backgrounds.
  background,

  /// Aggressive trim used when the platform reports memory pressure.
  pressure,
}
