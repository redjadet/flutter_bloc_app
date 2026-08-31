part of 'social_feed_cubit.dart';

mixin _SocialFeedCubitLeases
    on _SocialFeedCubitBase, _SocialFeedCubitHelpers, _SocialFeedCubitLoad {
  Future<void> switchViewer(SocialFeedViewer next) async {
    if (next.id == viewer.id) {
      return;
    }
    ++_generation;
    await _closeLeases();
    if (isClosed) {
      return;
    }
    emit(SocialFeedState.loading(next));
    await load();
  }

  Future<void> resetCurrentViewerDemo() async {
    final SocialFeedViewer current = viewer;
    await _repository.resetViewerData(viewer: current);
    _scenario.resetViewerSimulatorFaults(viewer: current);
    await load();
  }

  void onAppLifecycle(AppLifecycleState lifecycle) {
    switch (lifecycle) {
      case AppLifecycleState.resumed:
        unawaited(_onResume());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_closeLeases());
    }
  }

  Future<void> _onResume() async {
    final int generation = _generation;
    final SocialFeedViewer current = viewer;
    final SocialFeedSyncSummary? seedSummary = await _acquireLeases(
      current,
      generation: generation,
    );
    if (!_isCurrentLease(generation, current)) {
      return;
    }
    if (seedSummary != null) {
      _applySyncSummary(seedSummary, current);
    }
    if (_scenario.isSimulatedOnline) {
      await refresh();
    }
  }
}
