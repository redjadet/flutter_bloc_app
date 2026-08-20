/// Trim/length validation for comment submission (Unicode scalar count).
class SocialFeedCommentPolicy {
  const SocialFeedCommentPolicy();

  static const int minLength = 1;
  static const int maxLength = 280;

  /// Returns trimmed body when valid; otherwise null.
  String? validate(String raw) {
    final String trimmed = raw.trim();
    final int length = trimmed.runes.length;
    if (length < minLength || length > maxLength) {
      return null;
    }
    return trimmed;
  }

  bool isValid(String raw) => validate(raw) != null;
}
