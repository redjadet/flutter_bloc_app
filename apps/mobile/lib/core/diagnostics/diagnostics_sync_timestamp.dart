/// Whether a persisted sync timestamp is safe to show in diagnostics UI.
///
/// Rejects corrupt or absurd values from local storage (e.g. bad ISO strings).
bool isPlausibleDiagnosticsSyncTime(final DateTime utcOrLocal) {
  final DateTime local = utcOrLocal.toLocal();
  final int y = local.year;
  return y >= 1970 && y <= 2100;
}
