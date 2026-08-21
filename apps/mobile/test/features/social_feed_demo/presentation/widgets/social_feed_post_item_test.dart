import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_post_item.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('like control exposes selected state semantically', (
    WidgetTester tester,
  ) async {
    final _HarnessCubit cubit = _HarnessCubit();
    cubit.showPost(
      SocialFeedPost(
        id: 'p1',
        authorId: 'a1',
        authorDisplayName: 'Author',
        body: 'Hello',
        createdAt: DateTime.utc(2026, 8, 1),
        isLikedByMe: false,
        likeCount: 0,
        commentCount: 0,
        serverRevision: 1,
      ),
    );
    addTearDown(cubit.close);

    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<SocialFeedCubit>.value(
          value: cubit,
          child: const Scaffold(body: SocialFeedPostItem(postId: 'p1')),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Not liked'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('like button calls toggleLike', (WidgetTester tester) async {
    final _HarnessCubit cubit = _HarnessCubit();
    cubit.showPost(
      SocialFeedPost(
        id: 'p1',
        authorId: 'a1',
        authorDisplayName: 'Author',
        body: 'Hello',
        createdAt: DateTime.utc(2026, 8, 1),
        isLikedByMe: false,
        likeCount: 0,
        commentCount: 0,
        serverRevision: 1,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<SocialFeedCubit>.value(
          value: cubit,
          child: const Scaffold(body: SocialFeedPostItem(postId: 'p1')),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('social-feed-like-p1')));
    await tester.pump();
    expect(cubit.likeCalls, 1);
    await cubit.close();
  });
}

class _HarnessCubit extends SocialFeedCubit {
  _HarnessCubit()
    : super(
        repository: _UnusedRepo(),
        realtimeSource: _UnusedRealtime(),
        scenario: _UnusedScenario(),
        clock: () => DateTime.utc(2026, 8, 20),
      );

  int likeCalls = 0;

  void showPost(SocialFeedPost post) {
    emit(
      SocialFeedState.ready(
        SocialFeedReadyData(
          viewer: SocialFeedViewer.alex,
          posts: <SocialFeedPost>[post],
          nextCursor: null,
          refreshStatus: const SocialFeedRefreshStatus.idle(),
          pageStatus: const SocialFeedPageStatus.exhausted(),
          isShowingCachedData: false,
          cacheAge: Duration.zero,
          connectionStatus: SocialFeedConnectionStatus.disconnected,
          isSimulatedOffline: false,
          bufferedRealtimePosts: const <SocialFeedPost>[],
          pendingMutationCount: 0,
          needsAttentionCount: 0,
          pendingPostIds: const <String>{},
          needsAttentionByPostId: const <String, String>{},
          pendingCommentsByPostId: const {},
        ),
      ),
    );
  }

  @override
  Future<void> toggleLike(String postId) async {
    likeCalls += 1;
  }
}

class _UnusedScenario implements SocialFeedScenarioController {
  @override
  bool get isSimulatedOnline => true;

  @override
  void setSimulatedOnline({required bool online}) {}

  @override
  void emitThreeNewPosts({required SocialFeedViewer viewer}) {}

  @override
  void failNextInitialOrRefresh({required SocialFeedViewer viewer}) {}

  @override
  void failNextLoadMore({required SocialFeedViewer viewer}) {}

  @override
  void disconnectRealtimeAndFailNextReconnect({
    required SocialFeedViewer viewer,
  }) {}

  @override
  void failNextFiveQueuedDispatchesRetryably({
    required SocialFeedViewer viewer,
  }) {}

  @override
  void rejectNextLikePermanently({required SocialFeedViewer viewer}) {}

  @override
  void rejectNextCommentPermanently({required SocialFeedViewer viewer}) {}

  @override
  void returnMalformedNextPayload({required SocialFeedViewer viewer}) {}

  @override
  void resetViewerSimulatorFaults({required SocialFeedViewer viewer}) {}
}

class _UnusedRealtime implements SocialFeedRealtimeSource {
  @override
  Future<SocialFeedRealtimeLease> acquire(SocialFeedViewer viewer) async =>
      throw UnimplementedError();

  @override
  void flushPendingPosts(SocialFeedViewer viewer) {}
}

class _UnusedRepo implements SocialFeedRepository {
  @override
  Future<SocialFeedPage?> readCachedPage({
    required SocialFeedViewer viewer,
  }) async => null;

  @override
  Future<SocialFeedPage> refresh({required SocialFeedViewer viewer}) async =>
      throw UnimplementedError();

  @override
  Future<SocialFeedPage> loadMore({
    required SocialFeedViewer viewer,
    required String cursor,
  }) async => throw UnimplementedError();

  @override
  Future<SocialFeedLikeResult> setLiked({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  }) async => throw UnimplementedError();

  @override
  Future<SocialFeedCommentResult> addComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  }) async => throw UnimplementedError();

  @override
  Future<SocialFeedSyncLease> acquireSync({
    required SocialFeedViewer viewer,
  }) async => throw UnimplementedError();

  @override
  Future<void> retryNeedsAttention({
    required SocialFeedViewer viewer,
    required String mutationId,
  }) async {}

  @override
  Future<int> pendingMutationCount({required SocialFeedViewer viewer}) async =>
      0;

  @override
  Future<void> resetViewerData({required SocialFeedViewer viewer}) async {}
}
