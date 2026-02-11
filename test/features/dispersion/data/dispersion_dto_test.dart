import 'package:flutter_bloc_app/features/dispersion/data/dispersion_dto.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dispersionPointToMap / dispersionPointFromMap', () {
    test('round-trip preserves isOutlierAuto and isOutlierManual', () {
      const DispersionPoint point = DispersionPoint(
        id: 'pt-1',
        xMm: 1.0,
        yMm: 2.0,
        radialMm: 2.24,
        holeDiameterMm: 5.0,
        isOutlierAuto: true,
        isOutlierManual: true,
      );
      final Map<String, dynamic> map = dispersionPointToMap(point);
      final DispersionPoint? restored = dispersionPointFromMap(map);
      expect(restored, isNotNull);
      expect(restored!.id, point.id);
      expect(restored.isOutlierAuto, true);
      expect(restored.isOutlierManual, true);
      expect(restored.isOutlier, true);
    });

    test('round-trip with manual-only outlier', () {
      const DispersionPoint point = DispersionPoint(
        id: 'pt-2',
        xMm: 0,
        yMm: 0,
        radialMm: 0,
        holeDiameterMm: 5.0,
        isOutlierAuto: false,
        isOutlierManual: true,
      );
      final Map<String, dynamic> map = dispersionPointToMap(point);
      final DispersionPoint? restored = dispersionPointFromMap(map);
      expect(restored, isNotNull);
      expect(restored!.isOutlierManual, true);
      expect(restored.isOutlierAuto, false);
      expect(restored.isOutlier, true);
    });
  });
}
