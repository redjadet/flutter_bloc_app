import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChartLoadingList extends StatelessWidget {
  const ChartLoadingList({super.key});

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;
    final chartHeight = context.heightFraction(0.28);
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: theme.colorScheme.surfaceContainerHigh,
        highlightColor: theme.colorScheme.surface,
      ),
      child: ChartScrollable(
        children: [
          Container(
            height: chartHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UI.radiusM),
              color: skeletonColor,
            ),
          ),
          SizedBox(height: UI.gapL),
          Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(UI.radiusM),
              color: skeletonColor,
            ),
          ),
        ],
      ),
    );
  }
}
