import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_comment_mapper.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const SocialFeedCommentMapper mapper = SocialFeedCommentMapper();

  test('round-trips valid comment json', () {
    final comment = mapper.toDomain(
      mapper.fromJson(<String, Object?>{
        'id': 'c1',
        'postId': 'p1',
        'viewerId': 'demo-alex',
        'body': 'hello',
        'createdAt': '2026-08-20T10:00:00.000Z',
        'syncStatus': 'pending',
      }),
    );
    expect(comment.id, 'c1');
    expect(comment.syncStatus, SocialFeedMutationStatus.pending);
    expect(mapper.toJson(comment), <String, Object?>{
      'id': 'c1',
      'postId': 'p1',
      'viewerId': 'demo-alex',
      'body': 'hello',
      'createdAt': '2026-08-20T10:00:00.000Z',
      'syncStatus': 'pending',
    });
  });

  test('rejects unknown syncStatus in toDomain', () {
    expect(
      () => mapper.toDomain(
        mapper.fromJson(<String, Object?>{
          'id': 'c1',
          'postId': 'p1',
          'viewerId': 'demo-alex',
          'body': 'hello',
          'createdAt': '2026-08-20T10:00:00.000Z',
          'syncStatus': 'bogus',
        }),
      ),
      throwsA(isA<SocialFeedMalformedDataFailure>()),
    );
  });

  test('rejects missing fields', () {
    expect(
      () => mapper.fromJson(<String, Object?>{'id': 'c1'}),
      throwsA(isA<SocialFeedMalformedDataFailure>()),
    );
  });
}
