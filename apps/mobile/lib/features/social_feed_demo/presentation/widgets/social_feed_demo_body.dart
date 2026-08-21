import 'dart:async';

import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_error_view.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_loading_view.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_new_posts_banner.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_post_item.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_scenario_controls.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_senior_signal_panel.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_status_banner.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class SocialFeedDemoBody extends StatelessWidget {
  const SocialFeedDemoBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialFeedCubit, SocialFeedState>(
      listenWhen: (previous, current) {
        if (current is! SocialFeedReady) {
          return false;
        }
        if (previous is! SocialFeedReady) {
          return current.data.effect != null;
        }
        return previous.data.effectId != current.data.effectId;
      },
      listener: (context, state) {
        if (state is! SocialFeedReady) {
          return;
        }
        final SocialFeedEffect? effect = state.data.effect;
        if (effect == null) {
          return;
        }
        final AppLocalizations l10n = AppLocalizations.of(context);
        final String message = switch (effect) {
          SocialFeedMutationRejectedEffect() =>
            l10n.socialFeedDemoMutationRejected,
          SocialFeedAnnouncementEffect(:final code) => code,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      builder: (context, state) {
        return switch (state) {
          SocialFeedInitial() ||
          SocialFeedLoading() => const SocialFeedLoadingView(),
          SocialFeedFailureState(:final failure) => SocialFeedErrorView(
            failure: failure,
            onRetry: () => context.read<SocialFeedCubit>().load(),
          ),
          SocialFeedReady(:final data) => _ReadyBody(data: data),
        };
      },
    );
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({required this.data});

  final SocialFeedReadyData data;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= LayoutBreakpoints.tabletBreakpoint;
    final bool tabletBand =
        width >= LayoutBreakpoints.mobileBreakpoint && !wide;

    final Widget feed = _FeedColumn(data: data);
    if (!wide && !tabletBand) {
      return feed;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(flex: 3, child: feed),
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: const <Widget>[
              SocialFeedSeniorSignalPanel(),
              SizedBox(height: 12),
              SocialFeedScenarioControls(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedColumn extends StatelessWidget {
  const _FeedColumn({required this.data});

  final SocialFeedReadyData data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SocialFeedCubit cubit = context.read<SocialFeedCubit>();
    final bool hasBufferedPosts = data.bufferedRealtimePosts.isNotEmpty;
    final bool hasFooter =
        data.pageStatus is SocialFeedPageLoading ||
        data.pageStatus is SocialFeedPageFailureStatus;
    final int itemCount =
        1 +
        (hasBufferedPosts ? 1 : 0) +
        (data.posts.isEmpty ? 1 : data.posts.length) +
        (hasFooter ? 1 : 0);
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter <= 400) {
            // check-ignore: side_effects_build - scroll notification is event-driven.
            unawaited(cubit.loadMore());
          }
          return false;
        },
        child: ListView.builder(
          key: const ValueKey('social-feed-list'),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index == 0) {
              return SocialFeedStatusBanner(
                key: const ValueKey('social-feed-status-banner'),
                data: data,
              );
            }
            var feedIndex = index - 1;
            if (hasBufferedPosts) {
              if (feedIndex == 0) {
                return SocialFeedNewPostsBanner(
                  key: const ValueKey('social-feed-new-posts-banner'),
                  count: data.bufferedRealtimePosts.length,
                  onActivate: cubit.activateBufferedPosts,
                );
              }
              feedIndex -= 1;
            }
            if (data.posts.isEmpty) {
              if (feedIndex == 0) {
                return Center(
                  key: const ValueKey('social-feed-empty'),
                  child: Text(l10n.socialFeedDemoEmpty),
                );
              }
              feedIndex -= 1;
            } else if (feedIndex < data.posts.length) {
              final post = data.posts[feedIndex];
              return SocialFeedPostItem(
                key: ValueKey('social-feed-post-${post.id}'),
                postId: post.id,
              );
            } else {
              feedIndex -= data.posts.length;
            }
            return switch (data.pageStatus) {
              SocialFeedPageLoading() => const Padding(
                key: ValueKey('social-feed-page-loading'),
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              SocialFeedPageFailureStatus(:final failure) => TextButton(
                key: const ValueKey('social-feed-page-retry'),
                onPressed: cubit.loadMore,
                child: Text(_failureLabel(l10n, failure)),
              ),
              _ => const SizedBox.shrink(
                key: ValueKey('social-feed-page-idle'),
              ),
            };
          },
        ),
      ),
    );
  }
}

String _failureLabel(AppLocalizations l10n, SocialFeedFailure failure) {
  return switch (failure) {
    SocialFeedOfflineFailure() => l10n.socialFeedDemoOffline,
    SocialFeedMalformedDataFailure() => l10n.socialFeedDemoMalformed,
    SocialFeedPageFailure() => l10n.socialFeedDemoPageError,
    _ => l10n.socialFeedDemoRetry,
  };
}
