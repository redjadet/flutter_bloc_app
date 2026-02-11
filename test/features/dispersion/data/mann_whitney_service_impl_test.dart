import 'package:flutter_bloc_app/features/dispersion/data/mann_whitney_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MannWhitneyServiceImpl service;

  setUp(() {
    service = MannWhitneyServiceImpl();
  });

  group('MannWhitneyServiceImpl', () {
    test('returns high p-value when samples are similar', () {
      final sampleA = <double>[1.0, 2.0, 3.0, 4.0, 5.0];
      final sampleB = <double>[1.5, 2.5, 3.5, 4.5, 5.5];
      final result = service.runTest(
        sampleA: sampleA,
        sampleB: sampleB,
        alpha: 0.05,
      );
      expect(result.nA, 5);
      expect(result.nB, 5);
      expect(result.pValueTwoSided, greaterThan(0.1));
      expect(result.isSignificant, false);
    });

    test('returns low p-value when one group is clearly larger', () {
      final sampleA = <double>[1.0, 2.0, 3.0, 4.0, 5.0];
      final sampleB = <double>[50.0, 51.0, 52.0, 53.0, 54.0];
      final result = service.runTest(
        sampleA: sampleA,
        sampleB: sampleB,
        alpha: 0.05,
      );
      expect(result.nA, 5);
      expect(result.nB, 5);
      expect(result.pValueTwoSided, lessThan(0.05));
      expect(result.isSignificant, true);
    });

    test('handles ties with average ranks', () {
      final sampleA = <double>[1.0, 1.0, 2.0];
      final sampleB = <double>[1.0, 2.0, 2.0];
      final result = service.runTest(
        sampleA: sampleA,
        sampleB: sampleB,
        alpha: 0.05,
      );
      expect(result.nA, 3);
      expect(result.nB, 3);
      expect(result.uStatistic, greaterThanOrEqualTo(0));
      expect(result.pValueTwoSided, greaterThanOrEqualTo(0));
      expect(result.pValueTwoSided, lessThanOrEqualTo(1));
    });

    test('empty sample A returns safe default', () {
      final result = service.runTest(
        sampleA: <double>[],
        sampleB: <double>[1.0, 2.0, 3.0],
        alpha: 0.05,
      );
      expect(result.nA, 0);
      expect(result.nB, 3);
      expect(result.pValueTwoSided, 1);
      expect(result.isSignificant, false);
      expect(result.smallSampleCaution, true);
    });

    test('small sample sets smallSampleCaution', () {
      final result = service.runTest(
        sampleA: <double>[1.0, 2.0, 3.0, 4.0, 5.0],
        sampleB: <double>[2.0, 3.0, 4.0, 5.0, 6.0],
        alpha: 0.05,
      );
      expect(result.smallSampleCaution, true);
    });
  });
}
