import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/dispersion/data/image_import_service.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_repository.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_create_group_body.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DispersionCreateGroupBody', () {
    Widget buildSubject({
      required final DispersionCubit cubit,
      final String? imagePath,
      final Calibration? calibration,
      final double aimPx = 0,
      final double aimPy = 0,
      final List<DispersionPoint> createPoints = const [],
      final String? createSelectedPointId,
    }) {
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<DispersionCubit>.value(
            value: cubit,
            child: DispersionCreateGroupBody(
              imagePath: imagePath,
              knownLengthMm: 50,
              distanceMeters: 25,
              groupName: null,
              holeDiameterMm: 5,
              pointsCount: createPoints.length,
              hasCalibration: calibration != null,
              hasAimPoint: true,
              calibration: calibration,
              aimPx: aimPx,
              aimPy: aimPy,
              createPoints: createPoints,
              createSelectedPointId: createSelectedPointId,
            ),
          ),
        ),
      );
    }

    testWidgets('shows points count', (final WidgetTester tester) async {
      final cubit = DispersionCubit(
        repository: _FakeRepository(),
        imageImportService: _FakeImageImport(),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(buildSubject(cubit: cubit));
      await tester.pumpAndSettle();
      expect(find.text('points: 0'), findsOneWidget);
    });

    testWidgets(
      'shows Delete selected when a point is selected and image present',
      (final WidgetTester tester) async {
        final pngBytes = base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQzwAEhQGAghkxdQAAAABJRU5ErkJggg==',
        );
        final tempFile = File(
          '${Directory.systemTemp.path}/dispersion_test_1x1_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        tempFile.writeAsBytesSync(pngBytes);
        addTearDown(() => tempFile.deleteSync());

        final cubit = DispersionCubit(
          repository: _FakeRepository(),
          imageImportService: _FakeImageImport(),
        );
        addTearDown(cubit.close);
        cubit.setCreateCalibrationFromNumbers(0, 0, 100, 0, 50);
        cubit.setCreateAimFromNumbers(50, 50);
        cubit.setCreateHoleDiameterMm(5);
        cubit.addCreatePoint(const PixelPoint(x: 20, y: 0));
        final pointId = cubit.state.createPoints.first.id;
        cubit.setCreateSelectedPoint(pointId);
        const calibration = Calibration(
          endpoint1Px: PixelPoint(x: 0, y: 0),
          endpoint2Px: PixelPoint(x: 100, y: 0),
          knownLengthMm: 50,
        );
        await tester.pumpWidget(
          buildSubject(
            cubit: cubit,
            imagePath: tempFile.path,
            calibration: calibration,
            aimPx: 50,
            aimPy: 50,
            createPoints: cubit.state.createPoints,
            createSelectedPointId: pointId,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Delete selected'), findsOneWidget);
      },
    );

    testWidgets('shows point list with outlier toggle when points exist',
        (final WidgetTester tester) async {
      final cubit = DispersionCubit(
        repository: _FakeRepository(),
        imageImportService: _FakeImageImport(),
      );
      addTearDown(cubit.close);
      const calibration = Calibration(
        endpoint1Px: PixelPoint(x: 0, y: 0),
        endpoint2Px: PixelPoint(x: 100, y: 0),
        knownLengthMm: 50,
      );
      final List<DispersionPoint> points = <DispersionPoint>[
        const DispersionPoint(
          id: 'pt-1',
          xMm: 10,
          yMm: 0,
          radialMm: 10,
          holeDiameterMm: 5,
          isOutlierManual: false,
        ),
      ];
      await tester.pumpWidget(
        buildSubject(
          cubit: cubit,
          calibration: calibration,
          aimPx: 50,
          aimPy: 50,
          createPoints: points,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Points'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}

class _FakeRepository implements DispersionRepository {
  @override
  Future<List<DispersionDataset>> fetchDatasets() async => [];

  @override
  Stream<List<DispersionDataset>> watchDatasets() =>
      Stream<List<DispersionDataset>>.value([]);

  @override
  Future<DispersionDataset?> getDataset(final String id) async => null;

  @override
  Future<void> upsertDataset(final DispersionDataset dataset) async {}

  @override
  Future<void> deleteDataset(final String id) async {}

  @override
  Future<DispersionDataset> createDerivedDataset({
    required final String name,
    required final List<String> sourceDatasetIds,
  }) async => throw UnimplementedError();

  @override
  Future<DispersionComparisonResult> compareDatasets(
    final String idA,
    final String idB, {
    required final double alpha,
    required final bool excludeOutliers,
  }) async => throw UnimplementedError();

  @override
  Future<List<DispersionGroup>> fetchGroups() async => [];

  @override
  Stream<List<DispersionGroup>> watchGroups() =>
      Stream<List<DispersionGroup>>.value([]);

  @override
  Future<DispersionGroup?> getGroup(final String id) async => null;

  @override
  Future<void> upsertGroup(final DispersionGroup group) async {}

  @override
  Future<void> deleteGroup(final String id) async {}
}

class _FakeImageImport implements ImageImportService {
  @override
  Future<String?> pickFromCamera() async => null;

  @override
  Future<String?> pickFromGallery() async => null;

  @override
  Future<String?> loadTestImage() async => null;
}
