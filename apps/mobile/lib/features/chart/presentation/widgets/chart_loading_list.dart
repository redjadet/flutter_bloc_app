import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:material_ui/material_ui.dart';

class ChartLoadingList extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;
    final chartHeight = context.heightFraction(0.28);
    return SkeletonBase(
      semanticLabel: 'Loading chart',
      child: ChartScrollable(
        children: [
          CommonCard(
            color: skeletonColor,
            elevation: 0,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: SizedBox(height: chartHeight),
          ),
          SizedBox(height: context.responsiveGapL),
          CommonCard(
            color: skeletonColor,
            elevation: 0,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: const SizedBox(height: 48),
          ),
        ],
      ),
    );
  }
}
