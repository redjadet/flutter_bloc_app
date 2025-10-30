import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/counter/counter.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/widgets/awesome_feature_widget.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({required this.title, super.key});
  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with WidgetsBindingObserver {
  final ErrorNotificationService _errorNotificationService =
      getIt<ErrorNotificationService>();
  late final bool _showFlavorBadge;

  @override
  void initState() {
    super.initState();
    _showFlavorBadge = FlavorManager.I.flavor != Flavor.prod;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (!mounted) return;
    final CounterCubit cubit = context.read<CounterCubit>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        cubit.pauseAutoDecrement();
      case AppLifecycleState.resumed:
        cubit.resumeAutoDecrement();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) => prev.error != curr.error,
          listener: (final context, final state) {
            final error = state.error;
            if (error != null) {
              final String localizedMessage = counterErrorMessage(l10n, error);
              ErrorHandling.handleCubitError(
                context,
                error,
                customMessage: localizedMessage,
                onRetry: () =>
                    CubitHelpers.safeExecute<CounterCubit, CounterState>(
                      context,
                      (final cubit) => cubit.clearError(),
                    ),
              );
            }
          },
        ),
        BlocListener<CounterCubit, CounterState>(
          listenWhen: (final prev, final curr) =>
              prev.count == 0 && curr.count > 0,
          listener: (final context, final state) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ],
      child: Scaffold(
        appBar: CounterPageAppBar(
          title: widget.title,
          onOpenSettings: () => _handleOpenSettings(context),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                child: _CounterSkeletonizedBody(
                  theme: theme,
                  l10n: l10n,
                  showFlavorBadge: _showFlavorBadge,
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CountdownBar(),
        floatingActionButton: const CounterActions(),
      ),
    );
  }

  Future<void> _handleOpenSettings(final BuildContext context) async {
    final l10n = context.l10n;
    final BiometricAuthenticator authenticator =
        getIt<BiometricAuthenticator>();
    final bool authenticated = await authenticator.authenticate(
      localizedReason: l10n.settingsBiometricPrompt,
    );
    if (!context.mounted) return;
    if (authenticated) {
      await context.pushNamed(AppRoutes.settings);
    } else {
      unawaited(
        _errorNotificationService.showSnackBar(
          context,
          l10n.settingsBiometricFailed,
        ),
      );
    }
  }
}

class _CounterSkeletonizedBody extends StatelessWidget {
  const _CounterSkeletonizedBody({
    required this.theme,
    required this.l10n,
    required this.showFlavorBadge,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final bool showFlavorBadge;

  @override
  Widget build(final BuildContext context) =>
      BlocSelector<CounterCubit, CounterState, bool>(
        selector: (final state) => state.status.isLoading,
        builder: (final context, final isLoading) => Skeletonizer(
          enabled: isLoading,
          effect: ShimmerEffect(
            baseColor: theme.colorScheme.surfaceContainerHighest,
            highlightColor: theme.colorScheme.surface,
          ),
          child: _CounterContent(
            theme: theme,
            l10n: l10n,
            showFlavorBadge: showFlavorBadge,
          ),
        ),
      );
}

class _CounterContent extends StatelessWidget {
  const _CounterContent({
    required this.theme,
    required this.l10n,
    required this.showFlavorBadge,
  });

  final ThemeData theme;
  final AppLocalizations l10n;
  final bool showFlavorBadge;

  @override
  Widget build(final BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      if (showFlavorBadge) ...[
        const Padding(
          padding: EdgeInsets.all(1),
          child: Align(alignment: Alignment.centerRight, child: FlavorBadge()),
        ),
        SizedBox(height: UI.gapS),
      ],
      Text(
        l10n.pushCountLabel,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: UI.gapS),
      const CounterDisplay(),
      SizedBox(height: UI.gapM),
      const AwesomeFeatureWidget(),
      SizedBox(height: UI.gapM),
      BlocSelector<CounterCubit, CounterState, bool>(
        selector: (final state) => state.count == 0,
        builder: (final context, final showHint) {
          if (!showHint) {
            return const SizedBox.shrink();
          }
          return Text(
            l10n.startAutoHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    ],
  );
}
