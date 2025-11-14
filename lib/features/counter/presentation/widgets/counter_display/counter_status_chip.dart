import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CounterStatusChip extends StatelessWidget {
  const CounterStatusChip({
    required this.active,
    required this.colors,
    required this.textTheme,
    required this.l10n,
    required this.animDuration,
    super.key,
  });

  final bool active;
  final ColorScheme colors;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final Duration animDuration;

  @override
  Widget build(final BuildContext context) {
    final double fontSize = (textTheme.labelMedium?.fontSize ?? 12).spMax;
    return AnimatedContainer(
      duration: animDuration,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: active ? colors.primary.withValues(alpha: 0.12) : colors.surface,
        borderRadius: BorderRadius.circular(context.responsiveCardRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalGapM,
        vertical: context.responsiveGapXS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: animDuration,
            transitionBuilder: (final child, final animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Icon(
              active ? Icons.timer : Icons.pause_circle_filled,
              key: ValueKey<bool>(active),
              size: 18,
              color: colors.primary,
            ),
          ),
          SizedBox(width: context.responsiveGapXS),
          Flexible(
            child: AnimatedSwitcher(
              duration: animDuration,
              transitionBuilder: (final child, final animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                active ? l10n.autoLabel : l10n.pausedLabel,
                key: ValueKey<bool>(active),
                style: textTheme.labelMedium?.copyWith(
                  color: colors.primary,
                  fontSize: fontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
