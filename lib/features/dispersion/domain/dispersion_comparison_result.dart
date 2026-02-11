import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispersion_comparison_result.freezed.dart';

/// Result of comparing two datasets with the Mann-Whitney U-test.
@freezed
abstract class DispersionComparisonResult with _$DispersionComparisonResult {
  const factory DispersionComparisonResult({
    required final String datasetAId,
    required final String datasetBId,
    required final int nA,
    required final int nB,
    required final double uStatistic,
    required final double zScore,
    required final double pValueTwoSided,
    required final double alpha,
    required final bool isSignificant,
    required final double effectSizeRankBiserial,
    @Default(0) final int excludedOutliersCount,
    @Default(false) final bool smallSampleCaution,
  }) = _DispersionComparisonResult;

  const DispersionComparisonResult._();
}
