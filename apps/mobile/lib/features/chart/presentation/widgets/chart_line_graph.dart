import 'package:design_system/responsive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chart/domain/chart_point.dart';
import 'package:intl/intl.dart';

part 'chart_line_graph_chart_data.part.dart';

class ChartLineGraph extends StatefulWidget {
  const ChartLineGraph({
    required this.points,
    required this.dateFormat,
    required this.zoomEnabled,
    super.key,
  });

  final List<ChartPoint> points;
  final DateFormat dateFormat;
  final bool zoomEnabled;

  @override
  State<ChartLineGraph> createState() => _ChartLineGraphState();
}

class _ChartLineGraphState extends State<ChartLineGraph> {
  late List<FlSpot> _spots;
  late List<String> _bottomLabels;
  late final TransformationController _transformationController;
  _ChartRenderKey? _renderKey;
  LineChartData? _cachedZoomEnabledData;
  LineChartData? _cachedZoomDisabledData;
  static const int _maxBottomLabels = 7;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _recomputeCaches();
  }

  @override
  void didUpdateWidget(final ChartLineGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points ||
        oldWidget.dateFormat != widget.dateFormat) {
      _recomputeCaches();
      _invalidateChartDataCache();
    }
    if (oldWidget.zoomEnabled && !widget.zoomEnabled) {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _recomputeCaches() {
    final List<ChartPoint> points = widget.points;
    _spots = List<FlSpot>.generate(
      points.length,
      (final i) => FlSpot(i.toDouble(), points[i].value),
      growable: false,
    );
    _bottomLabels = List<String>.generate(
      points.length,
      (final i) => widget.dateFormat.format(points[i].date),
      growable: false,
    );
  }

  void _invalidateChartDataCache() {
    _renderKey = null;
    _cachedZoomEnabledData = null;
    _cachedZoomDisabledData = null;
  }

  @override
  Widget build(final BuildContext context) {
    final chart = LineChart(
      _getOrBuildChartData(
        context,
        zoomEnabled: widget.zoomEnabled,
      ),
    );

    return InteractiveViewer(
      panEnabled: widget.zoomEnabled,
      scaleEnabled: widget.zoomEnabled,
      maxScale: 6,
      boundaryMargin: context.allGapL,
      transformationController: _transformationController,
      child: chart,
    );
  }
}
