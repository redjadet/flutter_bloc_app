import 'package:flutter_bloc_app/features/dispersion/domain/outlier_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iqrOutlierIndices', () {
    test('returns empty for fewer than 4 values', () {
      expect(iqrOutlierIndices(<double>[1, 2, 3]), isEmpty);
    });

    test('identifies high outlier', () {
      final values = <double>[1.0, 2.0, 3.0, 4.0, 5.0, 100.0];
      final indices = iqrOutlierIndices(values);
      expect(indices, contains(5));
    });

    test('identifies low outlier', () {
      final values = <double>[-100.0, 1.0, 2.0, 3.0, 4.0, 5.0];
      final indices = iqrOutlierIndices(values);
      expect(indices, contains(0));
    });

    test('returns empty when no outliers', () {
      final values = <double>[2.0, 3.0, 4.0, 5.0, 6.0];
      final indices = iqrOutlierIndices(values);
      expect(indices, isEmpty);
    });
  });
}
