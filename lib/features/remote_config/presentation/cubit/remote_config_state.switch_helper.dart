part of 'remote_config_cubit.dart';

// Generated exhaustive switch helper for RemoteConfigState
extension RemoteConfigStateSwitchHelper on RemoteConfigState {
  /// Exhaustive pattern matching helper
  T when<T>({
    required final T Function() initial,
    required final T Function() loading,
    required final T Function({
      required bool isAwesomeFeatureEnabled,
      required String testValue,
      String? dataSource,
      DateTime? lastSyncedAt,
    })
    loaded,
    required final T Function(String message) error,
  }) => switch (this) {
    RemoteConfigInitial() => initial(),
    RemoteConfigLoading() => loading(),
    RemoteConfigLoaded(
      :final isAwesomeFeatureEnabled,
      :final testValue,
      :final dataSource,
      :final lastSyncedAt,
    ) =>
      loaded(
        isAwesomeFeatureEnabled: isAwesomeFeatureEnabled,
        testValue: testValue,
        dataSource: dataSource,
        lastSyncedAt: lastSyncedAt,
      ),
    RemoteConfigError(:final message) => error(message),
  };
}
