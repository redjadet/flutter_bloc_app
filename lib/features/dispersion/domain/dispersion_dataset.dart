import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispersion_dataset.freezed.dart';

/// A named collection of dispersion data: either from one or more groups,
/// or derived by merging other datasets.
@freezed
abstract class DispersionDataset with _$DispersionDataset {
  const factory DispersionDataset({
    required final String id,
    required final String name,
    required final List<String> groupIds,
    required final DateTime createdAt,
    @Default(false) final bool isDerived,
    @Default([]) final List<String> sourceDatasetIds,
    @Default(0) final int pointCount,
    @Default({}) final Map<String, String> metadata,
  }) = _DispersionDataset;

  const DispersionDataset._();
}
