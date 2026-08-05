import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:utilities/utilities.dart';

part 'production_readiness_state.freezed.dart';

enum ProductionReadinessMode { live, simulated }

enum ProductionReadinessStatus { initial, loading, ready, error }

@freezed
abstract class ProductionReadinessState with _$ProductionReadinessState {
  const factory ProductionReadinessState({
    @Default(ProductionReadinessStatus.initial)
    final ProductionReadinessStatus status,
    @Default(ProductionReadinessMode.simulated)
    final ProductionReadinessMode mode,
    @Default(false) final bool analyticsConsentEnabled,
    @Default(0) final int localEventCount,
    @Default(true) final bool releaseFlagEnabled,
    @Default('control') final String releaseVariant,
    @Default('defaults') final String configSource,
    @Default(false) final bool crashlyticsAvailable,
    @Default(FcmDemoMode.simulated) final FcmDemoMode fcmMode,
    final FcmPermissionState? fcmPermission,
    @Default(0) final int fcmDataKeyCount,
    @Default(false) final bool fcmHasTitle,
    @Default(false) final bool fcmHasBody,
    final String? fcmLastSource,
    @Default(0) final int frameSampleCount,
    @Default(0) final double frameP90Ms,
    @Default(0) final double frameP99Ms,
    @Default(0) final int framesMissedOver16_7Ms,
    final String? errorMessage,
  }) = _ProductionReadinessState;
}
