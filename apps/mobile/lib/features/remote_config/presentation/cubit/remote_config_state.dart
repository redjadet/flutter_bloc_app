import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_state.freezed.dart';

/// Union state for the remote config cubit.
@freezed
sealed class RemoteConfigState with _$RemoteConfigState {
  const factory RemoteConfigState.initial() = RemoteConfigInitial;

  const factory RemoteConfigState.loading() = RemoteConfigLoading;

  const factory RemoteConfigState.loaded({
    required bool isAwesomeFeatureEnabled,
    required String testValue,
    String? dataSource,
    DateTime? lastSyncedAt,
  }) = RemoteConfigLoaded;

  const factory RemoteConfigState.error(String message) = RemoteConfigError;
}
