sealed class SocialFeedFailure implements Exception {
  const new({required this.code});

  final String code;

  @override
  String toString() => 'SocialFeedFailure($code)';
}

final class SocialFeedOfflineFailure extends SocialFeedFailure {
  const new() : super(code: 'social_feed_offline');
}

final class SocialFeedMalformedDataFailure extends SocialFeedFailure {
  const new() : super(code: 'social_feed_malformed_data');
}

final class SocialFeedPageFailure extends SocialFeedFailure {
  const new() : super(code: 'social_feed_page_failure');
}

final class SocialFeedMutationRejectedFailure extends SocialFeedFailure {
  const new() : super(code: 'social_feed_mutation_rejected');
}

final class SocialFeedNotQueuedFailure extends SocialFeedFailure {
  const new() : super(code: 'social_feed_not_queued');
}

final class SocialFeedPersistenceDegradedFailure extends SocialFeedFailure {
  const new() : super(code: 'social_feed_persistence_degraded');
}

final class SocialFeedUnknownFailure extends SocialFeedFailure {
  const new() : super(code: 'social_feed_unknown');
}
