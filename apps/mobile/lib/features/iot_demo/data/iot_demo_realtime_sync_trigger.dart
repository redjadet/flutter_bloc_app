import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_realtime_subscription.dart';
import 'package:networking/networking.dart';

/// Bridges IoT demo Supabase realtime into the shared sync coordinator.
final class IotDemoRealtimeSyncTrigger implements RealtimeSyncTrigger {
  const new(this._subscription);

  final IotDemoRealtimeSubscription _subscription;

  @override
  void start(void Function() onSyncRequested) =>
      _subscription.start(onSyncRequested);

  @override
  Future<void> stop() => _subscription.stop();
}
