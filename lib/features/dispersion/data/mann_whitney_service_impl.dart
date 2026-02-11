import 'dart:math' as math;

import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/mann_whitney_service.dart';

/// Pure Dart implementation of the Mann-Whitney U-test (two-sided).
/// Uses asymptotic normal approximation with continuity correction.
class MannWhitneyServiceImpl implements MannWhitneyService {
  @override
  DispersionComparisonResult runTest({
    required final List<double> sampleA,
    required final List<double> sampleB,
    required final double alpha,
    final String datasetAId = '',
    final String datasetBId = '',
  }) {
    final int nA = sampleA.length;
    final int nB = sampleB.length;
    if (nA == 0 || nB == 0) {
      return DispersionComparisonResult(
        datasetAId: datasetAId,
        datasetBId: datasetBId,
        nA: nA,
        nB: nB,
        uStatistic: 0,
        zScore: 0,
        pValueTwoSided: 1,
        alpha: alpha,
        isSignificant: false,
        effectSizeRankBiserial: 0,
        smallSampleCaution: true,
      );
    }

    final int n = nA + nB;
    final List<_RankedValue> pooled = <_RankedValue>[
      ...sampleA.map((final v) => _RankedValue(v, isA: true)),
      ...sampleB.map((final v) => _RankedValue(v, isA: false)),
    ]..sort((final a, final b) => a.value.compareTo(b.value));

    _assignRanks(pooled);

    double r1 = 0;
    for (int i = 0; i < pooled.length; i++) {
      if (pooled[i].isA) {
        r1 += pooled[i].rank;
      }
    }

    final double u1 = nA * nB + (nA * (nA + 1)) / 2 - r1;
    final double u2 = nA * nB - u1;
    final double u = math.min(u1, u2);

    final double mu = (nA * nB) / 2;
    final double tieCorrection = _tieCorrection(pooled);
    final double tieDenominator = n > 1 ? (n * (n - 1)).toDouble() : 1;
    final double tieTerm = tieCorrection / tieDenominator;
    final double varianceFactor = (n + 1) - tieTerm;
    final double variance =
        (nA * nB / 12) * varianceFactor.clamp(0.0, double.infinity);
    final double sigma = variance > 0 ? _sqrt(variance) : 0;

    double zAbs = 0;
    double zSigned = 0;
    if (sigma > 0) {
      final double diff = u - mu;
      zAbs = (diff.abs() - 0.5).clamp(0.0, double.infinity) / sigma;
      zSigned = diff / sigma;
      if (diff > 0) {
        zSigned -= 0.5 / sigma;
      } else {
        zSigned += 0.5 / sigma;
      }
    }

    final double pValueTwoSided = 2 * (1 - _normalCdf(zAbs));
    final bool isSignificant = pValueTwoSided <= alpha;
    final double effectSizeRankBiserial = (nA * nB) > 0
        ? 1 - (2 * u) / (nA * nB)
        : 0;
    final bool smallSampleCaution = nA < 20 || nB < 20;

    return DispersionComparisonResult(
      datasetAId: datasetAId,
      datasetBId: datasetBId,
      nA: nA,
      nB: nB,
      uStatistic: u,
      zScore: zSigned,
      pValueTwoSided: pValueTwoSided,
      alpha: alpha,
      isSignificant: isSignificant,
      effectSizeRankBiserial: effectSizeRankBiserial,
      smallSampleCaution: smallSampleCaution,
    );
  }

  static void _assignRanks(final List<_RankedValue> pooled) {
    int i = 0;
    while (i < pooled.length) {
      int j = i;
      while (j < pooled.length && pooled[j].value == pooled[i].value) {
        j++;
      }
      final int tieCount = j - i;
      final double avgRank = i + (tieCount + 1) / 2.0;
      for (int k = i; k < j; k++) {
        pooled[k].rank = avgRank;
      }
      i = j;
    }
  }

  static double _tieCorrection(final List<_RankedValue> pooled) {
    int i = 0;
    double sum = 0;
    while (i < pooled.length) {
      int j = i;
      while (j < pooled.length && pooled[j].value == pooled[i].value) {
        j++;
      }
      final int t = j - i;
      if (t > 1) {
        sum += (t * t * t - t).toDouble();
      }
      i = j;
    }
    return sum;
  }

  static double _sqrt(final double v) {
    if (v <= 0) return 0;
    return math.sqrt(v);
  }

  static const double _sqrt2Pi = 2.5066282746310002;

  static double _normalCdf(final double z) {
    if (z <= -8) return 0;
    if (z >= 8) return 1;
    if (z < 0) return 1 - _normalCdf(-z);
    final double t = 1 / (1 + 0.2316419 * z);
    final double pdf = math.exp(-0.5 * z * z) / _sqrt2Pi;
    final double poly =
        t *
        (0.3193815 +
            t *
                (-0.3565638 +
                    t * (1.7814779 + t * (-1.8212559 + t * 1.3302744))));
    return 1 - pdf * poly;
  }
}

class _RankedValue {
  _RankedValue(this.value, {required this.isA});

  final double value;
  final bool isA;
  double rank = 0;
}
