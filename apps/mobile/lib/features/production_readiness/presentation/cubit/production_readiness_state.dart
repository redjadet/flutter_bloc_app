import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:utilities/utilities.dart';

part 'production_readiness_state.freezed.dart';

enum ProductionReadinessMode { live, simulated }

enum ProductionReadinessStatus { initial, loading, ready, error }

enum ProductionReadinessNonFatalStatus {
  idle,
  recording,
  recordedLocal,
  recordedFirebase,
  failed,
}

@freezed
abstract class ProductionReadinessState with _$ProductionReadinessState {
  const factory ProductionReadinessState({
    @Default(ProductionReadinessStatus.initial)
    ProductionReadinessStatus status,
    @Default(ProductionReadinessMode.simulated) ProductionReadinessMode mode,
    @Default(false) bool analyticsConsentEnabled,
    @Default(0) int localEventCount,
    @Default(true) bool releaseFlagEnabled,
    @Default('control') String releaseVariant,
    @Default('defaults') String configSource,
    @Default(false) bool crashlyticsAvailable,
    @Default(ProductionReadinessNonFatalStatus.idle)
    ProductionReadinessNonFatalStatus lastNonFatalStatus,
    @Default(FcmDemoMode.simulated) FcmDemoMode fcmMode,
    FcmPermissionState? fcmPermission,
    @Default(0) int fcmDataKeyCount,
    @Default(false) bool fcmHasTitle,
    @Default(false) bool fcmHasBody,
    String? fcmLastSource,
    @Default(0) int frameSampleCount,
    @Default(0) double frameP90Ms,
    @Default(0) double frameP99Ms,
    @Default(0) int framesMissedOver16_7Ms,
    String? errorMessage,
  }) = _ProductionReadinessState;
}
