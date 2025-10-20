import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/countdown_bar/countdown_status.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CountdownBarContent extends StatelessWidget {
  const CountdownBarContent({
    super.key,
    required this.active,
    required this.isLoading,
    required this.progress,
    required this.countdownSeconds,
    required this.targetColor,
    required this.colors,
    required this.l10n,
    required this.animFast,
  });

  final bool active;
  final bool isLoading;
  final double progress;
  final int countdownSeconds;
  final Color targetColor;
  final ColorScheme colors;
  final AppLocalizations l10n;
  final Duration animFast;

  @override
  Widget build(final BuildContext context) {
    final Widget bar = SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          UI.horizontalGapL,
          0,
          UI.horizontalGapL,
          UI.gapM,
        ),
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(UI.radiusM),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: UI.horizontalGapL,
              vertical: UI.gapM,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<Color?>(
                  duration: UI.animMedium,
                  tween: ColorTween(end: targetColor),
                  builder: (final context, final animatedColor, _) {
                    final Color c = animatedColor ?? targetColor;
                    return CountdownStatus(
                      active: active,
                      color: c,
                      label: active
                          ? l10n.nextAutoDecrementIn(countdownSeconds)
                          : l10n.autoDecrementPaused,
                      animDuration: animFast,
                    );
                  },
                ),
                SizedBox(height: UI.gapS),
                TweenAnimationBuilder<Color?>(
                  duration: UI.animMedium,
                  tween: ColorTween(end: targetColor),
                  builder: (final context, final animatedColor, _) {
                    final Color barColor = animatedColor ?? targetColor;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(UI.radiusPill),
                      child: LinearProgressIndicator(
                        value: active ? progress : 0,
                        minHeight: UI.progressHeight,
                        backgroundColor: colors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!isLoading) {
      return bar;
    }

    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: colors.surfaceContainerHighest,
        highlightColor: colors.surface,
      ),
      child: bar,
    );
  }
}
