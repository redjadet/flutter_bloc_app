/// Persisted mutation queue / attention record (stable string enums).
class const SocialFeedMutationDto({
  required final String mutationId,
  required final String viewerId,
  required final String type,
  required final String postId,
  required final int sequence,
  required final String idempotencyKey,
  required final int attemptCount,
  required final String? nextAttemptAt,
  required final bool? desiredLiked,
  required final String? commentBody,
  required final String status,
  required final bool dispatched,
});
