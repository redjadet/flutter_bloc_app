import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_widgets.dart';
import 'package:flutter_bloc_app/shared/widgets/flavor_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});
  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with WidgetsBindingObserver {
  String _getLocalizedErrorMessage(AppLocalizations l10n, CounterError error) {
    switch (error.type) {
      case CounterErrorType.cannotGoBelowZero:
        return l10n.cannotGoBelowZero;
      case CounterErrorType.loadError || CounterErrorType.saveError:
        return l10n.loadErrorMessage;
      case CounterErrorType.unknown:
        return error.message ?? 'An unknown error occurred';
    }
  }

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    final CounterCubit cubit = context.read<CounterCubit>();
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        cubit.pauseAutoDecrement();
        break;
      case AppLifecycleState.resumed:
        cubit.resumeAutoDecrement();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocListener<CounterCubit, CounterState>(
      listenWhen: (prev, curr) => prev.error != curr.error,
      listener: (context, state) {
        final error = state.error;
        if (error != null) {
          final String localizedMessage = _getLocalizedErrorMessage(
            l10n,
            error,
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(localizedMessage)));
          context.read<CounterCubit>().clearError();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.inversePrimary,
          title: Text(
            widget.title,
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: l10n.openExampleTooltip,
              onPressed: () => context.pushNamed(AppRoutes.example),
              icon: const Icon(Icons.explore),
            ),
            IconButton(
              tooltip: l10n.openChartsTooltip,
              onPressed: () => context.pushNamed(AppRoutes.charts),
              icon: const Icon(Icons.show_chart),
            ),
            IconButton(
              tooltip: l10n.openGraphqlTooltip,
              onPressed: () => context.pushNamed(AppRoutes.graphql),
              icon: const Icon(Icons.public),
            ),
            IconButton(
              tooltip: l10n.openChatTooltip,
              onPressed: () => context.pushNamed(AppRoutes.chat),
              icon: const Icon(Icons.forum),
            ),
            IconButton(
              tooltip: l10n.openSettingsTooltip,
              onPressed: () => _handleOpenSettings(context),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: context.pagePadding,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                child: BlocSelector<CounterCubit, CounterState, CounterStatus>(
                  selector: (state) => state.status,
                  builder: (context, status) {
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
                            const Align(
                              alignment: Alignment.centerRight,
                              child: FlavorBadge(),
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
                          BlocBuilder<CounterCubit, CounterState>(
                            buildWhen: (p, c) => p.count != c.count,
                            builder: (context, state) {
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

  Future<void> _handleOpenSettings(BuildContext context) async {
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.settingsBiometricFailed)));
    }
  }
}
