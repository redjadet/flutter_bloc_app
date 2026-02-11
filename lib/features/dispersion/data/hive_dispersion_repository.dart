import 'dart:async';

import 'package:flutter_bloc_app/features/dispersion/data/dispersion_dto.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_repository.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/mann_whitney_service.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/outlier_utils.dart';
import 'package:flutter_bloc_app/shared/storage/hive_repository_base.dart';
import 'package:flutter_bloc_app/shared/utils/storage_guard.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDispersionRepository extends HiveRepositoryBase
    implements DispersionRepository {
  HiveDispersionRepository({
    required super.hiveService,
    required final MannWhitneyService mannWhitneyService,
  }) : _mannWhitney = mannWhitneyService;

  static const String _boxName = 'dispersion_data';
  static const String _keyGroups = 'groups';
  static const String _keyDatasets = 'datasets';

  final MannWhitneyService _mannWhitney;

  @override
  String get boxName => _boxName;

  @override
  Future<List<DispersionGroup>> fetchGroups() async => StorageGuard.run(
    logContext: 'HiveDispersionRepository.fetchGroups',
    action: () async {
      final Box<dynamic> box = await getBox();
      return _loadGroupsFromBox(box);
    },
    fallback: () => <DispersionGroup>[],
  );

  @override
  Stream<List<DispersionGroup>> watchGroups() async* {
    final Box<dynamic> box = await getBox();
    yield await _loadGroupsFromBox(box);
    await for (final BoxEvent event in box.watch()) {
      if (event.key == _keyGroups) {
        yield await _loadGroupsFromBox(box);
      }
    }
  }

  @override
  Future<DispersionGroup?> getGroup(final String id) async {
    final List<DispersionGroup> all = await fetchGroups();
    try {
      return all.firstWhere((final g) => g.id == id);
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> upsertGroup(final DispersionGroup group) async =>
      StorageGuard.run(
        logContext: 'HiveDispersionRepository.upsertGroup',
        action: () async {
          final List<DispersionPoint> pointsWithOutliers = applyIqrOutlierFlags(
            group.points,
          );
          final DispersionGroup groupToSave = DispersionGroup(
            id: group.id,
            name: group.name,
            capturedAt: group.capturedAt,
            distanceToTargetMeters: group.distanceToTargetMeters,
            imagePath: group.imagePath,
            calibration: group.calibration,
            aimPointPx: group.aimPointPx,
            points: pointsWithOutliers,
          );
          final Box<dynamic> box = await getBox();
          final List<DispersionGroup> list = await _loadGroupsFromBox(box);
          final int i = list.indexWhere(
            (final g) => g.id == group.id,
          );
          final List<DispersionGroup> updated = List<DispersionGroup>.from(
            list,
          );
          if (i >= 0) {
            updated[i] = groupToSave;
          } else {
            updated.add(groupToSave);
          }
          await _saveGroups(box, updated);
        },
      );

  @override
  Future<void> deleteDataset(final String id) async => StorageGuard.run(
    logContext: 'HiveDispersionRepository.deleteDataset',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<DispersionDataset> list = await _loadDatasetsFromBox(box);
      final List<DispersionDataset> updated = list
          .where((final d) => d.id != id)
          .toList();
      await _saveDatasets(box, updated);
    },
  );

  @override
  Future<void> deleteGroup(final String id) async => StorageGuard.run(
    logContext: 'HiveDispersionRepository.deleteGroup',
    action: () async {
      final Box<dynamic> box = await getBox();
      final List<DispersionGroup> list = await _loadGroupsFromBox(box);
      final List<DispersionGroup> updated = list
          .where((final g) => g.id != id)
          .toList();
      await _saveGroups(box, updated);
    },
  );

  @override
  Future<List<DispersionDataset>> fetchDatasets() async => StorageGuard.run(
    logContext: 'HiveDispersionRepository.fetchDatasets',
    action: () async {
      final Box<dynamic> box = await getBox();
      return _loadDatasetsFromBox(box);
    },
    fallback: () => <DispersionDataset>[],
  );

  @override
  Stream<List<DispersionDataset>> watchDatasets() async* {
    final Box<dynamic> box = await getBox();
    yield await _loadDatasetsFromBox(box);
    await for (final BoxEvent event in box.watch()) {
      if (event.key == _keyDatasets) {
        yield await _loadDatasetsFromBox(box);
      }
    }
  }

  @override
  Future<DispersionDataset?> getDataset(final String id) async {
    final List<DispersionDataset> all = await fetchDatasets();
    try {
      return all.firstWhere((final d) => d.id == id);
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> upsertDataset(final DispersionDataset dataset) async =>
      StorageGuard.run(
        logContext: 'HiveDispersionRepository.upsertDataset',
        action: () async {
          final Box<dynamic> box = await getBox();
          final List<DispersionDataset> list = await _loadDatasetsFromBox(box);
          final int i = list.indexWhere(
            (final d) => d.id == dataset.id,
          );
          final List<DispersionDataset> updated = List<DispersionDataset>.from(
            list,
          );
          if (i >= 0) {
            updated[i] = dataset;
          } else {
            updated.add(dataset);
          }
          await _saveDatasets(box, updated);
        },
      );

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
    final (
      List<double> sampleA,
      int excludedA,
    ) = await _radialDistancesAndExcludedCount(
      idA,
      excludeOutliers,
    );
    final (
      List<double> sampleB,
      int excludedB,
    ) = await _radialDistancesAndExcludedCount(
      idB,
      excludeOutliers,
    );
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

  Future<(List<double>, int)> _radialDistancesAndExcludedCount(
    final String datasetId,
    final bool excludeOutliers,
  ) async {
    final DispersionDataset? dataset = await getDataset(datasetId);
    if (dataset == null) {
      return (<double>[], 0);
    }
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

  Future<List<DispersionGroup>> _loadGroupsFromBox(
    final Box<dynamic> box,
  ) async {
    final dynamic raw = box.get(_keyGroups);
    if (raw is! List<dynamic>) return <DispersionGroup>[];
    final List<DispersionGroup> out = <DispersionGroup>[];
    for (final dynamic e in raw) {
      if (e is Map<dynamic, dynamic>) {
        final DispersionGroup? g = dispersionGroupFromMap(e);
        if (g != null) out.add(g);
      }
    }
    return out;
  }

  Future<void> _saveGroups(
    final Box<dynamic> box,
    final List<DispersionGroup> list,
  ) async {
    final List<Map<String, dynamic>> serialized = list
        .map(dispersionGroupToMap)
        .toList();
    await box.put(_keyGroups, serialized);
  }

  Future<List<DispersionDataset>> _loadDatasetsFromBox(
    final Box<dynamic> box,
  ) async {
    final dynamic raw = box.get(_keyDatasets);
    if (raw is! List<dynamic>) return <DispersionDataset>[];
    final List<DispersionDataset> out = <DispersionDataset>[];
    for (final dynamic e in raw) {
      if (e is Map<dynamic, dynamic>) {
        final DispersionDataset? d = dispersionDatasetFromMap(e);
        if (d != null) out.add(d);
      }
    }
    return out;
  }

  Future<void> _saveDatasets(
    final Box<dynamic> box,
    final List<DispersionDataset> list,
  ) async {
    final List<Map<String, dynamic>> serialized = list
        .map(dispersionDatasetToMap)
        .toList();
    await box.put(_keyDatasets, serialized);
  }
}
