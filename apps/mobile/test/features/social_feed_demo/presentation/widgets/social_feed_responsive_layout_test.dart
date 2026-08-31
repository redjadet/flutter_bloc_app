import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_demo_body.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_scenario_controls.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<SocialFeedCubit> readyCubit() async {
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: _Repo(),
      realtimeSource: _Realtime(),
      scenario: _Scenario(),
      clock: () => DateTime.utc(2026, 8, 20),
    );
    await cubit.load();
    return cubit;
  }

  Future<void> pumpBody(
    WidgetTester tester, {
    required SocialFeedCubit cubit,
    required Size size,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider<SocialFeedCubit>.value(
            value: cubit,
            child: const Scaffold(body: SocialFeedDemoBody()),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('compact width hides senior signal side panel', (
    WidgetTester tester,
  ) async {
    final SocialFeedCubit cubit = await readyCubit();
    addTearDown(cubit.close);
    await pumpBody(tester, cubit: cubit, size: const Size(390, 800));

    expect(find.byKey(const ValueKey('social-feed-list')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('social-feed-senior-signal-panel')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('social-feed-scenario-controls')),
      findsNothing,
    );
  });

  testWidgets('wide width shows senior signal side panel', (
    WidgetTester tester,
  ) async {
    final SocialFeedCubit cubit = await readyCubit();
    addTearDown(cubit.close);
    await pumpBody(tester, cubit: cubit, size: const Size(1280, 900));

    expect(
      find.byKey(const ValueKey('social-feed-senior-signal-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('social-feed-scenario-controls')),
      findsOneWidget,
    );
  });

  testWidgets('scenario-sheet switch updates without reopening the sheet', (
    WidgetTester tester,
  ) async {
    final SocialFeedCubit cubit = await readyCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<SocialFeedCubit>.value(
          value: cubit,
          child: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () {
                  unawaited(
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (_) => BlocProvider<SocialFeedCubit>.value(
                        value: cubit,
                        child: const SocialFeedScenarioControls(),
                      ),
                    ),
                  );
                },
                child: const Text('Open scenario controls'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open scenario controls'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.byType(SocialFeedScenarioControls), findsOneWidget);
  });
}

class _Scenario implements SocialFeedScenarioController {
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

class _SyncLease implements SocialFeedSyncLease {
  final StreamController<SocialFeedSyncSummary> c =
      StreamController<SocialFeedSyncSummary>.broadcast();

  @override
  Stream<SocialFeedSyncSummary> get summaries => c.stream;

  @override
  SocialFeedSyncSummary? get seedSummary => null;

  @override
  Future<void> close() async {
    if (!c.isClosed) {
      await c.close();
    }
  }
}

class _RtLease implements SocialFeedRealtimeLease {
  final StreamController<SocialFeedConnectionStatus> status =
      StreamController<SocialFeedConnectionStatus>.broadcast();
  final StreamController<SocialFeedPost> postsController =
      StreamController<SocialFeedPost>.broadcast();

  @override
  Stream<SocialFeedConnectionStatus> get connectionStatus => status.stream;

  @override
  Stream<SocialFeedPost> get posts => postsController.stream;

  @override
  Future<void> close() async {
    if (!status.isClosed) {
      await status.close();
    }
    if (!postsController.isClosed) {
      await postsController.close();
    }
  }
}

class _Realtime implements SocialFeedRealtimeSource {
  @override
  Future<SocialFeedRealtimeLease> acquire(SocialFeedViewer viewer) async =>
      _RtLease();

  @override
  void flushPendingPosts(SocialFeedViewer viewer) {}
}

class _Repo implements SocialFeedRepository {
  @override
  Future<SocialFeedPage?> readCachedPage({
    required SocialFeedViewer viewer,
  }) async => null;

  @override
  Future<SocialFeedPage> refresh({required SocialFeedViewer viewer}) async =>
      SocialFeedPage(
        posts: <SocialFeedPost>[
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
        ],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      );

  @override
  Future<SocialFeedPage> loadMore({
    required SocialFeedViewer viewer,
    required String cursor,
  }) async => refresh(viewer: viewer);

  @override
  Future<SocialFeedLikeResult> setLiked({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  }) async => SocialFeedLikeSynced((await refresh(viewer: viewer)).posts.first);

  @override
  Future<SocialFeedCommentResult> addComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  }) async => SocialFeedCommentSynced(
    post: (await refresh(viewer: viewer)).posts.first,
    mutationId: mutationId,
  );

  @override
  Future<Map<String, List<SocialFeedComment>>> commentsForPostIds({
    required Iterable<String> postIds,
  }) async => <String, List<SocialFeedComment>>{};

  @override
  Future<SocialFeedSyncLease> acquireSync({
    required SocialFeedViewer viewer,
  }) async => _SyncLease();

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
