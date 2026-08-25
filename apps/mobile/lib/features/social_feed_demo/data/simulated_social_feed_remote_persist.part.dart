part of 'simulated_social_feed_remote_data_source.dart';

extension SimulatedSocialFeedRemotePersist
    on SimulatedSocialFeedRemoteDataSource {
  /// Full thread snapshot for Hive persistence (shared across viewers).
  Map<String, List<SocialFeedComment>> exportCommentThreads() {
    return <String, List<SocialFeedComment>>{
      for (final MapEntry<String, List<SocialFeedComment>> entry
          in _commentsByPostId.entries)
        entry.key: List<SocialFeedComment>.from(entry.value),
    };
  }

  /// Viewer-scoped liked post ids for Hive persistence.
  Map<String, Set<String>> exportViewerLikes() {
    return <String, Set<String>>{
      for (final MapEntry<String, Set<String>> entry in _likedByViewer.entries)
        entry.key: Set<String>.from(entry.value),
    };
  }

  /// Restore viewer likes after process restart.
  void replaceViewerLikes(Map<String, Set<String>> likes) {
    _likedByViewer
      ..clear()
      ..addAll(<String, Set<String>>{
        for (final MapEntry<String, Set<String>> entry in likes.entries)
          entry.key: Set<String>.from(entry.value),
      });
  }

  /// Restore threads after process restart; aligns stored post commentCounts.
  void replaceCommentThreads(Map<String, List<SocialFeedComment>> threads) {
    _commentsByPostId
      ..clear()
      ..addAll(<String, List<SocialFeedComment>>{
        for (final MapEntry<String, List<SocialFeedComment>> entry
            in threads.entries)
          entry.key: List<SocialFeedComment>.from(entry.value),
      });
    for (final SocialFeedPost post in _posts) {
      _commentsByPostId.putIfAbsent(post.id, () => <SocialFeedComment>[]);
    }
    _posts = <SocialFeedPost>[
      for (final SocialFeedPost post in _posts)
        post.copyWith(
          commentCount: _commentsByPostId[post.id]?.length ?? 0,
        ),
    ];
  }
}
