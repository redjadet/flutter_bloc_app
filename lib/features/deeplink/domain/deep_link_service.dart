import 'dart:async';

/// Abstraction over platform specific deep/universal link streams.
abstract class DeepLinkService {
  /// Emits URIs for deep link activations while the app is running.
  Stream<Uri> linkStream();

  /// Returns the initial URI used to launch the app, if any.
  Future<Uri?> getInitialLink();
}
