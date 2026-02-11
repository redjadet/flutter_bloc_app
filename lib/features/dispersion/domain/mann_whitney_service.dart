import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';

/// Contract for Mann-Whitney U-test on two samples of radial distances (mm).
/// Pure Dart; no Flutter imports.
abstract class MannWhitneyService {
  /// Runs a two-sided Mann-Whitney U-test on [sampleA] and [sampleB].
  /// [alpha] is the significance level (e.g. 0.05).
  /// Returns U statistic, z-score, two-sided p-value, significance, effect size,
  /// and smallSampleCaution when nA or nB < 20.
  DispersionComparisonResult runTest({
    required final List<double> sampleA,
    required final List<double> sampleB,
    required final double alpha,
    final String datasetAId = '',
    final String datasetBId = '',
  });
}
