import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_line_graph.dart';
import 'package:flutter_bloc_app/features/chart/presentation/widgets/chart_scrollable.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:intl/intl.dart';

class ChartContentList extends StatelessWidget {
  const ChartContentList({
    super.key,
    required this.l10n,
    required this.points,
    required this.dateFormat,
    required this.zoomEnabled,
    required this.onZoomChanged,
  });

  final AppLocalizations l10n;
  final List<ChartPoint> points;
  final DateFormat dateFormat;
  final bool zoomEnabled;
  final ValueChanged<bool> onZoomChanged;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final chartHeight = MediaQuery.of(context).size.height * 0.45;
    return ChartScrollable(
      children: [
        Text(l10n.chartPageDescription, style: theme.textTheme.titleMedium),
        SizedBox(height: UI.gapL),
        SwitchListTile.adaptive(
          value: zoomEnabled,
          onChanged: onZoomChanged,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.chartZoomToggleLabel),
        ),
        SizedBox(height: UI.gapS),
        SizedBox(
          height: chartHeight,
          child: ChartLineGraph(
            points: points,
            dateFormat: dateFormat,
            zoomEnabled: zoomEnabled,
          ),
        ),
        SizedBox(height: UI.gapL),
      ],
    );
  }
}
