import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';

/// Deterministic fictional seed (60 posts). Shared content; likes personalize
/// per viewer in the simulated remote.
class SocialFeedSeedData {
  const SocialFeedSeedData();

  static const int postCount = 60;

  static const List<({String id, String name})> _authors =
      <({String id, String name})>[
        (id: 'author-a', name: 'Jordan'),
        (id: 'author-b', name: 'Riley'),
        (id: 'author-c', name: 'Morgan'),
        (id: 'author-d', name: 'Avery'),
        (id: 'author-e', name: 'Quinn'),
      ];

  static const List<String> _postBodies = <String>[
    'Shipped the offline queue path today. Feels good when reconnect just works.',
    'Anyone else prefer cubits over full blocs for screen-local state?',
    'Coffee shop Wi-Fi dropped mid-sync. Queue caught up cleanly after.',
    'Hot tip: keep feed payloads as counts, not unbounded liker lists.',
    'Sketching a viewer switcher for the demo — Alex and Sam stay isolated.',
    'Pull-to-refresh + stale-while-revalidate is such a calm UX pattern.',
    'Widget tests caught a modal BlocProvider miss. Worth the extra fixture.',
    'Trying denser cards on tablet; still one composition on phone.',
    'Realtime buffer badge helped a lot during flaky reconnect drills.',
    'Small wins: Semantics labels on like toggles finally feel right.',
    'Curious how far we can push optimistic comment counts before refresh.',
    'Hive cache survived a process kill. Mutation order stayed intact.',
    'Design review note: less chrome, more content hierarchy.',
    'Rejected mutations should restore canonical counts without losing the draft.',
    'GoRouter deep links into demos make walkthroughs so much smoother.',
    'Thinking about empty states that teach instead of apologize.',
    'Latency knob in the scenario panel is underrated for teaching races.',
    'Prefer pure Dart domain for merge policy — easier to unit test.',
    'Accessibility pass tomorrow: live regions for needs-attention rows.',
    'Nothing fancy, just a clean feed that fails gracefully offline.',
  ];

  static const List<String> _commentBodies = <String>[
    'Nice catch on the reconnect path.',
    'This matches what we saw in review.',
    'Love how calm this feels offline.',
    'Agreed — counts beat unbounded arrays.',
    'Sam and Alex isolation is the right call.',
    'That stale-while-revalidate tip is gold.',
    'Modal provider miss is a classic — good catch.',
    'Tablet density looks promising.',
    'Buffer badge is a great teaching signal.',
    'Semantics on likes should be table stakes.',
    'Optimistic counts are tricky; this is solid.',
    'Process-kill survival is the real demo.',
    'Less chrome, more hierarchy — yes.',
    'Draft retention on reject is underrated.',
    'Deep links make demos feel product-ready.',
    'Teaching empty states > apologizing ones.',
    'Scenario latency knob is such a gift.',
    'Pure merge policy tests are so readable.',
    'Live regions for attention rows — nice.',
    'Graceful offline is the whole point.',
  ];

  List<SocialFeedPost> build({required DateTime Function() clock}) {
    final DateTime now = clock().toUtc();
    return <SocialFeedPost>[
      for (int i = 0; i < postCount; i++)
        SocialFeedPost(
          id: 'post-${(postCount - i).toString().padLeft(3, '0')}',
          authorId: _authors[i % _authors.length].id,
          authorDisplayName: _authors[i % _authors.length].name,
          body: _postBodies[i % _postBodies.length],
          createdAt: now.subtract(Duration(minutes: i * 3)),
          isLikedByMe: false,
          likeCount: i % 7,
          // Sparse threads: most posts quiet; some 1–2 comments.
          commentCount: i % 5 == 0
              ? 2
              : i % 5 == 2
              ? 1
              : 0,
          serverRevision: 1,
        ),
    ];
  }

  /// Deterministic thread bodies for [count] comments on [postId].
  List<SocialFeedSeedComment> commentsFor({
    required String postId,
    required int count,
    required DateTime baseCreatedAt,
  }) {
    if (count <= 0) {
      return const <SocialFeedSeedComment>[];
    }
    final int postOrdinal = int.tryParse(postId.replaceFirst('post-', '')) ?? 0;
    return <SocialFeedSeedComment>[
      for (int i = 0; i < count; i++)
        SocialFeedSeedComment(
          id: '$postId-cmt-${i + 1}',
          postId: postId,
          authorId: _authors[(postOrdinal + i + 1) % _authors.length].id,
          authorDisplayName:
              _authors[(postOrdinal + i + 1) % _authors.length].name,
          body: _commentBodies[(postOrdinal + i) % _commentBodies.length],
          createdAt: baseCreatedAt.add(Duration(minutes: i + 1)),
        ),
    ];
  }
}

/// Seed-only comment row (no mutation status; always treated as synced).
class const SocialFeedSeedComment({
  required final String id,
  required final String postId,
  required final String authorId,
  required final String authorDisplayName,
  required final String body,
  required final DateTime createdAt,
});
