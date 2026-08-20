import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_comment_composer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_post_card.dart';

/// Selector wrapper so liking one post does not rebuild siblings.
class SocialFeedPostItem extends StatelessWidget {
  const SocialFeedPostItem({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SocialFeedCubit, SocialFeedState, _PostRowView?>(
      selector: (state) {
        if (state is! SocialFeedReady) {
          return null;
        }
        SocialFeedPost? post;
        for (final SocialFeedPost candidate in state.data.posts) {
          if (candidate.id == postId) {
            post = candidate;
            break;
          }
        }
        if (post == null) {
          return null;
        }
        return _PostRowView(
          post: post,
          isPending: state.data.pendingPostIds.contains(postId),
          attentionMutationId: state.data.needsAttentionByPostId[postId],
        );
      },
      builder: (context, row) {
        if (row == null) {
          return const SizedBox.shrink();
        }
        final SocialFeedCubit cubit = context.read<SocialFeedCubit>();
        final String? attentionMutationId = row.attentionMutationId;
        return SocialFeedPostCard(
          key: ValueKey('social-feed-post-card-${row.post.id}'),
          post: row.post,
          isPending: row.isPending,
          needsAttention: attentionMutationId != null,
          onLike: () => cubit.toggleLike(postId),
          onComment: () => SocialFeedCommentComposer.show(
            context,
            postId: postId,
          ),
          onRetryAttention: attentionMutationId == null
              ? null
              : () => unawaited(cubit.retryNeedsAttention(attentionMutationId)),
        );
      },
    );
  }
}

class _PostRowView {
  const _PostRowView({
    required this.post,
    required this.isPending,
    required this.attentionMutationId,
  });

  final SocialFeedPost post;
  final bool isPending;
  final String? attentionMutationId;
}
