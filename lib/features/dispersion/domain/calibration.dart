import 'dart:math' as math;

import 'package:meta/meta.dart';

/// Calibration data: two pixel endpoints and the known real length in mm.
/// Scale factor = knownLengthMm / pixelDistance(endpoint1, endpoint2).
@immutable
class Calibration {
  const Calibration({
    required this.endpoint1Px,
    required this.endpoint2Px,
    required this.knownLengthMm,
  });

  final PixelPoint endpoint1Px;
  final PixelPoint endpoint2Px;
  final double knownLengthMm;

  /// Pixel distance between the two calibration endpoints.
  double get pixelDistance => _distance(endpoint1Px, endpoint2Px);

  /// Scale factor: mm per pixel. Multiply pixel offset by this to get mm.
  double get scaleFactorMmPerPx =>
      pixelDistance > 0 ? knownLengthMm / pixelDistance : 0;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is Calibration &&
          endpoint1Px == other.endpoint1Px &&
          endpoint2Px == other.endpoint2Px &&
          knownLengthMm == other.knownLengthMm;

  @override
  int get hashCode => Object.hash(endpoint1Px, endpoint2Px, knownLengthMm);

  static double _distance(final PixelPoint a, final PixelPoint b) {
    final double dx = b.x - a.x;
    final double dy = b.y - a.y;
    final double v = dx * dx + dy * dy;
    if (v <= 0) {
      return 0;
    }
    return math.sqrt(v);
  }
}

/// A point in pixel coordinates (Flutter-agnostic).
@immutable
class PixelPoint {
  const PixelPoint({required this.x, required this.y});

  final double x;
  final double y;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is PixelPoint && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
