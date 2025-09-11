import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CounterDisplay extends StatefulWidget {
  const CounterDisplay({super.key});

  @override
  State<CounterDisplay> createState() => _CounterDisplayState();
}

class _CounterDisplayState extends State<CounterDisplay> {
  int? _cycleTotalSeconds;

  static const Duration _animFast = Duration(milliseconds: 180);
  static const Duration _animMedium = Duration(milliseconds: 220);

  AppLocalizations _l10n(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsEn();

  String _formatLastChanged(BuildContext context, DateTime? dt) => dt == null
      ? '-'
      : DateFormat.yMd(Localizations.localeOf(context).languageCode)
          .add_jm()
          .format(dt);

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
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
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
          SizedBox(width: 6.w),
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
        style: textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: ((textTheme.displaySmall?.fontSize ?? 36)).spMax,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CounterCubit, CounterState>(
      builder: (context, state) {
        final ThemeData theme = Theme.of(context);
        final TextTheme textTheme = theme.textTheme;
        final ColorScheme colors = theme.colorScheme;
        final AppLocalizations l10n = _l10n(context);
        final String lastChangedText =
            _formatLastChanged(context, state.lastChanged);

        // Track per-cycle total for subtle background urgency cue
        _cycleTotalSeconds = (_cycleTotalSeconds == null)
            ? state.countdownSeconds
            : (_cycleTotalSeconds! < state.countdownSeconds
                ? state.countdownSeconds
                : _cycleTotalSeconds);
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
          duration: _animMedium,
          tween: ColorTween(end: targetCardColor),
          builder: (context, animatedColor, _) {
            final Color cardColor = animatedColor ?? targetCardColor;
            return Card(
              elevation: 0,
              color: cardColor,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _counterValue(textTheme, state.count),
                    SizedBox(height: 12.h),
                    _statusChip(
                      active: state.isAutoDecrementActive,
                      colors: colors,
                      textTheme: textTheme,
                      l10n: l10n,
                    ),
                    SizedBox(height: 12.h),
                    Divider(height: 1.h, color: colors.outlineVariant),
                    SizedBox(height: 12.h),
                    Text(
                      '${l10n.lastChangedLabel} $lastChangedText',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize:
                            (Theme.of(context).textTheme.bodySmall?.fontSize ??
                                    11)
                                .sp,
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
