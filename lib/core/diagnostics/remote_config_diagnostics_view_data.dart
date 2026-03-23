import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_diagnostics_view_data.freezed.dart';

/// Presentation-neutral snapshot for remote-config diagnostics (settings QA, etc.).
/// Mapped from the remote_config feature's cubit state.
enum RemoteConfigDiagnosticsStatus { idle, loading, loaded, error }

@freezed
abstract class RemoteConfigDiagnosticsViewData
    with _$RemoteConfigDiagnosticsViewData {
  const factory RemoteConfigDiagnosticsViewData({
    required final RemoteConfigDiagnosticsStatus status,
    final String? errorMessage,
    @Default(false) final bool isAwesomeFeatureEnabled,
    final String? testValue,
    final String? dataSource,
    final DateTime? lastSyncedAt,
  }) = _RemoteConfigDiagnosticsViewData;

  const RemoteConfigDiagnosticsViewData._();

  bool get showFlagStatus => status == RemoteConfigDiagnosticsStatus.loaded;
  bool get showTestValue => status == RemoteConfigDiagnosticsStatus.loaded;
  bool get isLoading => status == RemoteConfigDiagnosticsStatus.loading;
  bool get showMetadata => dataSource != null || lastSyncedAt != null;
}
