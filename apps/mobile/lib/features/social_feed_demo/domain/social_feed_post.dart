import 'package:meta/meta.dart';

/// Viewer-projected feed post (bounded counts; no liker arrays).
@immutable
class const SocialFeedPost({
  required final String id,
  required final String authorId,
  required final String authorDisplayName,
  required final String body,
  required final DateTime createdAt,
  required final bool isLikedByMe,
  required final int likeCount,
  required final int commentCount,
  required final int serverRevision,
}) {
  SocialFeedPost copyWith({
    String? id,
    String? authorId,
    String? authorDisplayName,
    String? body,
    DateTime? createdAt,
    bool? isLikedByMe,
    int? likeCount,
    int? commentCount,
    int? serverRevision,
  }) {
    return SocialFeedPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      serverRevision: serverRevision ?? this.serverRevision,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SocialFeedPost &&
      other.id == id &&
      other.serverRevision == serverRevision &&
      other.isLikedByMe == isLikedByMe &&
      other.likeCount == likeCount &&
      other.commentCount == commentCount;

  @override
  int get hashCode =>
      Object.hash(id, serverRevision, isLikedByMe, likeCount, commentCount);
}
