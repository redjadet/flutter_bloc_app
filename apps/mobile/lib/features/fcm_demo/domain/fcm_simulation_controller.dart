/// Emits deterministic FCM payloads for demos when Firebase is unavailable.
abstract interface class FcmSimulationController {
  /// Pushes a simulated notification through foreground/opened streams.
  void emitSimulatedNotification();
}
