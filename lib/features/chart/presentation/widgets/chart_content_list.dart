import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/presentation/cubit/chart_cubit.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_line_graph.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:intl/intl.dart';

class ChartContentList extends StatelessWidget {
  const ChartContentList({
    required this.l10n,
    required this.points,
    required this.dateFormat,
    super.key,
  });

  final AppLocalizations l10n;
  final List<ChartPoint> points;
  final DateFormat dateFormat;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final chartHeight = context.heightFraction(0.45);
    return ChartScrollable(
      children: [
        Text(l10n.chartPageDescription, style: theme.textTheme.titleMedium),
        SizedBox(height: context.responsiveGapL),
        TypeSafeBlocSelector<ChartCubit, ChartState, bool>(
          selector: (final state) => state.zoomEnabled,
          builder: (final context, final zoomEnabled) =>
              SwitchListTile.adaptive(
                value: zoomEnabled,
                onChanged: (final value) => context
                    .cubit<ChartCubit>()
                    .setZoomEnabled(isEnabled: value),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.chartZoomToggleLabel),
              ),
        ),
        SizedBox(height: context.responsiveGapS),
        SizedBox(
          height: chartHeight,
          child: RepaintBoundary(
            child: TypeSafeBlocSelector<ChartCubit, ChartState, bool>(
              selector: (final state) => state.zoomEnabled,
              builder: (final context, final zoomEnabled) => ChartLineGraph(
                points: points,
                dateFormat: dateFormat,
                zoomEnabled: zoomEnabled,
              ),
            ),
          ),
        ),
        SizedBox(height: context.responsiveGapL),
      ],
    );
  }
}
