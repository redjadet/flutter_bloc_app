import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_config_view_data.freezed.dart';

enum RemoteConfigViewStatus { idle, loading, loaded, error }

@freezed
abstract class RemoteConfigViewData with _$RemoteConfigViewData {
  const factory RemoteConfigViewData({
    required final RemoteConfigViewStatus status,
    final String? errorMessage,
    @Default(false) final bool isAwesomeFeatureEnabled,
    final String? testValue,
    final String? dataSource,
    final DateTime? lastSyncedAt,
  }) = _RemoteConfigViewData;

  const RemoteConfigViewData._();

  factory RemoteConfigViewData.fromState(final RemoteConfigState state) {
    if (state is RemoteConfigLoading) {
      return const RemoteConfigViewData(
        status: RemoteConfigViewStatus.loading,
      );
    }
    if (state is RemoteConfigLoaded) {
      return RemoteConfigViewData(
        status: RemoteConfigViewStatus.loaded,
        isAwesomeFeatureEnabled: state.isAwesomeFeatureEnabled,
        testValue: state.testValue,
        dataSource: state.dataSource,
        lastSyncedAt: state.lastSyncedAt,
      );
    }
    if (state is RemoteConfigError) {
      return RemoteConfigViewData(
        status: RemoteConfigViewStatus.error,
        errorMessage: state.message,
      );
    }
    return const RemoteConfigViewData(
      status: RemoteConfigViewStatus.idle,
    );
  }

  bool get showFlagStatus => status == RemoteConfigViewStatus.loaded;
  bool get showTestValue => status == RemoteConfigViewStatus.loaded;
  bool get isLoading => status == RemoteConfigViewStatus.loading;
  bool get showMetadata => dataSource != null || lastSyncedAt != null;
}
