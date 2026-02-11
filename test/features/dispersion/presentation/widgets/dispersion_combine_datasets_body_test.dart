import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/dispersion/data/image_import_service.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_repository.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_cubit.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/widgets/dispersion_combine_datasets_body.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DispersionCombineDatasetsBody', () {
    Widget buildSubject({
      required final DispersionCubit cubit,
      final List<DispersionDataset> datasets = const [],
      final String? errorMessage,
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
            child: DispersionCombineDatasetsBody(
              datasets: datasets,
              errorMessage: errorMessage,
            ),
          ),
        ),
      );
    }

    testWidgets('shows combine title and back button', (
      final WidgetTester tester,
    ) async {
      final cubit = DispersionCubit(
        repository: _FakeRepository(),
        imageImportService: _FakeImageImport(),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(buildSubject(cubit: cubit));
      await tester.pumpAndSettle();
      expect(find.text('Combine datasets'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows Create combined dataset button', (
      final WidgetTester tester,
    ) async {
      final cubit = DispersionCubit(
        repository: _FakeRepository(),
        imageImportService: _FakeImageImport(),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(buildSubject(cubit: cubit));
      await tester.pumpAndSettle();
      expect(find.text('Create combined dataset'), findsOneWidget);
    });

    testWidgets('shows dataset list when datasets provided', (
      final WidgetTester tester,
    ) async {
      final cubit = DispersionCubit(
        repository: _FakeRepository(),
        imageImportService: _FakeImageImport(),
      );
      addTearDown(cubit.close);
      final datasets = <DispersionDataset>[
        DispersionDataset(
          id: 'ds1',
          name: 'Dataset A',
          groupIds: [],
          createdAt: DateTime(2025, 1, 1),
          pointCount: 5,
        ),
      ];
      await tester.pumpWidget(buildSubject(cubit: cubit, datasets: datasets));
      await tester.pumpAndSettle();
      expect(find.text('Dataset A'), findsOneWidget);
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
