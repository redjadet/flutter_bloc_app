import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_graph_projection.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('projectPointsForGraph', () {
    test('returns empty list when both inputs empty', () {
      expect(projectPointsForGraph([], []), isEmpty);
    });

    test('projects points A with isDatasetA true and isOutlier from point', () {
      const DispersionPoint p = DispersionPoint(
        id: '1',
        xMm: 10,
        yMm: 5,
        radialMm: 11.2,
        holeDiameterMm: 5,
        isOutlierAuto: false,
        isOutlierManual: true,
      );
      final list = projectPointsForGraph([p], []);
      expect(list.length, 1);
      expect(list[0].xMm, 10);
      expect(list[0].yMm, 5);
      expect(list[0].isDatasetA, true);
      expect(list[0].isOutlier, true);
    });

    test('projects points B with isDatasetA false', () {
      const DispersionPoint p = DispersionPoint(
        id: '2',
        xMm: -3,
        yMm: -4,
        radialMm: 5,
        holeDiameterMm: 5,
      );
      final list = projectPointsForGraph([], [p]);
      expect(list.length, 1);
      expect(list[0].xMm, -3);
      expect(list[0].yMm, -4);
      expect(list[0].isDatasetA, false);
      expect(list[0].isOutlier, false);
    });

    test('concatenates A then B', () {
      const DispersionPoint a = DispersionPoint(
        id: 'a',
        xMm: 1,
        yMm: 0,
        radialMm: 1,
        holeDiameterMm: 5,
      );
      const DispersionPoint b = DispersionPoint(
        id: 'b',
        xMm: 2,
        yMm: 0,
        radialMm: 2,
        holeDiameterMm: 5,
      );
      final list = projectPointsForGraph([a], [b]);
      expect(list.length, 2);
      expect(list[0].xMm, 1);
      expect(list[1].xMm, 2);
      expect(list[0].isDatasetA, true);
      expect(list[1].isDatasetA, false);
    });
  });
}
