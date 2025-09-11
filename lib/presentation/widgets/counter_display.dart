import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc_app/presentation/ui_constants.dart';

class CounterDisplay extends StatefulWidget {
  const CounterDisplay({super.key});

  @override
  State<CounterDisplay> createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  int? _cycleTotalSeconds;

  static const Duration _animFast = UI.animFast;
  static const Duration _animMedium = UI.animMedium;

  AppLocalizations _l10n(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsEn();

  String _formatLastChanged(BuildContext context, DateTime? dt) => dt == null
      ? '-'
      : DateFormat.yMd(
          Localizations.localeOf(context).languageCode,
        ).add_jm().format(dt);

  Widget _statusChip({
    required bool active,
    required ColorScheme colors,
    required TextTheme textTheme,
    required AppLocalizations l10n,
  }) {
    return AnimatedContainer(
      duration: _animMedium,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: active ? colors.primary.withValues(alpha: 0.12) : colors.surface,
        borderRadius: BorderRadius.circular(UI.radiusM),
      ),
      padding: EdgeInsets.symmetric(horizontal: UI.hgapM, vertical: UI.gapXS),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: _animFast,
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: Icon(
              active ? Icons.timer : Icons.pause_circle_filled,
              key: ValueKey<bool>(active),
              size: 16.spMax,
              color: colors.primary,
            ),
          ),
          SizedBox(width: UI.hgapXS),
          AnimatedSwitcher(
            duration: _animFast,
            transitionBuilder: (c, a) => FadeTransition(opacity: a, child: c),
            child: Text(
              active ? l10n.autoLabel : l10n.pausedLabel,
              key: ValueKey<bool>(active),
              style: textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontSize: (textTheme.labelMedium?.fontSize ?? 12).spMax,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterValue(TextTheme textTheme, int count) {
    return AnimatedSwitcher(
      duration: _animMedium,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
        child: child,
      ),
      child: Text(
        '$count',
        key: ValueKey<int>(count),
        semanticsLabel: 'count $count',
        style: textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: ((textTheme.displaySmall?.fontSize ?? 36)).spMax,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = _l10n(context);

    return BlocSelector<CounterCubit, CounterState, (bool, int)>(
      selector: (s) => (s.isAutoDecrementActive, s.countdownSeconds),
      builder: (context, tuple) {
        final bool isActive = tuple.$1;
        final int seconds = tuple.$2;

        // Edge-case reset: when auto-decrement is inactive, restart cycle window
        if (!isActive) {
          _cycleTotalSeconds = seconds;
        } else {
          _cycleTotalSeconds = (_cycleTotalSeconds == null)
              ? seconds
              : (_cycleTotalSeconds! < seconds ? seconds : _cycleTotalSeconds);
        }
        final int total = _cycleTotalSeconds ?? 5;
        final double progress = (seconds / total).clamp(0.0, 1.0);

        final Color targetCardColor = isActive
            ? (Color.lerp(
                    colors.errorContainer.withValues(alpha: 0.08),
                    colors.surfaceContainerHighest,
                    progress,
                  ) ??
                  colors.surfaceContainerHighest)
            : colors.surfaceContainerHighest;

        return TweenAnimationBuilder<Color?>(
          duration: _animMedium,
          tween: ColorTween(end: targetCardColor),
          builder: (context, animatedColor, _) {
            final Color cardColor = animatedColor ?? targetCardColor;
            return Card(
              elevation: 0,
              color: cardColor,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UI.radiusM),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: UI.cardPadH,
                  vertical: UI.cardPadV,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Only rebuilds when count changes
                    BlocSelector<CounterCubit, CounterState, int>(
                      selector: (s) => s.count,
                      builder: (context, count) =>
                          _counterValue(textTheme, count),
                    ),
                    SizedBox(height: UI.gapM),
                    // Only rebuilds when active flag changes
                    BlocSelector<CounterCubit, CounterState, bool>(
                      selector: (s) => s.isAutoDecrementActive,
                      builder: (context, active) => _statusChip(
                        active: active,
                        colors: colors,
                        textTheme: textTheme,
                        l10n: l10n,
                      ),
                    ),
                    SizedBox(height: UI.gapM),
                    Divider(
                      height: UI.dividerThin,
                      color: colors.outlineVariant,
                    ),
                    SizedBox(height: UI.gapM),
                    // Only rebuilds when lastChanged changes
                    BlocSelector<CounterCubit, CounterState, DateTime?>(
                      selector: (s) => s.lastChanged,
                      builder: (context, dt) => Text(
                        '${l10n.lastChangedLabel} ${_formatLastChanged(context, dt)}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: (textTheme.bodySmall?.fontSize ?? 11).sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
