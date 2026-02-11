import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/dispersion/data/image_import_service.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/pages/dispersion_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/in_memory_dispersion_repository.dart';

void main() {
  late InMemoryDispersionRepository repository;
  late String testImagePath;

  setUp(() {
    repository = InMemoryDispersionRepository();
    final pngBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQzwAEhQGAghkxdQAAAABJRU5ErkJggg==',
    );
    final tempFile = File(
      '${Directory.systemTemp.path}/dispersion_e2e_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    tempFile.writeAsBytesSync(pngBytes);
    testImagePath = tempFile.path;
    addTearDown(() => tempFile.deleteSync());
  });

  Widget buildApp(final DispersionCubit cubit) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<DispersionCubit>.value(
        value: cubit,
        child: const DispersionPage(),
      ),
    );
  }

  group('Dispersion E2E', () {
    testWidgets('home shows Compare datasets and dataset list when seeded',
        (final WidgetTester tester) async {
      const calibration = Calibration(
        endpoint1Px: PixelPoint(x: 0, y: 0),
        endpoint2Px: PixelPoint(x: 100, y: 0),
        knownLengthMm: 50,
      );
      final group1 = DispersionGroup(
        id: 'g1',
        name: 'Group 1',
        capturedAt: DateTime(2025, 1, 1).toUtc(),
        distanceToTargetMeters: 25,
        imagePath: '/test/img1.png',
        calibration: calibration,
        aimPointPx: const PixelPoint(x: 50, y: 50),
        points: const <DispersionPoint>[],
      );
      final dataset1 = DispersionDataset(
        id: 'ds1',
        name: 'Set A',
        groupIds: <String>['g1'],
        createdAt: DateTime(2025, 1, 1),
        pointCount: 0,
      );
      repository.seedWithGroupsAndDatasets(
        groups: <DispersionGroup>[group1],
        datasets: <DispersionDataset>[dataset1],
      );
      final cubit = DispersionCubit(
        repository: repository,
        imageImportService: _FakeImageImport(testImagePath),
      );
      addTearDown(cubit.close);
      await cubit.load();
      await tester.pumpWidget(buildApp(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Compare datasets'), findsOneWidget);
      expect(find.text('Set A'), findsOneWidget);
    });

    testWidgets('full flow: compare two datasets then assert result and graph',
        (final WidgetTester tester) async {
      const calibration = Calibration(
        endpoint1Px: PixelPoint(x: 0, y: 0),
        endpoint2Px: PixelPoint(x: 100, y: 0),
        knownLengthMm: 50,
      );
      final group1 = DispersionGroup(
        id: 'g1',
        name: 'Group 1',
        capturedAt: DateTime(2025, 1, 1).toUtc(),
        distanceToTargetMeters: 25,
        imagePath: '/test/img1.png',
        calibration: calibration,
        aimPointPx: const PixelPoint(x: 50, y: 50),
        points: <DispersionPoint>[
          const DispersionPoint(
            id: 'p1',
            xMm: 5,
            yMm: 0,
            radialMm: 5,
            holeDiameterMm: 5,
          ),
          const DispersionPoint(
            id: 'p2',
            xMm: 10,
            yMm: 0,
            radialMm: 10,
            holeDiameterMm: 5,
          ),
        ],
      );
      final group2 = DispersionGroup(
        id: 'g2',
        name: 'Group 2',
        capturedAt: DateTime(2025, 1, 2).toUtc(),
        distanceToTargetMeters: 25,
        imagePath: '/test/img2.png',
        calibration: calibration,
        aimPointPx: const PixelPoint(x: 50, y: 50),
        points: <DispersionPoint>[
          const DispersionPoint(
            id: 'p3',
            xMm: 7,
            yMm: 0,
            radialMm: 7,
            holeDiameterMm: 5,
          ),
          const DispersionPoint(
            id: 'p4',
            xMm: 12,
            yMm: 0,
            radialMm: 12,
            holeDiameterMm: 5,
          ),
        ],
      );
      final dataset1 = DispersionDataset(
        id: 'ds1',
        name: 'Set A',
        groupIds: <String>['g1'],
        createdAt: DateTime(2025, 1, 1),
        pointCount: 2,
      );
      final dataset2 = DispersionDataset(
        id: 'ds2',
        name: 'Set B',
        groupIds: <String>['g2'],
        createdAt: DateTime(2025, 1, 2),
        pointCount: 2,
      );
      repository.seedWithGroupsAndDatasets(
        groups: <DispersionGroup>[group1, group2],
        datasets: <DispersionDataset>[dataset1, dataset2],
      );

      final imageImport = _FakeImageImport(testImagePath);
      final cubit = DispersionCubit(
        repository: repository,
        imageImportService: imageImport,
      );
      addTearDown(cubit.close);
      await cubit.load();
      await tester.pumpWidget(buildApp(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Compare datasets'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      expect(dropdowns, findsNWidgets(2));
      await tester.tap(dropdowns.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Set A').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(dropdowns.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Set B').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Run comparison'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Comparison result'), findsOneWidget);
      expect(find.textContaining('n(A)='), findsOneWidget);
      expect(find.text('Dispersion'), findsOneWidget);
    });

    testWidgets('empty-state comparison: zero effective points shows result',
        (final WidgetTester tester) async {
      const calibration = Calibration(
        endpoint1Px: PixelPoint(x: 0, y: 0),
        endpoint2Px: PixelPoint(x: 100, y: 0),
        knownLengthMm: 50,
      );
      final group1 = DispersionGroup(
        id: 'g1',
        name: 'Group 1',
        capturedAt: DateTime(2025, 1, 1).toUtc(),
        distanceToTargetMeters: 25,
        imagePath: '/test/img1.png',
        calibration: calibration,
        aimPointPx: const PixelPoint(x: 50, y: 50),
        points: <DispersionPoint>[
          const DispersionPoint(
            id: 'p1',
            xMm: 5,
            yMm: 0,
            radialMm: 5,
            holeDiameterMm: 5,
            isOutlierManual: true,
          ),
        ],
      );
      final group2 = DispersionGroup(
        id: 'g2',
        name: 'Group 2',
        capturedAt: DateTime(2025, 1, 2).toUtc(),
        distanceToTargetMeters: 25,
        imagePath: '/test/img2.png',
        calibration: calibration,
        aimPointPx: const PixelPoint(x: 50, y: 50),
        points: <DispersionPoint>[
          const DispersionPoint(
            id: 'p2',
            xMm: 7,
            yMm: 0,
            radialMm: 7,
            holeDiameterMm: 5,
            isOutlierManual: true,
          ),
        ],
      );
      final dataset1 = DispersionDataset(
        id: 'ds1',
        name: 'Empty A',
        groupIds: <String>['g1'],
        createdAt: DateTime(2025, 1, 1),
        pointCount: 1,
      );
      final dataset2 = DispersionDataset(
        id: 'ds2',
        name: 'Empty B',
        groupIds: <String>['g2'],
        createdAt: DateTime(2025, 1, 2),
        pointCount: 1,
      );
      repository.seedWithGroupsAndDatasets(
        groups: <DispersionGroup>[group1, group2],
        datasets: <DispersionDataset>[dataset1, dataset2],
      );

      final cubit = DispersionCubit(
        repository: repository,
        imageImportService: _FakeImageImport(testImagePath),
      );
      addTearDown(cubit.close);
      await cubit.load();
      await tester.pumpWidget(buildApp(cubit));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Compare datasets'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final dropdowns = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdowns.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Empty A').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(dropdowns.at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Empty B').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Run comparison'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Comparison result'), findsOneWidget);
      expect(find.textContaining('n(A)='), findsOneWidget);
    });
  });
}

class _FakeImageImport implements ImageImportService {
  _FakeImageImport(this._testPath);

  final String _testPath;

  @override
  Future<String?> pickFromCamera() async => _testPath;

  @override
  Future<String?> pickFromGallery() async => _testPath;

  @override
  Future<String?> loadTestImage() async => _testPath;
}
