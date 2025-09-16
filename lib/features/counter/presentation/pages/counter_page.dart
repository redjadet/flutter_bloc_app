import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/presentation/theme_cubit.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_widgets.dart';
import 'package:flutter_bloc_app/shared/widgets/flavor_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key, required this.title});
  final String title;

  String _getLocalizedErrorMessage(BuildContext context, CounterError error) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    switch (error.type) {
      case CounterErrorType.cannotGoBelowZero:
        return l10n.cannotGoBelowZero;
      case CounterErrorType.loadError:
        return l10n.loadErrorMessage;
      case CounterErrorType.saveError:
        return l10n.loadErrorMessage; // Reuse same message for now
      case CounterErrorType.unknown:
        return error.message ?? 'An unknown error occurred';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CounterCubit, CounterState>(
      listenWhen: (prev, curr) => prev.error != curr.error,
      listener: (context, state) {
        final error = state.error;
        if (error != null) {
          final String localizedMessage = _getLocalizedErrorMessage(
            context,
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: AppLocalizations.of(context).openExampleTooltip,
              onPressed: () => context.pushNamed(AppRoutes.example),
              icon: const Icon(Icons.explore),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).openChartsTooltip,
              onPressed: () => context.pushNamed(AppRoutes.charts),
              icon: const Icon(Icons.show_chart),
            ),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) {
                final bool isDark = mode == ThemeMode.dark;
                return IconButton(
                  tooltip: isDark ? 'Light mode' : 'Dark mode',
                  onPressed: () => context.read<ThemeCubit>().toggle(),
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                );
              },
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
                    final ThemeData theme = Theme.of(context);
                    final bool showFlavor = FlavorManager.I.flavor != Flavor.prod;
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
                            AppLocalizations.of(context).pushCountLabel,
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
                                  AppLocalizations.of(context).startAutoHint,
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
}
