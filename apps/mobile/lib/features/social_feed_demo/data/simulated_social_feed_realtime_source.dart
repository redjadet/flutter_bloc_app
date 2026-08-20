import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

/// Reference-counted viewer-scoped simulated realtime source.
class SimulatedSocialFeedRealtimeSource implements SocialFeedRealtimeSource {
  SimulatedSocialFeedRealtimeSource({
    required this._scenario,
    required this._remote,
    required this._timerService,
  });

  final SimulatedSocialFeedScenarioController _scenario;
  final SimulatedSocialFeedRemoteDataSource _remote;
  final TimerService _timerService;

  final Map<String, _ViewerSession> _sessions = <String, _ViewerSession>{};

  @override
  Future<SocialFeedRealtimeLease> acquire(SocialFeedViewer viewer) async {
    final _ViewerSession session = _sessions.putIfAbsent(
      viewer.id,
      () => _ViewerSession(
        viewer: viewer,
        scenario: _scenario,
        remote: _remote,
        timerService: _timerService,
        onZeroLeases: () {
          _sessions.remove(viewer.id);
        },
      ),
    );
    return session.addLease();
  }

  Future<void> dispose() async {
    for (final _ViewerSession session in List<_ViewerSession>.from(
      _sessions.values,
    )) {
      await session.forceClose();
    }
    _sessions.clear();
  }

  /// Push scenario-emitted posts into an active viewer session buffer path.
  @override
  void flushPendingPosts(SocialFeedViewer viewer) {
    final _ViewerSession? session = _sessions[viewer.id];
    session?.flushPending();
  }
}

class _ViewerSession {
  _ViewerSession({
    required this.viewer,
    required this.scenario,
    required this.remote,
    required this.timerService,
    required this.onZeroLeases,
  });

  final SocialFeedViewer viewer;
  final SimulatedSocialFeedScenarioController scenario;
  final SimulatedSocialFeedRemoteDataSource remote;
  final TimerService timerService;
  final void Function() onZeroLeases;

  int _leaseCount = 0;
  int _backoffSeconds = 1;
  TimerDisposable? _reconnectTimer;
  final StreamController<SocialFeedConnectionStatus> _statusController =
      StreamController<SocialFeedConnectionStatus>.broadcast();
  final StreamController<SocialFeedPost> _postsController =
      StreamController<SocialFeedPost>.broadcast();
  bool _closed = false;

  SocialFeedRealtimeLease addLease() {
    _leaseCount += 1;
    if (_leaseCount == 1) {
      unawaited(_connect());
    }
    return _Lease(
      connectionStatus: _statusController.stream,
      posts: _postsController.stream,
      closeFn: _release,
    );
  }

  Future<void> _release() async {
    if (_leaseCount <= 0) {
      return;
    }
    _leaseCount -= 1;
    if (_leaseCount == 0) {
      await _shutdown();
      onZeroLeases();
    }
  }

  Future<void> forceClose() async {
    _leaseCount = 0;
    await _shutdown();
  }

  Future<void> _connect() async {
    if (_closed || _leaseCount == 0) {
      return;
    }
    _setStatus(SocialFeedConnectionStatus.connecting);
    if (scenario.consumeFailNextRealtimeReconnect(viewer: viewer)) {
      _setStatus(SocialFeedConnectionStatus.reconnecting);
      _scheduleReconnect();
      return;
    }
    if (scenario.consumeForceRealtimeDisconnect(viewer: viewer)) {
      _setStatus(SocialFeedConnectionStatus.reconnecting);
      _scheduleReconnect();
      return;
    }
    _backoffSeconds = 1;
    _setStatus(SocialFeedConnectionStatus.connected);
    flushPending();
  }

  void flushPending() {
    if (_closed || _leaseCount == 0) {
      return;
    }
    final int pending = scenario.consumePendingNewPosts(viewer: viewer);
    if (pending <= 0) {
      return;
    }
    final List<SocialFeedPost> posts = remote.createRealtimePosts(
      viewer: viewer,
      count: pending,
    );
    for (final SocialFeedPost post in posts) {
      if (!_postsController.isClosed) {
        _postsController.add(post);
      }
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.dispose();
    if (_leaseCount == 0 || _closed) {
      return;
    }
    final int delay = _backoffSeconds.clamp(1, 8);
    _backoffSeconds = (_backoffSeconds * 2).clamp(1, 8);
    _reconnectTimer = timerService.runOnce(Duration(seconds: delay), () {
      unawaited(_connect());
    });
  }

  void _setStatus(SocialFeedConnectionStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<void> _shutdown() async {
    _closed = true;
    _reconnectTimer?.dispose();
    _reconnectTimer = null;
    _setStatus(SocialFeedConnectionStatus.disconnected);
    await _statusController.close();
    await _postsController.close();
  }
}

class _Lease implements SocialFeedRealtimeLease {
  _Lease({
    required this.connectionStatus,
    required this.posts,
    required this._closeFn,
  });

  @override
  final Stream<SocialFeedConnectionStatus> connectionStatus;

  @override
  final Stream<SocialFeedPost> posts;

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
