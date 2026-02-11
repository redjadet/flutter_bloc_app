import 'package:meta/meta.dart';

/// A point in the dispersion compare graph: coordinates in mm from aim,
/// which dataset it belongs to, and whether it is an outlier (for styling).
@immutable
class DispersionGraphPoint {
  const DispersionGraphPoint({
    required this.xMm,
    required this.yMm,
    required this.isDatasetA,
    required this.isOutlier,
  });

  final double xMm;
  final double yMm;
  final bool isDatasetA;
  final bool isOutlier;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is DispersionGraphPoint &&
          xMm == other.xMm &&
          yMm == other.yMm &&
          isDatasetA == other.isDatasetA &&
          isOutlier == other.isOutlier;

  @override
  int get hashCode => Object.hash(xMm, yMm, isDatasetA, isOutlier);
}
