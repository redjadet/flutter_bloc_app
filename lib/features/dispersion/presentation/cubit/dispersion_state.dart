import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_comparison_result.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_dataset.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_group.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispersion_state.freezed.dart';

enum DispersionScreen {
  home,
  createGroup,
  combineDatasets,
  manageDatasets,
  compare,
}

@freezed
abstract class DispersionState with _$DispersionState {
  const factory DispersionState({
    @Default(DispersionScreen.home) final DispersionScreen screen,
    @Default([]) final List<DispersionDataset> datasets,
    @Default([]) final List<DispersionGroup> groups,
    @Default(true) final bool isLoading,
    final String? errorMessage,

    // Create group flow
    final String? createImagePath,
    final Calibration? createCalibration,
    final PixelPoint? createAimPointPx,
    @Default([]) final List<DispersionPoint> createPoints,
    final String? createSelectedPointId,
    @Default(0) final double createDistanceMeters,
    @Default(0) final double createKnownLengthMm,
    @Default(0) final double createCalibrationE1x,
    @Default(0) final double createCalibrationE1y,
    @Default(0) final double createCalibrationE2x,
    @Default(0) final double createCalibrationE2y,
    @Default(0) final double createAimPx,
    @Default(0) final double createAimPy,
    final String? createGroupName,
    final double? createHoleDiameterMm,
    @Default(0) final int createSamplePointIndex,

    // Comparison
    final String? compareDatasetAId,
    final String? compareDatasetBId,
    @Default(0.05) final double compareAlpha,
    @Default(true) final bool compareExcludeOutliers,
    final DispersionComparisonResult? compareResult,
    @Default(false) final bool compareLoading,
    final List<DispersionPoint>? comparePointsA,
    final List<DispersionPoint>? comparePointsB,
  }) = _DispersionState;

  const DispersionState._();
}
