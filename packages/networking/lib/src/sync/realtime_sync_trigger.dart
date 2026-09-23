/// Feature-agnostic realtime hook that can request an immediate sync cycle.
///
/// App composition registers a concrete trigger (e.g. IoT demo Supabase
/// realtime). [BackgroundSyncCoordinator] must not import feature types.
abstract class RealtimeSyncTrigger {
  /// Begin listening; invoke [onSyncRequested] when remote data may have changed.
  void start(void Function() onSyncRequested);

  /// Stop listening. Safe when not started.
  Future<void> stop();
}

/// Adapts arbitrary start/stop callbacks into a [RealtimeSyncTrigger].
final class CallbackRealtimeSyncTrigger implements RealtimeSyncTrigger {
  const new({
    required void Function(void Function() onSyncRequested) start,
    required Future<void> Function() stop,
  }) : _start = start,
       _stop = stop;

  final void Function(void Function() onSyncRequested) _start;
  final Future<void> Function() _stop;

  @override
  void start(void Function() onSyncRequested) => _start(onSyncRequested);

  @override
  Future<void> stop() => _stop();
}
