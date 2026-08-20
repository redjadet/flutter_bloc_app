/// Wire DTO for feed posts. V1: all fields required; unknown extras ignored.
class const SocialFeedPostDto({
  required final String id,
  required final String authorId,
  required final String authorDisplayName,
  required final String body,
  required final String createdAt,
  required final bool isLikedByMe,
  required final int likeCount,
  required final int commentCount,
  required final int serverRevision,
});
