part of 'hive_social_feed_mutation_queue.dart';

extension HiveSocialFeedMutationQueueJson on HiveSocialFeedMutationQueue {
  SocialFeedMutationDto _fromJson(Map<String, Object?> json) {
    final String? mutationId = json['mutationId'] as String?;
    final String? viewerId = json['viewerId'] as String?;
    final String? type = json['type'] as String?;
    final String? postId = json['postId'] as String?;
    final int? sequence = json['sequence'] as int?;
    final String? idempotencyKey = json['idempotencyKey'] as String?;
    final int? attemptCount = json['attemptCount'] as int?;
    final String? status = json['status'] as String?;
    final bool? dispatched = json['dispatched'] as bool?;
    if (mutationId == null ||
        viewerId == null ||
        type == null ||
        postId == null ||
        sequence == null ||
        idempotencyKey == null ||
        attemptCount == null ||
        status == null ||
        dispatched == null) {
      throw const FormatException('Invalid social feed mutation JSON');
    }
    return SocialFeedMutationDto(
      mutationId: mutationId,
      viewerId: viewerId,
      type: type,
      postId: postId,
      sequence: sequence,
      idempotencyKey: idempotencyKey,
      attemptCount: attemptCount,
      nextAttemptAt: json['nextAttemptAt'] as String?,
      desiredLiked: json['desiredLiked'] as bool?,
      commentBody: json['commentBody'] as String?,
      status: status,
      dispatched: dispatched,
    );
  }

  Map<String, Object?> _toJson(SocialFeedMutationDto dto) => <String, Object?>{
    'mutationId': dto.mutationId,
    'viewerId': dto.viewerId,
    'type': dto.type,
    'postId': dto.postId,
    'sequence': dto.sequence,
    'idempotencyKey': dto.idempotencyKey,
    'attemptCount': dto.attemptCount,
    'nextAttemptAt': dto.nextAttemptAt,
    'desiredLiked': dto.desiredLiked,
    'commentBody': dto.commentBody,
    'status': dto.status,
    'dispatched': dto.dispatched,
  };
}
