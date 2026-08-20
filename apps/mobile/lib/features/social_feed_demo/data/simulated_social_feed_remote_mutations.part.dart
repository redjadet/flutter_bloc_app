part of 'simulated_social_feed_remote_data_source.dart';

extension SimulatedSocialFeedRemoteMutations
    on SimulatedSocialFeedRemoteDataSource {
  Future<SocialFeedPost> applyLike({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  }) async {
    await _delay();
    if (!_scenario.isSimulatedOnline) {
      throw const SocialFeedOfflineFailure();
    }
    final SocialFeedPost? cached = _mutationAckCache[viewer.id]?[mutationId];
    if (cached != null) {
      return cached;
    }
    if (_scenario.consumeRejectNextLike(viewer: viewer)) {
      final SocialFeedPost? canonical = _find(postId);
      if (canonical == null) {
        throw const SocialFeedUnknownFailure();
      }
      throw SocialFeedRemoteRejection(canonical: _project(viewer, canonical));
    }
    if (_scenario.consumeRetryableDispatchFailure(viewer: viewer)) {
      throw const SocialFeedUnknownFailure();
    }
    final Set<String> liked = _likedByViewer.putIfAbsent(
      viewer.id,
      () => <String>{},
    );
    if (desiredLiked) {
      liked.add(postId);
    } else {
      liked.remove(postId);
    }
    final SocialFeedPost? base = _find(postId);
    if (base == null) {
      throw const SocialFeedUnknownFailure();
    }
    final SocialFeedPost projected = _project(viewer, base).copyWith(
      serverRevision: base.serverRevision + 1,
    );
    _replace(base.copyWith(serverRevision: base.serverRevision + 1));
    _mutationAckCache.putIfAbsent(
      viewer.id,
      () => <String, SocialFeedPost>{},
    )[mutationId] = projected;
    return projected;
  }

  Future<SocialFeedPost> applyComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  }) async {
    await _delay();
    if (!_scenario.isSimulatedOnline) {
      throw const SocialFeedOfflineFailure();
    }
    final SocialFeedPost? cached = _mutationAckCache[viewer.id]?[mutationId];
    if (cached != null) {
      return cached;
    }
    if (_scenario.consumeRejectNextComment(viewer: viewer)) {
      final SocialFeedPost? canonical = _find(postId);
      if (canonical == null) {
        throw const SocialFeedUnknownFailure();
      }
      throw SocialFeedRemoteRejection(canonical: _project(viewer, canonical));
    }
    if (_scenario.consumeRetryableDispatchFailure(viewer: viewer)) {
      throw const SocialFeedUnknownFailure();
    }
    // body intentionally unused after validation — never log it.
    _commentExtras[postId] = (_commentExtras[postId] ?? 0) + 1;
    final SocialFeedPost? base = _find(postId);
    if (base == null) {
      throw const SocialFeedUnknownFailure();
    }
    final SocialFeedPost bumped = base.copyWith(
      serverRevision: base.serverRevision + 1,
    );
    _replace(bumped);
    final SocialFeedPost projected = _project(viewer, bumped);
    _mutationAckCache.putIfAbsent(
      viewer.id,
      () => <String, SocialFeedPost>{},
    )[mutationId] = projected;
    return projected;
  }

  void resetViewerPersonalization(SocialFeedViewer viewer) {
    _likedByViewer.remove(viewer.id);
    _mutationAckCache.remove(viewer.id);
    // Comment extras are shared content counts from demo mutations; leave seed
    // extras tied to posts but clear viewer-only like state.
  }

  SocialFeedPost? _find(String postId) {
    for (final SocialFeedPost post in _posts) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  void _replace(SocialFeedPost post) {
    final int index = _posts.indexWhere((p) => p.id == post.id);
    if (index >= 0) {
      _posts[index] = post;
    }
  }
}
