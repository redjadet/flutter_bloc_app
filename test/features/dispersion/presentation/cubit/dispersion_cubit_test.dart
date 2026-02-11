import 'package:flutter_bloc_app/features/dispersion/data/image_import_service.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_repository.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDispersionRepository extends Mock implements DispersionRepository {}

class MockImageImportService extends Mock implements ImageImportService {}

void main() {
  late MockDispersionRepository repository;
  late MockImageImportService imageImport;

  setUp(() {
    repository = MockDispersionRepository();
    imageImport = MockImageImportService();
  });

  DispersionCubit buildCubit() =>
      DispersionCubit(repository: repository, imageImportService: imageImport);

  group('DispersionCubit point editor flow', () {
    test(
      'addCreatePoint adds one point when calibration and hole diameter set',
      () {
        final cubit = buildCubit();
        cubit.setCreateCalibrationFromNumbers(0, 0, 100, 0, 50);
        cubit.setCreateAimFromNumbers(50, 50);
        cubit.setCreateHoleDiameterMm(5);
        cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
        expect(cubit.state.createPoints.length, 1);
        expect(cubit.state.createPoints.first.xMm, 10);
        expect(cubit.state.createPoints.first.yMm, 0);
        expect(cubit.state.createPoints.first.radialMm, 10);
      },
    );

    test(
      'removeCreatePoint removes point and clears selection if selected',
      () {
        final cubit = buildCubit();
        cubit.setCreateCalibrationFromNumbers(0, 0, 100, 0, 50);
        cubit.setCreateAimFromNumbers(50, 50);
        cubit.setCreateHoleDiameterMm(5);
        cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
        final id = cubit.state.createPoints.first.id;
        cubit.setCreateSelectedPoint(id);
        cubit.removeCreatePoint(id);
        expect(cubit.state.createPoints, isEmpty);
        expect(cubit.state.createSelectedPointId, isNull);
      },
    );

    test('setCreateSelectedPoint updates selected id', () {
      final cubit = buildCubit();
      cubit.setCreateCalibrationFromNumbers(0, 0, 100, 0, 50);
      cubit.setCreateAimFromNumbers(50, 50);
      cubit.setCreateHoleDiameterMm(5);
      cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
      final id = cubit.state.createPoints.first.id;
      cubit.setCreateSelectedPoint(id);
      expect(cubit.state.createSelectedPointId, id);
    });

    test('addCreatePoint does nothing when calibration missing', () {
      final cubit = buildCubit();
      cubit.setCreateAimFromNumbers(50, 50);
      cubit.setCreateHoleDiameterMm(5);
      cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
      expect(cubit.state.createPoints, isEmpty);
    });

    test('addCreatePoint does nothing when hole diameter not set', () {
      final cubit = buildCubit();
      cubit.setCreateCalibrationFromNumbers(0, 0, 100, 0, 50);
      cubit.setCreateAimFromNumbers(50, 50);
      cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
      expect(cubit.state.createPoints, isEmpty);
    });
  });

  group('DispersionCubit createDerivedDataset', () {
    test('does nothing when name is empty', () async {
      final cubit = buildCubit();
      cubit.setScreen(DispersionScreen.combineDatasets);
      await cubit.createDerivedDataset('', ['id1', 'id2']);
      expect(cubit.state.screen, DispersionScreen.combineDatasets);
      verifyNever(
        () => repository.createDerivedDataset(
          name: any(named: 'name'),
          sourceDatasetIds: any(named: 'sourceDatasetIds'),
        ),
      );
    });

    test('does nothing when fewer than 2 source ids', () async {
      final cubit = buildCubit();
      cubit.setScreen(DispersionScreen.combineDatasets);
      await cubit.createDerivedDataset('Combined', ['id1']);
      expect(cubit.state.screen, DispersionScreen.combineDatasets);
      verifyNever(
        () => repository.createDerivedDataset(
          name: any(named: 'name'),
          sourceDatasetIds: any(named: 'sourceDatasetIds'),
        ),
      );
    });

    test('calls repository and navigates to home on success', () async {
      final derived = DispersionDataset(
        id: 'derived-1',
        name: 'Combined',
        groupIds: [],
        createdAt: DateTime(2025, 1, 1),
        isDerived: true,
        sourceDatasetIds: ['a', 'b'],
        pointCount: 10,
      );
      when(
        () => repository.createDerivedDataset(
          name: any(named: 'name'),
          sourceDatasetIds: any(named: 'sourceDatasetIds'),
        ),
      ).thenAnswer((_) async => derived);
      final cubit = buildCubit();
      cubit.setScreen(DispersionScreen.combineDatasets);
      await cubit.createDerivedDataset('Combined', ['a', 'b']);
      expect(cubit.state.screen, DispersionScreen.home);
      expect(cubit.state.errorMessage, isNull);
      verify(
        () => repository.createDerivedDataset(
          name: 'Combined',
          sourceDatasetIds: ['a', 'b'],
        ),
      ).called(1);
    });
  });

  group('DispersionCubit manual outlier toggle', () {
    test('setCreatePointOutlierManual sets isOutlierManual for point', () {
      final cubit = buildCubit();
      cubit.setCreateCalibrationFromNumbers(0, 0, 100, 0, 50);
      cubit.setCreateAimFromNumbers(50, 50);
      cubit.setCreateHoleDiameterMm(5);
      cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
      final String pointId = cubit.state.createPoints.first.id;
      expect(cubit.state.createPoints.first.isOutlierManual, false);
      cubit.setCreatePointOutlierManual(pointId, value: true);
      expect(cubit.state.createPoints.first.isOutlierManual, true);
      cubit.setCreatePointOutlierManual(pointId, value: false);
      expect(cubit.state.createPoints.first.isOutlierManual, false);
    });

    test('setCreatePointOutlierManual no-op when pointId not found', () {
      final cubit = buildCubit();
      cubit.setCreateCalibrationFromNumbers(0, 0, 100, 0, 50);
      cubit.setCreateAimFromNumbers(50, 50);
      cubit.setCreateHoleDiameterMm(5);
      cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
      final List<DispersionPoint> before = cubit.state.createPoints;
      cubit.setCreatePointOutlierManual('nonexistent', value: true);
      expect(cubit.state.createPoints, equals(before));
    });
  });
}
