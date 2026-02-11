import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';

/// IQR-based outlier detection: values above Q3 + 1.5*IQR or below Q1 - 1.5*IQR.
/// Returns a list of indices (into [values]) that are outliers.
List<int> iqrOutlierIndices(final List<double> values) {
  if (values.length < 4) {
    return <int>[];
  }
  final List<double> sorted = List<double>.from(values)..sort();
  final double q1 = _quantile(sorted, 0.25);
  final double q3 = _quantile(sorted, 0.75);
  final double iqr = q3 - q1;
  if (iqr <= 0) {
    return <int>[];
  }
  final double lower = q1 - 1.5 * iqr;
  final double upper = q3 + 1.5 * iqr;
  final List<int> indices = <int>[];
  for (int i = 0; i < values.length; i++) {
    if (values[i] < lower || values[i] > upper) {
      indices.add(i);
    }
  }
  return indices;
}

/// Returns a new list of points with [DispersionPoint.isOutlierAuto] set from IQR.
List<DispersionPoint> applyIqrOutlierFlags(
  final List<DispersionPoint> points,
) {
  if (points.length < 4) {
    return points;
  }
  final List<double> radials = points.map((final p) => p.radialMm).toList();
  final List<int> outlierIndices = iqrOutlierIndices(radials);
  final Set<int> outlierSet = outlierIndices.toSet();
  return <DispersionPoint>[
    for (int i = 0; i < points.length; i++)
      points[i].copyWith(isOutlierAuto: outlierSet.contains(i)),
  ];
}

double _quantile(final List<double> sorted, final double p) {
  if (sorted.isEmpty) {
    return 0;
  }
  final double index = p * (sorted.length - 1);
  final int i = index.floor().clamp(0, sorted.length - 1);
  final int j = (i + 1).clamp(0, sorted.length - 1);
  final double t = index - i;
  return sorted[i] * (1 - t) + sorted[j] * t;
}
