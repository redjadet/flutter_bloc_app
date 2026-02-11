import 'dart:async';

import 'package:flutter_bloc_app/features/dispersion/data/mann_whitney_service_impl.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_repository.dart';

/// In-memory repository for E2E tests. Mutations update lists and notify
/// watchers via broadcast streams.
class InMemoryDispersionRepository implements DispersionRepository {
  InMemoryDispersionRepository()
      : _mannWhitney = MannWhitneyServiceImpl(),
        _groupsController = StreamController<List<DispersionGroup>>.broadcast(),
        _datasetsController =
            StreamController<List<DispersionDataset>>.broadcast();

  final MannWhitneyServiceImpl _mannWhitney;
  final StreamController<List<DispersionGroup>> _groupsController;
  final StreamController<List<DispersionDataset>> _datasetsController;

  List<DispersionGroup> _groups = <DispersionGroup>[];
  List<DispersionDataset> _datasets = <DispersionDataset>[];

  void seedWithGroupsAndDatasets({
    required final List<DispersionGroup> groups,
    required final List<DispersionDataset> datasets,
  }) {
    _groups = List<DispersionGroup>.from(groups);
    _datasets = List<DispersionDataset>.from(datasets);
    _groupsController.add(List<DispersionGroup>.from(_groups));
    _datasetsController.add(List<DispersionDataset>.from(_datasets));
  }

  @override
  Future<List<DispersionGroup>> fetchGroups() async =>
      List<DispersionGroup>.from(_groups);

  @override
  Stream<List<DispersionGroup>> watchGroups() async* {
    yield List<DispersionGroup>.from(_groups);
    yield* _groupsController.stream;
  }

  @override
  Future<DispersionGroup?> getGroup(final String id) async {
    try {
      return _groups.firstWhere((final g) => g.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsertGroup(final DispersionGroup group) async {
    final int i = _groups.indexWhere((final g) => g.id == group.id);
    if (i >= 0) {
      _groups[i] = group;
    } else {
      _groups.add(group);
    }
    _groupsController.add(List<DispersionGroup>.from(_groups));
  }

  @override
  Future<void> deleteGroup(final String id) async {
    _groups.removeWhere((final g) => g.id == id);
    _groupsController.add(List<DispersionGroup>.from(_groups));
  }

  @override
  Future<List<DispersionDataset>> fetchDatasets() async =>
      List<DispersionDataset>.from(_datasets);

  @override
  Stream<List<DispersionDataset>> watchDatasets() async* {
    yield List<DispersionDataset>.from(_datasets);
    yield* _datasetsController.stream;
  }

  @override
  Future<DispersionDataset?> getDataset(final String id) async {
    try {
      return _datasets.firstWhere((final d) => d.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<void> upsertDataset(final DispersionDataset dataset) async {
    final int i = _datasets.indexWhere((final d) => d.id == dataset.id);
    if (i >= 0) {
      _datasets[i] = dataset;
    } else {
      _datasets.add(dataset);
    }
    _datasetsController.add(List<DispersionDataset>.from(_datasets));
  }

  @override
  Future<void> deleteDataset(final String id) async {
    _datasets.removeWhere((final d) => d.id == id);
    _datasetsController.add(List<DispersionDataset>.from(_datasets));
  }

  @override
  Future<DispersionDataset> createDerivedDataset({
    required final String name,
    required final List<String> sourceDatasetIds,
  }) async {
    final Set<String> groupIds = <String>{};
    int pointCount = 0;
    for (final String sid in sourceDatasetIds) {
      final DispersionDataset? ds = await getDataset(sid);
      if (ds != null) {
        groupIds.addAll(ds.groupIds);
        pointCount += ds.pointCount;
      }
    }
    final String id = 'derived-${DateTime.now().microsecondsSinceEpoch}';
    final DispersionDataset derived = DispersionDataset(
      id: id,
      name: name,
      groupIds: groupIds.toList()..sort(),
      createdAt: DateTime.now().toUtc(),
      isDerived: true,
      sourceDatasetIds: sourceDatasetIds,
      pointCount: pointCount,
    );
    await upsertDataset(derived);
    return derived;
  }

  @override
  Future<DispersionComparisonResult> compareDatasets(
    final String idA,
    final String idB, {
    required final double alpha,
    required final bool excludeOutliers,
  }) async {
    final (List<double> sampleA, int excludedA) =
        await _radialsAndExcluded(idA, excludeOutliers);
    final (List<double> sampleB, int excludedB) =
        await _radialsAndExcluded(idB, excludeOutliers);
    final DispersionComparisonResult result = _mannWhitney.runTest(
      sampleA: sampleA,
      sampleB: sampleB,
      alpha: alpha,
      datasetAId: idA,
      datasetBId: idB,
    );
    return result.copyWith(
      excludedOutliersCount: excludedA + excludedB,
    );
  }

  Future<(List<double>, int)> _radialsAndExcluded(
    final String datasetId,
    final bool excludeOutliers,
  ) async {
    final DispersionDataset? dataset = await getDataset(datasetId);
    if (dataset == null) return (<double>[], 0);
    final List<double> radials = <double>[];
    int excluded = 0;
    for (final String gid in dataset.groupIds) {
      final DispersionGroup? group = await getGroup(gid);
      if (group == null) continue;
      for (final DispersionPoint p in group.points) {
        if (excludeOutliers && p.isOutlier) {
          excluded++;
          continue;
        }
        radials.add(p.radialMm);
      }
    }
    return (radials, excluded);
  }
}
