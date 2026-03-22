import 'package:flutter_bloc_app/core/diagnostics/remote_config_diagnostics_view_data.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_state.dart';

/// Maps feature [RemoteConfigState] to core diagnostics view data for shared UI.
RemoteConfigDiagnosticsViewData mapRemoteConfigStateToDiagnosticsViewData(
  final RemoteConfigState state,
) {
  if (state is RemoteConfigLoading) {
    return const RemoteConfigDiagnosticsViewData(
      status: RemoteConfigDiagnosticsStatus.loading,
    );
  }
  if (state is RemoteConfigLoaded) {
    return RemoteConfigDiagnosticsViewData(
      status: RemoteConfigDiagnosticsStatus.loaded,
      isAwesomeFeatureEnabled: state.isAwesomeFeatureEnabled,
      testValue: state.testValue,
      dataSource: state.dataSource,
      lastSyncedAt: state.lastSyncedAt,
    );
  }
  if (state is RemoteConfigError) {
    return RemoteConfigDiagnosticsViewData(
      status: RemoteConfigDiagnosticsStatus.error,
      errorMessage: state.message,
    );
  }
  return const RemoteConfigDiagnosticsViewData(
    status: RemoteConfigDiagnosticsStatus.idle,
  );
}
