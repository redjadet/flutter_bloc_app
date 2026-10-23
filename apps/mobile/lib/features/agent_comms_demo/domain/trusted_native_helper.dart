/// Extension point for **trusted** in-process native helpers.
///
/// Use `flutter_rust_bridge` (async / streams / bidirectional) here when a
/// helper must live in the Flutter process. Never route untrusted agent
/// commands through this port — those belong in the out-of-process engine.
abstract interface class TrustedNativeHelper {
  /// Demo no-op identity check for the trusted path.
  Future<String> identity();
}

/// Placeholder until an FRB-backed helper is wired.
final class NoOpTrustedNativeHelper implements TrustedNativeHelper {
  const new();

  @override
  Future<String> identity() async => 'trusted-helper-extension-point';
}
