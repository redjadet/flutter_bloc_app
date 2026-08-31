part of 'offline_first_social_feed_repository.dart';

class _ViewerReplay {
  _ViewerReplay({
    required this.viewer,
    required this.repository,
    required this.timerService,
    required this.onZero,
  });

  final SocialFeedViewer viewer;
  final OfflineFirstSocialFeedRepository repository;
  final TimerService timerService;
  final void Function() onZero;

  int _leases = 0;
  TimerDisposable? _timer;
  final StreamController<SocialFeedSyncSummary> _controller =
      StreamController<SocialFeedSyncSummary>.broadcast();

  Future<SocialFeedSyncLease> addLease() async {
    _leases += 1;
    SocialFeedSyncSummary? seed;
    if (_leases == 1) {
      seed = await _tick();
      _timer = timerService.periodic(const Duration(seconds: 1), () {
        unawaited(_tick());
      });
    }
    return _SyncLease(
      summaries: _controller.stream,
      seedSummary: seed,
      closeFn: _release,
    );
  }

  Future<void> _release() async {
    if (_leases <= 0) {
      return;
    }
    _leases -= 1;
    if (_leases == 0) {
      _timer?.dispose();
      _timer = null;
      // Drop from the registry before awaiting close so a new acquire cannot
      // resurrect a replay whose stream controller is shutting down.
      onZero();
      await _controller.close();
    }
  }

  Future<void> forceClose() async {
    _leases = 0;
    _timer?.dispose();
    await _controller.close();
  }

  Future<SocialFeedSyncSummary?> _tick() async {
    if (_leases == 0 || _controller.isClosed) {
      return null;
    }
    final SocialFeedSyncSummary summary = await repository._dispatchQueue(
      viewer,
    );
    if (!_controller.isClosed) {
      _controller.add(summary);
    }
    return summary;
  }
}

class _SyncLease implements SocialFeedSyncLease {
  _SyncLease({
    required this.summaries,
    required this.seedSummary,
    required this._closeFn,
  });

  @override
  final Stream<SocialFeedSyncSummary> summaries;

  @override
  final SocialFeedSyncSummary? seedSummary;

  final Future<void> Function() _closeFn;
  bool _closed = false;

  @override
  Future<void> close() async {
    if (_closed) {
      return;
    }
    _closed = true;
    await _closeFn();
  }
}
