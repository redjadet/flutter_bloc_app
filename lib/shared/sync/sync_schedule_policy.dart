import 'package:flutter_bloc_app/shared/services/network_status_service.dart';

/// Encapsulates "when should a sync cycle run?" for background sync coordination.
class SyncSchedulePolicy {
  const SyncSchedulePolicy();

  /// Returns true if a sync cycle should be started given current state.
  ///
  /// [networkStatus] must be [NetworkStatus.online] for sync to run.
  /// [immediate] true when triggered by user/event; [isRunning] when coordinator is started.
  bool shouldRunCycle(
    final NetworkStatus networkStatus, {
    required final bool immediate,
    required final bool isRunning,
  }) {
    if (networkStatus != NetworkStatus.online) {
      return false;
    }
    return immediate || isRunning;
  }
}
