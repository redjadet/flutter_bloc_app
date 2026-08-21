import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_comment_composer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_post_card.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_visible_comments.dart';

/// Selector wrapper so liking one post does not rebuild siblings.
class SocialFeedPostItem extends StatefulWidget {
  const SocialFeedPostItem({required this.postId, super.key});

  final String postId;

  @override
  State<SocialFeedPostItem> createState() => _SocialFeedPostItemState();
}

class _SocialFeedPostItemState extends State<SocialFeedPostItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SocialFeedCubit, SocialFeedState, _PostRowView?>(
      selector: (state) {
        if (state is! SocialFeedReady) {
          return null;
        }
        SocialFeedPost? post;
        for (final SocialFeedPost candidate in state.data.posts) {
          if (candidate.id == widget.postId) {
            post = candidate;
            break;
          }
        }
        if (post == null) {
          return null;
        }
        return _PostRowView(
          post: post,
          isPending: state.data.pendingPostIds.contains(widget.postId),
          attentionMutationId: state.data.needsAttentionByPostId[widget.postId],
          pendingComments:
              state.data.pendingCommentsByPostId[widget.postId] ??
              const <SocialFeedComment>[],
          storedComments:
              state.data.commentsByPostId[widget.postId] ??
              const <SocialFeedComment>[],
        );
      },
      builder: (context, row) {
        if (row == null) {
          return const SizedBox.shrink();
        }
        final SocialFeedCubit cubit = context.read<SocialFeedCubit>();
        final String? attentionMutationId = row.attentionMutationId;
        final List<SocialFeedVisibleComment> visibleComments =
            resolveSocialFeedVisibleComments(
              post: row.post,
              storedComments: row.storedComments,
              pendingComments: row.pendingComments,
            );
        return SocialFeedPostCard(
          key: ValueKey('social-feed-post-card-${row.post.id}'),
          post: row.post,
          isPending: row.isPending,
          needsAttention: attentionMutationId != null,
          expanded: _expanded,
          visibleComments: visibleComments,
          onToggleExpanded: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          onLike: () {
            // check-ignore: side_effects_build - user gesture callback.
            unawaited(cubit.toggleLike(widget.postId));
          },
          onComment: () {
            setState(() {
              _expanded = true;
            });
            // check-ignore: side_effects_build - user gesture callback.
            unawaited(
              SocialFeedCommentComposer.show(
                context,
                postId: widget.postId,
              ),
            );
          },
          onRetryAttention: attentionMutationId == null
              ? null
              : () {
                  // check-ignore: side_effects_build - user gesture callback.
                  unawaited(cubit.retryNeedsAttention(attentionMutationId));
                },
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
    required this.pendingComments,
    required this.storedComments,
  });

  final SocialFeedPost post;
  final bool isPending;
  final String? attentionMutationId;
  final List<SocialFeedComment> pendingComments;
  final List<SocialFeedComment> storedComments;
}
