import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_graph_point.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';

/// Projects dataset A and B points into a single list of graph points
/// in a common coordinate system (mm from aim). All points are kept;
/// [DispersionPoint.isOutlier] is used for styling only (outliers remain
/// visible when exclude-outliers is on).
List<DispersionGraphPoint> projectPointsForGraph(
  final List<DispersionPoint> pointsA,
  final List<DispersionPoint> pointsB,
) {
  final List<DispersionGraphPoint> out = <DispersionGraphPoint>[];
  for (final DispersionPoint p in pointsA) {
    out.add(DispersionGraphPoint(
      xMm: p.xMm,
      yMm: p.yMm,
      isDatasetA: true,
      isOutlier: p.isOutlier,
    ));
  }
  for (final DispersionPoint p in pointsB) {
    out.add(DispersionGraphPoint(
      xMm: p.xMm,
      yMm: p.yMm,
      isDatasetA: false,
      isOutlier: p.isOutlier,
    ));
  }
  return out;
}
