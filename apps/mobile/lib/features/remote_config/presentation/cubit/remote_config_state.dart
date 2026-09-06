import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_state.freezed.dart';

/// Union state for the remote config cubit.
@freezed
sealed class RemoteConfigState with _$RemoteConfigState {
  const factory initial() = RemoteConfigInitial;

  const factory loading() = RemoteConfigLoading;

  const factory loaded({
    required bool isAwesomeFeatureEnabled,
    required String testValue,
    String? dataSource,
    DateTime? lastSyncedAt,
  }) = RemoteConfigLoaded;

  const factory error(String message) = RemoteConfigError;
}
