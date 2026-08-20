import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment_policy.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';

// Keep ctor param names (`repository`, …) for `super.` forwarding from
// SocialFeedCubit; initializing formals would force private names.
// ignore_for_file: prefer_initializing_formals

part 'social_feed_cubit_load.part.dart';
part 'social_feed_cubit_mutations.part.dart';
part 'social_feed_cubit_leases.part.dart';
part 'social_feed_cubit_helpers.part.dart';
part 'social_feed_cubit_paging.part.dart';

class SocialFeedCubit extends _SocialFeedCubitBase
    with
        _SocialFeedCubitHelpers,
        _SocialFeedCubitLoad,
        _SocialFeedCubitMutations,
        _SocialFeedCubitLeases,
        _SocialFeedCubitPaging {
  SocialFeedCubit({
    required super.repository,
    required super.realtimeSource,
    required super.scenario,
    required super.clock,
    super.commentPolicy,
    super.initialViewer,
  });

  Future<void> initialize() => load();

  @override
  Future<void> close() async {
    ++_generation;
    await _closeLeases();
    return super.close();
  }
}

class _SocialFeedCubitBase extends Cubit<SocialFeedState>
    with CubitSubscriptionMixin<SocialFeedState> {
  _SocialFeedCubitBase({
    required SocialFeedRepository repository,
    required SocialFeedRealtimeSource realtimeSource,
    required SocialFeedScenarioController scenario,
    required DateTime Function() clock,
    SocialFeedCommentPolicy commentPolicy = const SocialFeedCommentPolicy(),
    SocialFeedViewer initialViewer = SocialFeedViewer.alex,
  }) : _repository = repository,
       _realtimeSource = realtimeSource,
       _scenario = scenario,
       _clock = clock,
       _commentPolicy = commentPolicy,
       super(SocialFeedState.initial(initialViewer));

  final SocialFeedRepository _repository;
  final SocialFeedRealtimeSource _realtimeSource;
  final SocialFeedScenarioController _scenario;
  final DateTime Function() _clock;
  final SocialFeedCommentPolicy _commentPolicy;

  int _generation = 0;
  SocialFeedSyncLease? _syncLease;
  SocialFeedRealtimeLease? _realtimeLease;
  // ignore: cancel_subscriptions - Managed via CubitSubscriptionMixin.
  StreamSubscription<SocialFeedSyncSummary>? _syncSub;
  // ignore: cancel_subscriptions - Managed via CubitSubscriptionMixin.
  StreamSubscription<SocialFeedPost>? _realtimePostsSub;
  // ignore: cancel_subscriptions - Managed via CubitSubscriptionMixin.
  StreamSubscription<SocialFeedConnectionStatus>? _realtimeStatusSub;
  bool _loadMoreInFlight = false;

  SocialFeedViewer get viewer => switch (state) {
    SocialFeedInitial(:final viewer) => viewer,
    SocialFeedLoading(:final viewer) => viewer,
    SocialFeedFailureState(:final viewer) => viewer,
    SocialFeedReady(:final data) => data.viewer,
  };

  SocialFeedScenarioController get scenarioController => _scenario;

  void emitThreeNewPosts() {
    _scenario.emitThreeNewPosts(viewer: viewer);
    _realtimeSource.flushPendingPosts(viewer);
  }

  Future<void> retryNeedsAttention(String mutationId) async {
    await _repository.retryNeedsAttention(
      viewer: viewer,
      mutationId: mutationId,
    );
  }
}
