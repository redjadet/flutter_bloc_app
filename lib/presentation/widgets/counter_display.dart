import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';

class CounterDisplay extends StatefulWidget {
  const CounterDisplay({super.key});

  @override
  State<CounterDisplay> createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  int? _cycleTotalSeconds;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        final String lastChangedText = state.lastChanged != null
            ? DateFormat.yMd(
                Localizations.localeOf(context).languageCode,
              ).add_jm().format(state.lastChanged!)
            : '-';
        final AppLocalizations l10n =
            Localizations.of<AppLocalizations>(context, AppLocalizations) ??
            AppLocalizationsEn();
        final ColorScheme colors = Theme.of(context).colorScheme;

        // Track per-cycle total for subtle background urgency cue
        if (_cycleTotalSeconds == null ||
            state.countdownSeconds > (_cycleTotalSeconds ?? 0)) {
          _cycleTotalSeconds = state.countdownSeconds;
        }
        final int total = _cycleTotalSeconds ?? 5;
        final double progress = (state.countdownSeconds / total).clamp(
          0.0,
          1.0,
        );

        final Color targetCardColor = state.isAutoDecrementActive
            ? Color.lerp(
                    colors.errorContainer.withValues(alpha: 0.08),
                    colors.surfaceContainerHighest,
                    progress,
                  ) ??
                  colors.surfaceContainerHighest
            : colors.surfaceContainerHighest;

        return TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 220),
          tween: ColorTween(end: targetCardColor),
          builder: (context, animatedColor, _) {
            final Color cardColor = animatedColor ?? targetCardColor;
            return Card(
              elevation: 0,
              color: cardColor,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.9,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                      child: Text(
                        '${state.count}',
                        key: ValueKey<int>(state.count),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: state.isAutoDecrementActive
                                ? colors.primary.withValues(alpha: 0.12)
                                : colors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: Icon(
                                  state.isAutoDecrementActive
                                      ? Icons.timer
                                      : Icons.pause_circle_filled,
                                  key: ValueKey<bool>(
                                    state.isAutoDecrementActive,
                                  ),
                                  size: 16,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: Text(
                                  state.isAutoDecrementActive
                                      ? l10n.autoLabel
                                      : l10n.pausedLabel,
                                  key: ValueKey<bool>(
                                    state.isAutoDecrementActive,
                                  ),
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(color: colors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: colors.outlineVariant),
                    const SizedBox(height: 12),
                    Text(
                      '${l10n.lastChangedLabel} $lastChangedText',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
