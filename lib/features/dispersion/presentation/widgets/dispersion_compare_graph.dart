import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_graph_point.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_graph_projection.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

/// Plots dataset A and B points in a common mm-from-aim coordinate system.
/// Outliers are shown with distinct styling but remain visible.
class DispersionCompareGraph extends StatelessWidget {
  const DispersionCompareGraph({
    required this.pointsA,
    required this.pointsB,
    this.labelA = 'A',
    this.labelB = 'B',
    super.key,
  });

  final List<DispersionPoint> pointsA;
  final List<DispersionPoint> pointsB;
  final String labelA;
  final String labelB;

  @override
  Widget build(final BuildContext context) {
    final List<DispersionGraphPoint> points = projectPointsForGraph(pointsA, pointsB);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final l10n = context.l10n;
    final Color colorA = colors.primary;
    final Color colorB = colors.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 200,
          child: points.isEmpty
              ? Center(
                  child: Text(
                    l10n.dispersionGraphNoPoints,
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : LayoutBuilder(
                  builder: (final context, final constraints) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _DispersionGraphPainter(
                        points: points,
                        colorA: colorA,
                        colorB: colorB,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _LegendDot(color: colorA, filled: true),
            const SizedBox(width: 4),
            Text(labelA, style: theme.textTheme.labelSmall),
            const SizedBox(width: 16),
            _LegendDot(color: colorB, filled: true),
            const SizedBox(width: 4),
            Text(labelB, style: theme.textTheme.labelSmall),
            const SizedBox(width: 16),
            _LegendDot(color: colors.outline, filled: false),
            const SizedBox(width: 4),
            Text(l10n.dispersionGraphOutlier, style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _DispersionGraphPainter extends CustomPainter {
  _DispersionGraphPainter({
    required this.points,
    required this.colorA,
    required this.colorB,
  });

  final List<DispersionGraphPoint> points;
  final Color colorA;
  final Color colorB;

  @override
  void paint(final Canvas canvas, final Size size) {
    if (points.isEmpty) return;
    const double padding = 24;
    final double w = size.width - 2 * padding;
    final double h = size.height - 2 * padding;
    if (w <= 0 || h <= 0) return;

    double maxAbs = 0;
    for (final DispersionGraphPoint p in points) {
      final double m = p.xMm.abs() > p.yMm.abs() ? p.xMm.abs() : p.yMm.abs();
      if (m > maxAbs) maxAbs = m;
    }
    if (maxAbs < 1) maxAbs = 1;
    final double scale = (w < h ? w : h) / (2 * maxAbs);
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    final Paint aimPaint = Paint()
      ..color = colorA.withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), 4, aimPaint);

    for (final DispersionGraphPoint p in points) {
      final double dx = p.xMm * scale;
      final double dy = -p.yMm * scale;
      final Offset pos = Offset(cx + dx, cy + dy);
      final Color color = p.isDatasetA ? colorA : colorB;
      if (p.isOutlier) {
        final Paint stroke = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(pos, 6, stroke);
      } else {
        final Paint fill = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 5, fill);
      }
    }
  }

  @override
  bool shouldRepaint(final _DispersionGraphPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.colorA != colorA || oldDelegate.colorB != colorB;
}
