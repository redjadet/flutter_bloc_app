part of 'chart_line_graph.dart';

extension _ChartLineGraphStateChartData on _ChartLineGraphState {
  LineChartData _getOrBuildChartData(
    final BuildContext context, {
    required final bool zoomEnabled,
  }) {
    final theme = Theme.of(context);

    final renderKey = _ChartRenderKey(
      primaryColor: theme.colorScheme.primary,
      onSurface: theme.colorScheme.onSurface,
      reservedSize: context.responsiveGapL * 3,
      titleSpace: context.responsiveGapS,
      simplifyChart: _spots.length >= 160,
      labelEvery:
          (_bottomLabels.length <= _ChartLineGraphState._maxBottomLabels)
          ? 1
          : (_bottomLabels.length / _ChartLineGraphState._maxBottomLabels)
                .ceil(),
      spotCount: _spots.length,
      labelCount: _bottomLabels.length,
    );

    if (_renderKey != renderKey) {
      _renderKey = renderKey;
      _cachedZoomEnabledData = null;
      _cachedZoomDisabledData = null;
    }

    final existing = zoomEnabled
        ? _cachedZoomEnabledData
        : _cachedZoomDisabledData;
    if (existing != null) {
      return existing;
    }

    final tooltipTextStyle =
        theme.textTheme.bodyMedium?.copyWith(
          color: renderKey.onSurface,
          fontWeight: FontWeight.w600,
        ) ??
        TextStyle(
          color: renderKey.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        );

    final lineTouchData = zoomEnabled
        ? const LineTouchData(enabled: false)
        : LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (final touchedSpots) => touchedSpots
                  .map<LineTooltipItem?>(
                    (final spot) => LineTooltipItem(
                      spot.y.toStringAsFixed(3),
                      tooltipTextStyle,
                    ),
                  )
                  .toList(),
            ),
          );

    final data = LineChartData(
      lineTouchData: lineTouchData,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: renderKey.reservedSize,
            getTitlesWidget: (final value, final meta) {
              final index = value.toInt();
              Widget child = const SizedBox.shrink();
              if (index >= 0 &&
                  index < _bottomLabels.length &&
                  (renderKey.labelEvery <= 1 ||
                      index % renderKey.labelEvery == 0)) {
                child = Text(_bottomLabels[index]);
              }
              return SideTitleWidget(
                meta: meta,
                space: renderKey.titleSpace,
                child: child,
              );
            },
          ),
        ),
        leftTitles: const AxisTitles(),
      ),
      borderData: FlBorderData(),
      lineBarsData: [
        LineChartBarData(
          spots: _spots,
          isCurved: !renderKey.simplifyChart,
          color: renderKey.primaryColor,
          belowBarData: BarAreaData(
            show: !renderKey.simplifyChart,
            color: renderKey.primaryColor.withValues(alpha: 0.15),
          ),
        ),
      ],
    );

    if (zoomEnabled) {
      _cachedZoomEnabledData = data;
    } else {
      _cachedZoomDisabledData = data;
    }
    return data;
  }
}

@immutable
class _ChartRenderKey {
  const _ChartRenderKey({
    required this.primaryColor,
    required this.onSurface,
    required this.reservedSize,
    required this.titleSpace,
    required this.simplifyChart,
    required this.labelEvery,
    required this.spotCount,
    required this.labelCount,
  });

  final Color primaryColor;
  final Color onSurface;
  final double reservedSize;
  final double titleSpace;
  final bool simplifyChart;
  final int labelEvery;
  final int spotCount;
  final int labelCount;

  @override
  bool operator ==(final Object other) =>
      other is _ChartRenderKey &&
      other.primaryColor == primaryColor &&
      other.onSurface == onSurface &&
      other.reservedSize == reservedSize &&
      other.titleSpace == titleSpace &&
      other.simplifyChart == simplifyChart &&
      other.labelEvery == labelEvery &&
      other.spotCount == spotCount &&
      other.labelCount == labelCount;

  @override
  int get hashCode => Object.hash(
    primaryColor,
    onSurface,
    reservedSize,
    titleSpace,
    simplifyChart,
    labelEvery,
    spotCount,
    labelCount,
  );
}
