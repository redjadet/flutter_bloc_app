part of 'hive_social_feed_local_data_source.dart';

extension HiveSocialFeedLocalDataSourceLikes on HiveSocialFeedLocalDataSource {
  /// Viewer-scoped liked post ids (restored into remote personalization).
  Future<Map<String, Set<String>>?> readViewerLikes() async {
    try {
      return await runWithBox((box) async {
        final Object? raw = box.get(HiveSocialFeedLocalDataSource._likesKey);
        if (raw is! Map) {
          return null;
        }
        final Map<String, Set<String>> likes = <String, Set<String>>{};
        raw.forEach((viewerId, value) {
          if (viewerId == null || value is! List) {
            return;
          }
          likes[viewerId.toString()] = <String>{
            for (final Object? postId in value)
              if (postId is String) postId,
          };
        });
        return likes;
      });
    } on Object {
      return null;
    }
  }

  Future<void> saveViewerLikes(Map<String, Set<String>> likes) async {
    await runWithBox((box) async {
      await box.put(HiveSocialFeedLocalDataSource._likesKey, <String, Object?>{
        for (final MapEntry<String, Set<String>> entry in likes.entries)
          entry.key: entry.value.toList(),
      });
    });
  }

  Future<void> removeViewerLikes(SocialFeedViewer viewer) async {
    await runWithBox((box) async {
      final Object? raw = box.get(HiveSocialFeedLocalDataSource._likesKey);
      if (raw is! Map) {
        return;
      }
      final Map<String, Object?> updated = raw.map(
        (k, v) => MapEntry(k.toString(), v),
      )..remove(viewer.id);
      if (updated.isEmpty) {
        await safeDeleteKey(box, HiveSocialFeedLocalDataSource._likesKey);
      } else {
        await box.put(HiveSocialFeedLocalDataSource._likesKey, updated);
      }
    });
  }
}
