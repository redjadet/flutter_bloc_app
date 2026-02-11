import 'package:flutter_bloc_app/features/dispersion/domain/calibration.dart';
import 'package:flutter_bloc_app/features/dispersion/domain/dispersion_point.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispersion_group.freezed.dart';

/// A single dispersion event: one image with calibration, aim point, and shot points.
@freezed
abstract class DispersionGroup with _$DispersionGroup {
  const factory DispersionGroup({
    required final String id,
    required final String name,
    required final DateTime capturedAt,
    required final double distanceToTargetMeters,
    required final String imagePath,
    required final Calibration calibration,
    required final PixelPoint aimPointPx,
    required final List<DispersionPoint> points,
  }) = _DispersionGroup;

  const DispersionGroup._();
}
