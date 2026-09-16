import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/sync/sync_context_extensions.dart';

/// Calls [SyncContextExtensions.ensureSyncStartedIfAvailable] once per [State]
/// lifetime.
///
/// Override [onSyncEnsureStarted] for extra first-mount work (e.g. feature
/// cubit refresh) after the shared ensure runs.
mixin EnsureSyncStartedMixin<T extends StatefulWidget> on State<T> {
  bool _didEnsureSyncStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didEnsureSyncStarted) {
      return;
    }
    _didEnsureSyncStarted = true;
    context.ensureSyncStartedIfAvailable();
    onSyncEnsureStarted();
  }

  /// Invoked once after sync ensure has run for this [State].
  void onSyncEnsureStarted() {}
}
