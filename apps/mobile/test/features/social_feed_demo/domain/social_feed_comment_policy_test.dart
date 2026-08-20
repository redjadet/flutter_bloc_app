import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const SocialFeedCommentPolicy policy = SocialFeedCommentPolicy();

  test('rejects whitespace-only', () {
    expect(policy.validate('   '), isNull);
  });

  test('accepts 1 and 280 runes', () {
    expect(policy.validate('a'), 'a');
    expect(policy.validate('é' * 280)?.runes.length, 280);
  });

  test('rejects 281 runes', () {
    expect(policy.validate('a' * 281), isNull);
  });
}
