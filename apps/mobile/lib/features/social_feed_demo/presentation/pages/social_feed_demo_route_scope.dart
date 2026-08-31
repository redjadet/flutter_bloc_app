import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/pages/social_feed_demo_page.dart';

/// Route-scoped owner for [SocialFeedCubit].
///
/// go_router 18 may rebuild route pages while navigator pages transition.
/// Stateful ownership keeps one cubit per route visit and avoids disposing
/// the provider mid-transition.
class SocialFeedDemoRouteScope extends StatefulWidget {
  const SocialFeedDemoRouteScope({
    required this.repository,
    required this.realtimeSource,
    required this.scenario,
    required this.clock,
    super.key,
  });

  final SocialFeedRepository repository;
  final SocialFeedRealtimeSource realtimeSource;
  final SocialFeedScenarioController scenario;
  final DateTime Function() clock;

  @override
  State<SocialFeedDemoRouteScope> createState() =>
      _SocialFeedDemoRouteScopeState();
}

class _SocialFeedDemoRouteScopeState extends State<SocialFeedDemoRouteScope> {
  late final SocialFeedCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SocialFeedCubit(
      repository: widget.repository,
      realtimeSource: widget.realtimeSource,
      scenario: widget.scenario,
      clock: widget.clock,
    );
    unawaited(_cubit.initialize());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SocialFeedCubit>.value(
      value: _cubit,
      child: const SocialFeedDemoPage(),
    );
  }
}
