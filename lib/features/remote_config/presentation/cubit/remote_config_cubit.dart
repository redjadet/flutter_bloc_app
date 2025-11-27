import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

part 'remote_config_state.dart';

class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  RemoteConfigCubit(this._remoteConfigService)
    : super(const RemoteConfigInitial());

  static const String _awesomeFeatureKey = 'awesome_feature_enabled';
  static const String _testValueKey = 'test_value_1';
  static const String _dataSourceKey = 'last_data_source';
  static const String _lastSyncedKey = 'last_synced_at';

  final RemoteConfigService _remoteConfigService;

  Future<void> initialize() async {
    await _loadRemoteConfig(
      logContext: 'RemoteConfigCubit.initialize',
      setup: _remoteConfigService.initialize,
      showLoading: true,
    );
  }

  Future<void> fetchValues() async {
    await _loadRemoteConfig(
      logContext: 'RemoteConfigCubit.fetchValues',
      showLoading: state is! RemoteConfigLoading,
    );
  }

  bool _isLoading = false;

  Future<void> _loadRemoteConfig({
    required final String logContext,
    Future<void> Function()? setup,
    bool showLoading = false,
  }) async {
    if (isClosed || _isLoading) return;
    _isLoading = true;
    if (showLoading) {
      emit(const RemoteConfigLoading());
    }

    try {
      await CubitExceptionHandler.executeAsyncVoid(
        operation: () async {
          if (setup != null) {
            await setup();
          }
          await _remoteConfigService.forceFetch();
        },
        logContext: logContext,
        onSuccess: _emitLoadedState,
        onError: (final String message) {
          if (isClosed) return;
          emit(RemoteConfigError(message));
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  void _emitLoadedState() {
    if (isClosed) return;
    final String dataSource = _remoteConfigService.getString(_dataSourceKey);
    final String lastSyncedRaw = _remoteConfigService.getString(_lastSyncedKey);
    final DateTime? lastSyncedAt = lastSyncedRaw.isEmpty
        ? null
        : DateTime.tryParse(lastSyncedRaw)?.toUtc();
    emit(
      RemoteConfigLoaded(
        isAwesomeFeatureEnabled: _remoteConfigService.getBool(
          _awesomeFeatureKey,
        ),
        testValue: _remoteConfigService.getString(_testValueKey),
        dataSource: dataSource.isEmpty ? null : dataSource,
        lastSyncedAt: lastSyncedAt,
      ),
    );
  }
}
