import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_demo_body.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_scenario_controls.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('page body shows list after ready state', (
    WidgetTester tester,
  ) async {
    final _PageCubit cubit = _PageCubit();
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

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<SocialFeedCubit>.value(
          value: cubit,
          child: const Scaffold(body: SocialFeedDemoBody()),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('social-feed-list')), findsOneWidget);
    final ListView feed = tester.widget<ListView>(
      find.byKey(const ValueKey('social-feed-list')),
    );
    expect(feed.childrenDelegate, isA<SliverChildBuilderDelegate>());
    expect(find.byKey(const ValueKey('social-feed-post-p1')), findsOneWidget);
  });

  testWidgets(
    'scenario sheet without BlocProvider.value throws ProviderNotFound',
    (WidgetTester tester) async {
      final _PageCubit cubit = _PageCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<SocialFeedCubit>.value(
            value: cubit,
            child: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () {
                      // Deliberate anti-pattern: overlay drops page providers.
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (sheetContext) =>
                            const SocialFeedScenarioControls(),
                      );
                    },
                    child: const Text('open-bad'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-bad'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isA<ProviderNotFoundException>());
    },
  );

  testWidgets(
    'scenario sheet reuses page SocialFeedCubit via BlocProvider.value',
    (WidgetTester tester) async {
      final _PageCubit cubit = _PageCubit();
      addTearDown(cubit.close);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<SocialFeedCubit>.value(
            value: cubit,
            child: Builder(
              builder: (BuildContext context) {
                return Scaffold(
                  body: TextButton(
                    onPressed: () {
                      // Mirrors social_feed_demo_page scenario sheet wiring.
                      final SocialFeedCubit pageCubit = context
                          .read<SocialFeedCubit>();
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (sheetContext) =>
                            BlocProvider<SocialFeedCubit>.value(
                              value: pageCubit,
                              child: const SocialFeedScenarioControls(),
                            ),
                      );
                    },
                    child: const Text('open-good'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-good'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const ValueKey('social-feed-scenario-controls')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

class _PageCubit extends SocialFeedCubit {
  _PageCubit()
    : super(
        repository: _NoRepo(),
        realtimeSource: _NoRealtime(),
        scenario: _NoScenario(),
        clock: () => DateTime.utc(2026, 8, 20),
      );

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
}

class _NoScenario implements SocialFeedScenarioController {
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

class _NoRealtime implements SocialFeedRealtimeSource {
  @override
  Future<SocialFeedRealtimeLease> acquire(SocialFeedViewer viewer) async =>
      throw UnimplementedError();

  @override
  void flushPendingPosts(SocialFeedViewer viewer) {}
}

class _NoRepo implements SocialFeedRepository {
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
  Future<Map<String, List<SocialFeedComment>>> commentsForPostIds({
    required Iterable<String> postIds,
  }) async => <String, List<SocialFeedComment>>{};

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
  Future<SocialFeedPendingSnapshot> readPendingSnapshot({
    required SocialFeedViewer viewer,
  }) async => const SocialFeedPendingSnapshot(
    pendingCommentsByPostId: <String, List<SocialFeedComment>>{},
    pendingPostIds: <String>{},
  );

  @override
  Future<void> resetViewerData({required SocialFeedViewer viewer}) async {}
}
