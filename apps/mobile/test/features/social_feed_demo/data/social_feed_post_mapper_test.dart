import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_post_mapper.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const SocialFeedPostMapper mapper = SocialFeedPostMapper();

  test('maps valid UTC payload', () {
    final dto = mapper.fromJson(<String, Object?>{
      'id': '1',
      'authorId': 'a',
      'authorDisplayName': 'A',
      'body': 'hello',
      'createdAt': '2026-08-20T12:00:00.000Z',
      'isLikedByMe': false,
      'likeCount': 1,
      'commentCount': 0,
      'serverRevision': 1,
      'extraIgnored': true,
    });
    final post = mapper.toDomain(dto);
    expect(post.id, '1');
    expect(post.createdAt.isUtc, isTrue);
  });

  test('rejects negative counts', () {
    expect(
      () => mapper.fromJson(<String, Object?>{
        'id': '1',
        'authorId': 'a',
        'authorDisplayName': 'A',
        'body': 'hello',
        'createdAt': '2026-08-20T12:00:00.000Z',
        'isLikedByMe': false,
        'likeCount': -1,
        'commentCount': 0,
        'serverRevision': 1,
      }),
      throwsA(isA<SocialFeedMalformedDataFailure>()),
    );
  });

  test('rejects timestamp without Z/offset', () {
    expect(
      () => mapper.fromJson(<String, Object?>{
        'id': '1',
        'authorId': 'a',
        'authorDisplayName': 'A',
        'body': 'hello',
        'createdAt': '2026-08-20T12:00:00.000',
        'isLikedByMe': false,
        'likeCount': 0,
        'commentCount': 0,
        'serverRevision': 1,
      }),
      throwsA(isA<SocialFeedMalformedDataFailure>()),
    );
  });
}
