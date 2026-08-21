import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_comment_dto.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';

class SocialFeedCommentMapper {
  const SocialFeedCommentMapper();

  SocialFeedCommentDto fromJson(Map<String, Object?> json) {
    try {
      final Object? id = json['id'];
      final Object? postId = json['postId'];
      final Object? viewerId = json['viewerId'];
      final Object? body = json['body'];
      final Object? createdAt = json['createdAt'];
      final Object? syncStatus = json['syncStatus'];
      if (id is! String ||
          postId is! String ||
          viewerId is! String ||
          body is! String ||
          createdAt is! String ||
          syncStatus is! String) {
        throw const SocialFeedMalformedDataFailure();
      }
      return SocialFeedCommentDto(
        id: id,
        postId: postId,
        viewerId: viewerId,
        body: body,
        createdAt: createdAt,
        syncStatus: syncStatus,
      );
    } on SocialFeedFailure {
      rethrow;
    } on Object {
      throw const SocialFeedMalformedDataFailure();
    }
  }

  SocialFeedComment toDomain(SocialFeedCommentDto dto) {
    return SocialFeedComment(
      id: dto.id,
      postId: dto.postId,
      viewerId: dto.viewerId,
      body: dto.body,
      createdAt: DateTime.parse(dto.createdAt).toUtc(),
      syncStatus: switch (dto.syncStatus) {
        'pending' => SocialFeedMutationStatus.pending,
        'synced' => SocialFeedMutationStatus.synced,
        'needsAttention' => SocialFeedMutationStatus.needsAttention,
        _ => throw const SocialFeedMalformedDataFailure(),
      },
    );
  }

  SocialFeedCommentDto toDto(SocialFeedComment comment) {
    return SocialFeedCommentDto(
      id: comment.id,
      postId: comment.postId,
      viewerId: comment.viewerId,
      body: comment.body,
      createdAt: comment.createdAt.toUtc().toIso8601String(),
      syncStatus: switch (comment.syncStatus) {
        SocialFeedMutationStatus.pending => 'pending',
        SocialFeedMutationStatus.synced => 'synced',
        SocialFeedMutationStatus.needsAttention => 'needsAttention',
      },
    );
  }

  Map<String, Object?> toJson(SocialFeedComment comment) {
    final SocialFeedCommentDto dto = toDto(comment);
    return <String, Object?>{
      'id': dto.id,
      'postId': dto.postId,
      'viewerId': dto.viewerId,
      'body': dto.body,
      'createdAt': dto.createdAt,
      'syncStatus': dto.syncStatus,
    };
  }
}
