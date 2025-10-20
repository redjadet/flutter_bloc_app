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

  @override
  void initState() {
    super.initState();
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
    final AppLocalizations l10n = AppLocalizations.of(context);
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
                child: BlocSelector<CounterCubit, CounterState, CounterStatus>(
                  selector: (final state) => state.status,
                  builder: (final context, final status) {
                    final bool isLoading = status == CounterStatus.loading;
                    final bool showFlavor =
                        FlavorManager.I.flavor != Flavor.prod;
                    return Skeletonizer(
                      enabled: isLoading,
                      effect: ShimmerEffect(
                        baseColor: theme.colorScheme.surfaceContainerHighest,
                        highlightColor: theme.colorScheme.surface,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (showFlavor) ...[
                            const Padding(
                              padding: EdgeInsets.all(1),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FlavorBadge(),
                              ),
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
                          BlocBuilder<CounterCubit, CounterState>(
                            buildWhen: (final p, final c) => p.count != c.count,
                            builder: (final context, final state) {
                              if (state.count == 0) {
                                return Text(
                                  l10n.startAutoHint,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    );
                  },
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
    final AppLocalizations l10n = AppLocalizations.of(context);
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
