import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/dispersion/data/image_import_service.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_repository.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/outlier_utils.dart';
import 'package:flutter_bloc_app/features/dispersion/presentation/cubit/dispersion_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';

class DispersionCubit extends Cubit<DispersionState> with CubitSubscriptionMixin<DispersionState> {
  DispersionCubit({
    required final DispersionRepository repository,
    required final ImageImportService imageImportService,
  }) : _repository = repository,
       _imageImport = imageImportService,
       super(const DispersionState());

  final DispersionRepository _repository;
  final ImageImportService _imageImport;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<List<DispersionDataset>>? _datasetsSub;
  // ignore: cancel_subscriptions - Subscriptions are managed by CubitSubscriptionMixin
  StreamSubscription<List<DispersionGroup>>? _groupsSub;

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));
    await CubitExceptionHandler.executeAsync(
      operation: () async {
        final List<DispersionDataset> datasets = await _repository.fetchDatasets();
        final List<DispersionGroup> groups = await _repository.fetchGroups();
        return (datasets: datasets, groups: groups);
      },
      onSuccess: (final result) {
        if (isClosed) return;
        emit(
          state.copyWith(
            datasets: result.datasets,
            groups: result.groups,
            isLoading: false,
          ),
        );
      },
      onError: (final errorMessage) {
        if (isClosed) return;
        emit(state.copyWith(isLoading: false, errorMessage: errorMessage));
      },
      logContext: 'DispersionCubit.load',
    );
  }

  void watchData() {
    if (_datasetsSub != null || _groupsSub != null) {
      return;
    }
    _datasetsSub = _repository.watchDatasets().listen((final list) {
      if (isClosed) return;
      emit(state.copyWith(datasets: list));
    });
    _groupsSub = _repository.watchGroups().listen((final list) {
      if (isClosed) return;
      emit(state.copyWith(groups: list));
    });
    registerSubscription(_datasetsSub);
    registerSubscription(_groupsSub);
  }

  @override
  Future<void> close() async {
    await closeAllSubscriptions();
    return super.close();
  }

  void setScreen(final DispersionScreen screen) {
    emit(state.copyWith(screen: screen, errorMessage: null));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> pickImageFromCamera() async {
    await CubitExceptionHandler.executeAsync(
      operation: _imageImport.pickFromCamera,
      onSuccess: (final path) {
        if (isClosed) return;
        emit(state.copyWith(createImagePath: path));
      },
      onError: (final _) {},
      logContext: 'DispersionCubit.pickImageFromCamera',
    );
  }

  Future<void> pickImageFromGallery() async {
    await CubitExceptionHandler.executeAsync(
      operation: _imageImport.pickFromGallery,
      onSuccess: (final path) {
        if (isClosed) return;
        emit(state.copyWith(createImagePath: path));
      },
      onError: (final _) {},
      logContext: 'DispersionCubit.pickImageFromGallery',
    );
  }

  /// Loads the built-in test image (for manual testing without camera/gallery).
  Future<void> loadTestImage() async {
    await CubitExceptionHandler.executeAsync(
      operation: _imageImport.loadTestImage,
      onSuccess: (final path) {
        if (isClosed) return;
        emit(state.copyWith(createImagePath: path, errorMessage: null));
      },
      onError: (final _) {},
      logContext: 'DispersionCubit.loadTestImage',
    );
  }

  /// Adds 1-2 sample points per call around the current aim point.
  /// Uses fixed pixel offsets so markers stay visible on the image regardless of calibration scale.
  /// Requires image + calibration + aim point.
  void addSamplePoints() {
    final String? imagePath = state.createImagePath;
    final Calibration? cal = state.createCalibration;
    final PixelPoint? aim = state.createAimPointPx;
    if (imagePath == null || imagePath.isEmpty || cal == null || aim == null) {
      if (!isClosed) {
        emit(
          state.copyWith(
            errorMessage: 'Set image, calibration, and aim point before adding sample points',
          ),
        );
      }
      return;
    }
    if (cal.scaleFactorMmPerPx <= 0 || cal.pixelDistance <= 0) {
      return;
    }
    final double stepPx = (cal.pixelDistance * 0.12).clamp(0.12, 24.0);
    final List<(double dxPx, double dyPx)> sampleOffsetsPx = <(double, double)>[
      (stepPx, 0),
      (0, stepPx),
      (-stepPx * 0.75, stepPx * 0.6),
      (stepPx * 0.6, -stepPx * 0.85),
      (-stepPx * 0.85, -stepPx * 0.75),
      (0, -stepPx * 1.15),
    ];
    final int index = state.createSamplePointIndex;
    if (index >= sampleOffsetsPx.length) {
      return;
    }
    final int toAdd = (index + 2 <= sampleOffsetsPx.length) ? 2 : 1;
    final double? holeOverride =
        (state.createHoleDiameterMm == null || state.createHoleDiameterMm! <= 0) ? 1.0 : null;
    for (int i = 0; i < toAdd; i++) {
      final (double dxPx, double dyPx) = sampleOffsetsPx[index + i];
      addCreatePoint(
        PixelPoint(x: dxPx, y: dyPx),
        holeDiameterMmOverride: holeOverride,
      );
    }
    if (isClosed) return;
    emit(state.copyWith(createSamplePointIndex: index + toAdd));
  }

  void setCreateCalibration(
    final PixelPoint endpoint1Px,
    final PixelPoint endpoint2Px,
    final double knownLengthMm,
  ) {
    emit(
      state.copyWith(
        createCalibration: Calibration(
          endpoint1Px: endpoint1Px,
          endpoint2Px: endpoint2Px,
          knownLengthMm: knownLengthMm,
        ),
        createKnownLengthMm: knownLengthMm,
        createCalibrationE1x: endpoint1Px.x,
        createCalibrationE1y: endpoint1Px.y,
        createCalibrationE2x: endpoint2Px.x,
        createCalibrationE2y: endpoint2Px.y,
      ),
    );
  }

  void setCreateCalibrationFromNumbers(
    final double e1x,
    final double e1y,
    final double e2x,
    final double e2y,
    final double knownLengthMm,
  ) {
    emit(
      state.copyWith(
        createCalibration: Calibration(
          endpoint1Px: PixelPoint(x: e1x, y: e1y),
          endpoint2Px: PixelPoint(x: e2x, y: e2y),
          knownLengthMm: knownLengthMm,
        ),
        createKnownLengthMm: knownLengthMm,
        createCalibrationE1x: e1x,
        createCalibrationE1y: e1y,
        createCalibrationE2x: e2x,
        createCalibrationE2y: e2y,
      ),
    );
  }

  void setCreateAimPoint(final PixelPoint aimPointPx) {
    emit(
      state.copyWith(
        createAimPointPx: aimPointPx,
        createAimPx: aimPointPx.x,
        createAimPy: aimPointPx.y,
      ),
    );
  }

  void setCreateAimFromNumbers(final double x, final double y) {
    emit(
      state.copyWith(
        createAimPointPx: PixelPoint(x: x, y: y),
        createAimPx: x,
        createAimPy: y,
      ),
    );
  }

  void setCreateDistanceMeters(final double meters) {
    emit(state.copyWith(createDistanceMeters: meters));
  }

  void setCreateGroupName(final String name) {
    emit(state.copyWith(createGroupName: name));
  }

  void setCreateHoleDiameterMm(final double mm) {
    emit(state.copyWith(createHoleDiameterMm: mm));
  }

  /// Fills the create flow with test values from the MVP plan (debug/testing).
  /// For tiny generated test images (`test_sample_*`), use 1px-wide calibration and centered aim
  /// so sample points remain visible.
  void applyCreateTestValues() {
    const double defaultE1x = 0;
    const double defaultE1y = 0;
    const double defaultE2x = 200;
    const double defaultE2y = 0;
    const double knownLengthMm = 50;
    const double defaultAimX = 100;
    const double defaultAimY = 100;
    const double distanceM = 25;
    const double holeMm = 5;
    const String groupName = 'Test group A';
    final bool isGeneratedTinyTestImage = (state.createImagePath ?? '').contains('test_sample_');
    const double e1x = defaultE1x;
    const double e1y = defaultE1y;
    final double e2x = isGeneratedTinyTestImage ? 1 : defaultE2x;
    final double e2y = isGeneratedTinyTestImage ? 0 : defaultE2y;
    final double aimX = isGeneratedTinyTestImage ? 0.5 : defaultAimX;
    final double aimY = isGeneratedTinyTestImage ? 0.5 : defaultAimY;
    emit(
      state.copyWith(
        createCalibration: Calibration(
          endpoint1Px: const PixelPoint(x: e1x, y: e1y),
          endpoint2Px: PixelPoint(x: e2x, y: e2y),
          knownLengthMm: knownLengthMm,
        ),
        createKnownLengthMm: knownLengthMm,
        createCalibrationE1x: e1x,
        createCalibrationE1y: e1y,
        createCalibrationE2x: e2x,
        createCalibrationE2y: e2y,
        createAimPointPx: PixelPoint(x: aimX, y: aimY),
        createAimPx: aimX,
        createAimPy: aimY,
        createDistanceMeters: distanceM,
        createHoleDiameterMm: holeMm,
        createGroupName: groupName,
      ),
    );
  }

  void addCreatePoint(
    final PixelPoint pixelOffsetFromAim, {
    final double? holeDiameterMmOverride,
  }) {
    final Calibration? cal = state.createCalibration;
    final double? stateHole = state.createHoleDiameterMm;
    final double holeMm = holeDiameterMmOverride ?? stateHole ?? 0;
    if (cal == null || holeMm <= 0) {
      return;
    }
    final double scale = cal.scaleFactorMmPerPx;
    final double xMm = pixelOffsetFromAim.x * scale;
    final double yMm = pixelOffsetFromAim.y * scale;
    final double radialMm = _sqrt(xMm * xMm + yMm * yMm);
    final String id = 'pt-${DateTime.now().microsecondsSinceEpoch}';
    final DispersionPoint point = DispersionPoint(
      id: id,
      xMm: xMm,
      yMm: yMm,
      radialMm: radialMm,
      holeDiameterMm: holeMm,
    );
    final List<DispersionPoint> nextPoints = applyIqrOutlierFlags([
      ...state.createPoints,
      point,
    ]);
    emit(state.copyWith(createPoints: nextPoints));
  }

  void removeCreatePoint(final String pointId) {
    final List<DispersionPoint> nextPoints = applyIqrOutlierFlags(
      state.createPoints.where((final p) => p.id != pointId).toList(),
    );
    emit(
      state.copyWith(
        createPoints: nextPoints,
        createSelectedPointId: state.createSelectedPointId == pointId
            ? null
            : state.createSelectedPointId,
        createSamplePointIndex: nextPoints.isEmpty ? 0 : state.createSamplePointIndex,
      ),
    );
  }

  /// Toggles or sets manual outlier flag for a point in the create flow.
  void setCreatePointOutlierManual(
    final String pointId, {
    required final bool value,
  }) {
    final int idx = state.createPoints.indexWhere((final p) => p.id == pointId);
    if (idx < 0) return;
    final List<DispersionPoint> next = List<DispersionPoint>.from(
      state.createPoints,
    );
    next[idx] = next[idx].copyWith(isOutlierManual: value);
    emit(state.copyWith(createPoints: next));
  }

  void setCreateSelectedPoint(final String? pointId) {
    emit(state.copyWith(createSelectedPointId: pointId));
  }

  void clearCreateFlow() {
    emit(
      state.copyWith(
        createImagePath: null,
        createCalibration: null,
        createAimPointPx: null,
        createPoints: const [],
        createSelectedPointId: null,
        createDistanceMeters: 0,
        createKnownLengthMm: 0,
        createGroupName: null,
        createSamplePointIndex: 0,
        errorMessage: null,
      ),
    );
  }

  Future<void> saveGroup() async {
    final String? imagePath = state.createImagePath;
    final Calibration? cal = state.createCalibration;
    final PixelPoint? aim = state.createAimPointPx;
    final List<DispersionPoint> points = state.createPoints;
    final double distance = state.createDistanceMeters;
    final String name = state.createGroupName ?? 'Group ${DateTime.now().toIso8601String()}';
    if (imagePath == null || imagePath.isEmpty || cal == null || aim == null) {
      if (!isClosed) {
        emit(
          state.copyWith(
            errorMessage: 'Missing image, calibration, or aim point',
          ),
        );
      }
      return;
    }
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        final String id = 'group-${DateTime.now().microsecondsSinceEpoch}';
        final List<DispersionPoint> pointsWithAuto = applyIqrOutlierFlags(
          points,
        );
        final DispersionGroup group = DispersionGroup(
          id: id,
          name: name,
          capturedAt: DateTime.now().toUtc(),
          distanceToTargetMeters: distance,
          imagePath: imagePath,
          calibration: cal,
          aimPointPx: aim,
          points: pointsWithAuto,
        );
        await _repository.upsertGroup(group);
        final DispersionDataset dataset = DispersionDataset(
          id: 'dataset-$id',
          name: name,
          groupIds: [id],
          createdAt: DateTime.now().toUtc(),
          pointCount: points.length,
        );
        await _repository.upsertDataset(dataset);
      },
      onSuccess: () {
        if (isClosed) return;
        clearCreateFlow();
        emit(state.copyWith(screen: DispersionScreen.home));
      },
      onError: (final errorMessage) {
        if (isClosed) return;
        emit(state.copyWith(errorMessage: errorMessage));
      },
      logContext: 'DispersionCubit.saveGroup',
    );
  }

  Future<void> createDatasetFromGroups(
    final String name,
    final List<String> groupIds,
  ) async {
    if (name.isEmpty || groupIds.isEmpty) {
      return;
    }
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        int pointCount = 0;
        for (final String gid in groupIds) {
          final DispersionGroup? g = await _repository.getGroup(gid);
          if (g != null) {
            pointCount += g.points.length;
          }
        }
        final String id = 'dataset-${DateTime.now().microsecondsSinceEpoch}';
        final DispersionDataset ds = DispersionDataset(
          id: id,
          name: name,
          groupIds: groupIds,
          createdAt: DateTime.now().toUtc(),
          pointCount: pointCount,
        );
        await _repository.upsertDataset(ds);
      },
      onError: (final errorMessage) {
        if (isClosed) return;
        emit(state.copyWith(errorMessage: errorMessage));
      },
      logContext: 'DispersionCubit.createDatasetFromGroups',
    );
  }

  Future<void> createDerivedDataset(
    final String name,
    final List<String> sourceDatasetIds,
  ) async {
    if (name.isEmpty || sourceDatasetIds.length < 2) {
      return;
    }
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _repository.createDerivedDataset(
        name: name.trim(),
        sourceDatasetIds: sourceDatasetIds,
      ),
      onSuccess: () {
        if (isClosed) return;
        emit(state.copyWith(screen: DispersionScreen.home, errorMessage: null));
      },
      onError: (final errorMessage) {
        if (isClosed) return;
        emit(state.copyWith(errorMessage: errorMessage));
      },
      logContext: 'DispersionCubit.createDerivedDataset',
    );
  }

  void setCompareDatasetA(final String? id) {
    emit(
      state.copyWith(
        compareDatasetAId: id,
        compareResult: null,
        comparePointsA: null,
        comparePointsB: null,
      ),
    );
  }

  void setCompareDatasetB(final String? id) {
    emit(
      state.copyWith(
        compareDatasetBId: id,
        compareResult: null,
        comparePointsA: null,
        comparePointsB: null,
      ),
    );
  }

  void setCompareAlpha(final double alpha) {
    emit(state.copyWith(compareAlpha: alpha, compareResult: null));
  }

  void setCompareExcludeOutliers({required final bool exclude}) {
    emit(state.copyWith(compareExcludeOutliers: exclude, compareResult: null));
  }

  Future<void> runComparison() async {
    final String? idA = state.compareDatasetAId;
    final String? idB = state.compareDatasetBId;
    if (idA == null || idB == null || idA == idB) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'Select two different datasets'));
      }
      return;
    }
    emit(state.copyWith(compareLoading: true, errorMessage: null));
    final double alpha = state.compareAlpha;
    final bool excludeOutliers = state.compareExcludeOutliers;
    await CubitExceptionHandler.executeAsync(
      operation: () async {
        final DispersionComparisonResult result = await _repository.compareDatasets(
          idA,
          idB,
          alpha: alpha,
          excludeOutliers: excludeOutliers,
        );
        final List<DispersionPoint> pointsA = await _loadPointsForDataset(idA);
        final List<DispersionPoint> pointsB = await _loadPointsForDataset(idB);
        return (result: result, pointsA: pointsA, pointsB: pointsB);
      },
      onSuccess: (final data) {
        if (isClosed) return;
        emit(
          state.copyWith(
            compareResult: data.result,
            comparePointsA: data.pointsA,
            comparePointsB: data.pointsB,
            compareLoading: false,
          ),
        );
      },
      onError: (final errorMessage) {
        if (isClosed) return;
        emit(state.copyWith(compareLoading: false, errorMessage: errorMessage));
      },
      logContext: 'DispersionCubit.runComparison',
    );
  }

  Future<List<DispersionPoint>> _loadPointsForDataset(
    final String datasetId,
  ) async {
    final DispersionDataset? dataset = await _repository.getDataset(datasetId);
    if (dataset == null) return <DispersionPoint>[];
    final List<DispersionPoint> points = <DispersionPoint>[];
    for (final String gid in dataset.groupIds) {
      final DispersionGroup? group = await _repository.getGroup(gid);
      if (group != null) {
        points.addAll(group.points);
      }
    }
    return points;
  }

  static double _sqrt(final double v) {
    if (v <= 0) {
      return 0;
    }
    return math.sqrt(v);
  }
}
