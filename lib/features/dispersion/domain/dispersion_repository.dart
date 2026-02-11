import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';

/// Persistence and aggregation for dispersion groups and datasets.
abstract class DispersionRepository {
  Future<List<DispersionGroup>> fetchGroups();
  Stream<List<DispersionGroup>> watchGroups();
  Future<DispersionGroup?> getGroup(final String id);
  Future<void> upsertGroup(final DispersionGroup group);
  Future<void> deleteGroup(final String id);

  Future<List<DispersionDataset>> fetchDatasets();
  Stream<List<DispersionDataset>> watchDatasets();
  Future<DispersionDataset?> getDataset(final String id);
  Future<void> upsertDataset(final DispersionDataset dataset);
  Future<void> deleteDataset(final String id);

  Future<DispersionDataset> createDerivedDataset({
    required final String name,
    required final List<String> sourceDatasetIds,
  });

  Future<DispersionComparisonResult> compareDatasets(
    final String idA,
    final String idB, {
    required final double alpha,
    required final bool excludeOutliers,
  });
}
