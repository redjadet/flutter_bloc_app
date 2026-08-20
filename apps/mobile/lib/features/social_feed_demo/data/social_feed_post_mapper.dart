import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_post_dto.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';

class SocialFeedPostMapper {
  const SocialFeedPostMapper();

  static final RegExp _offsetSuffix = RegExp(r'[+-]\d{2}:\d{2}$');

  SocialFeedPostDto fromJson(Map<String, Object?> json) {
    try {
      final Object? id = json['id'];
      final Object? authorId = json['authorId'];
      final Object? authorDisplayName = json['authorDisplayName'];
      final Object? body = json['body'];
      final Object? createdAt = json['createdAt'];
      final Object? isLikedByMe = json['isLikedByMe'];
      final Object? likeCount = json['likeCount'];
      final Object? commentCount = json['commentCount'];
      final Object? serverRevision = json['serverRevision'];

      if (id is! String ||
          authorId is! String ||
          authorDisplayName is! String ||
          body is! String ||
          createdAt is! String ||
          isLikedByMe is! bool ||
          likeCount is! int ||
          commentCount is! int ||
          serverRevision is! int) {
        throw const SocialFeedMalformedDataFailure();
      }
      if (likeCount < 0 || commentCount < 0) {
        throw const SocialFeedMalformedDataFailure();
      }
      DateTime.parse(createdAt);
      final bool hasZ = createdAt.endsWith('Z');
      final bool hasOffset = _offsetSuffix.hasMatch(createdAt);
      if (!hasZ && !hasOffset) {
        throw const SocialFeedMalformedDataFailure();
      }

      return SocialFeedPostDto(
        id: id,
        authorId: authorId,
        authorDisplayName: authorDisplayName,
        body: body,
        createdAt: createdAt,
        isLikedByMe: isLikedByMe,
        likeCount: likeCount,
        commentCount: commentCount,
        serverRevision: serverRevision,
      );
    } on SocialFeedFailure {
      rethrow;
    } on FormatException {
      throw const SocialFeedMalformedDataFailure();
    } on Object {
      throw const SocialFeedMalformedDataFailure();
    }
  }

  SocialFeedPost toDomain(SocialFeedPostDto dto) {
    return SocialFeedPost(
      id: dto.id,
      authorId: dto.authorId,
      authorDisplayName: dto.authorDisplayName,
      body: dto.body,
      createdAt: DateTime.parse(dto.createdAt).toUtc(),
      isLikedByMe: dto.isLikedByMe,
      likeCount: dto.likeCount,
      commentCount: dto.commentCount,
      serverRevision: dto.serverRevision,
    );
  }

  Map<String, Object?> toJson(SocialFeedPost post) => <String, Object?>{
    'id': post.id,
    'authorId': post.authorId,
    'authorDisplayName': post.authorDisplayName,
    'body': post.body,
    'createdAt': post.createdAt.toUtc().toIso8601String(),
    'isLikedByMe': post.isLikedByMe,
    'likeCount': post.likeCount,
    'commentCount': post.commentCount,
    'serverRevision': post.serverRevision,
  };
}
