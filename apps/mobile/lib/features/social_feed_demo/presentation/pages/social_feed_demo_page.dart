import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_demo_body.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_scenario_controls.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SocialFeedDemoPage extends StatefulWidget {
  const SocialFeedDemoPage({super.key});

  @override
  State<SocialFeedDemoPage> createState() => _SocialFeedDemoPageState();
}

class _SocialFeedDemoPageState extends State<SocialFeedDemoPage> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Callback body lives outside initState so provider reads stay lifecycle-safe.
    _lifecycleListener = AppLifecycleListener(onStateChange: _onLifecycle);
  }

  void _onLifecycle(AppLifecycleState state) {
    if (!mounted) {
      return;
    }
    context.read<SocialFeedCubit>().onAppLifecycle(state);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return CommonPageLayout(
      useResponsiveBody: false,
      title: l10n.socialFeedDemoTitle,
      actions: <Widget>[
        Material(
          type: MaterialType.transparency,
          child: IconButton(
            key: const ValueKey('social-feed-refresh-button'),
            tooltip: l10n.socialFeedDemoRetry,
            onPressed: () {
              // check-ignore: side_effects_build - user gesture callback.
              unawaited(context.read<SocialFeedCubit>().refresh());
            },
            icon: const Icon(Icons.refresh),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: IconButton(
            key: const ValueKey('social-feed-scenario-button'),
            tooltip: l10n.socialFeedDemoScenarioTitle,
            onPressed: () {
              final SocialFeedCubit cubit = context.read<SocialFeedCubit>();
              // check-ignore: side_effects_build - user gesture callback.
              unawaited(
                showModalBottomSheet<void>(
                  context: context,
                  builder: (sheetContext) =>
                      BlocProvider<SocialFeedCubit>.value(
                        value: cubit,
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: SocialFeedScenarioControls(),
                        ),
                      ),
                ),
              );
            },
            icon: const Icon(Icons.tune),
          ),
        ),
        BlocBuilder<SocialFeedCubit, SocialFeedState>(
          buildWhen: (a, b) => _viewerOf(a).id != _viewerOf(b).id,
          builder: (context, state) {
            return Material(
              type: MaterialType.transparency,
              child: PopupMenuButton<SocialFeedViewer>(
                key: const ValueKey('social-feed-viewer-menu'),
                onSelected: context.read<SocialFeedCubit>().switchViewer,
                itemBuilder: (context) => <PopupMenuEntry<SocialFeedViewer>>[
                  for (final SocialFeedViewer viewer
                      in SocialFeedViewer.demoViewers)
                    PopupMenuItem<SocialFeedViewer>(
                      value: viewer,
                      child: Text(viewer.displayName),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(_viewerOf(state).displayName),
                ),
              ),
            );
          },
        ),
      ],
      body: const SocialFeedDemoBody(),
    );
  }
}

SocialFeedViewer _viewerOf(SocialFeedState state) => switch (state) {
  SocialFeedInitial(:final viewer) => viewer,
  SocialFeedLoading(:final viewer) => viewer,
  SocialFeedFailureState(:final viewer) => viewer,
  SocialFeedReady(:final data) => data.viewer,
};
