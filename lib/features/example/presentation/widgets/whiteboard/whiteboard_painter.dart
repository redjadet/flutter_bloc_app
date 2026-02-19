import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'whiteboard_painter.freezed.dart';

/// Custom painter for drawing strokes on a whiteboard canvas.
///
/// This painter handles:
/// - Multiple stroke paths with different colors and widths
/// - Smooth stroke rendering with anti-aliasing
/// - Efficient repainting of only changed areas
class WhiteboardPainter extends CustomPainter {
  WhiteboardPainter({
    required this.strokes,
    this.backgroundColor,
  });

  /// List of stroke data to render.
  final List<WhiteboardStroke> strokes;

  /// Background color of the canvas.
  final Color? backgroundColor;

  @override
  void paint(final Canvas canvas, final Size size) {
    // Draw background
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = backgroundColor!,
      );
    }

    // Draw all strokes
    for (final WhiteboardStroke stroke in strokes) {
      if (stroke.points.length < 2) {
        continue;
      }

      final Paint paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final Path path = Path()
        ..moveTo(stroke.points[0].dx, stroke.points[0].dy);

      for (int i = 1; i < stroke.points.length; i++) {
        final Offset current = stroke.points[i];
        final Offset previous = stroke.points[i - 1];

        // Use quadratic bezier for smooth curves
        if (i == 1) {
          path.lineTo(current.dx, current.dy);
        } else {
          final Offset midPoint = Offset(
            (previous.dx + current.dx) / 2,
            (previous.dy + current.dy) / 2,
          );
          path.quadraticBezierTo(
            previous.dx,
            previous.dy,
            midPoint.dx,
            midPoint.dy,
          );
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(final WhiteboardPainter oldDelegate) =>
      !listEquals(oldDelegate.strokes, strokes) ||
      oldDelegate.backgroundColor != backgroundColor;
}

/// Represents a single stroke on the whiteboard.
@freezed
abstract class WhiteboardStroke with _$WhiteboardStroke {
  factory WhiteboardStroke({
    required final List<Offset> points,
    required final Color color,
    required final double width,
  }) => WhiteboardStroke.raw(
    points: List<Offset>.unmodifiable(points),
    color: color,
    width: width,
  );

  const factory WhiteboardStroke.raw({
    required final List<Offset> points,
    required final Color color,
    required final double width,
  }) = _WhiteboardStroke;
}
