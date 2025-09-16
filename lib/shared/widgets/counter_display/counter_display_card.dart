import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_display/counter_last_changed_text.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_display/counter_status_chip.dart';
import 'package:flutter_bloc_app/shared/widgets/counter_display/counter_value_text.dart';

class CounterDisplayCard extends StatelessWidget {
  const CounterDisplayCard({
    super.key,
    required this.count,
    required this.isActive,
    required this.lastChanged,
    required this.cardColor,
    required this.colors,
    required this.textTheme,
    required this.l10n,
    required this.animFast,
    required this.animMedium,
  });

  final int count;
  final bool isActive;
  final DateTime? lastChanged;
  final Color cardColor;
  final ColorScheme colors;
  final TextTheme textTheme;
  final AppLocalizations l10n;
  final Duration animFast;
  final Duration animMedium;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      duration: animMedium,
      tween: ColorTween(end: cardColor),
      builder: (context, animatedColor, _) {
        final Color resolvedColor = animatedColor ?? cardColor;
        return Card(
          elevation: 0,
          color: resolvedColor,
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
                CounterValueText(
                  count: count,
                  textTheme: textTheme,
                  animDuration: animMedium,
                ),
                SizedBox(height: UI.gapM),
                CounterStatusChip(
                  active: isActive,
                  colors: colors,
                  textTheme: textTheme,
                  l10n: l10n,
                  animDuration: animFast,
                ),
                SizedBox(height: UI.gapM),
                Divider(height: UI.dividerThin, color: colors.outlineVariant),
                SizedBox(height: UI.gapM),
                CounterLastChangedText(
                  lastChanged: lastChanged,
                  l10n: l10n,
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
