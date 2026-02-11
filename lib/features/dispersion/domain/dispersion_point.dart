import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispersion_point.freezed.dart';

/// A single shot impact point relative to the aiming point.
/// Coordinates and radial distance are in millimeters.
@freezed
abstract class DispersionPoint with _$DispersionPoint {
  const factory DispersionPoint({
    required final String id,
    required final double xMm,
    required final double yMm,
    required final double radialMm,
    required final double holeDiameterMm,
    @Default(false) final bool isOutlierAuto,
    @Default(false) final bool isOutlierManual,
  }) = _DispersionPoint;

  const DispersionPoint._();

  /// Whether this point is considered an outlier (auto or manual).
  bool get isOutlier => isOutlierAuto || isOutlierManual;
}
