import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_keys.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_state.dart';

export 'remote_config_state.dart';

class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  RemoteConfigCubit(this._remoteConfigService)
    : super(const RemoteConfigState.initial());

  final RemoteConfigService _remoteConfigService;
  bool _hasInitialized = false;
  Future<void>? _initializationFuture;

  Future<void> ensureInitialized() {
    if (_hasInitialized) {
      return Future.value();
    }
    final Future<void>? inFlight = _initializationFuture;
    if (inFlight != null) {
      return inFlight;
    }
    late final Future<void> loadFuture;
    loadFuture = initialize().whenComplete(() {
      if (identical(_initializationFuture, loadFuture)) {
        _initializationFuture = null;
      }
    });
    _initializationFuture = loadFuture;
    return loadFuture;
  }

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

  Future<void> clearCache() async {
    await _loadRemoteConfig(
      logContext: 'RemoteConfigCubit.clearCache',
      showLoading: true,
      preFetch: _remoteConfigService.clearCache,
    );
  }

  bool _isLoading = false;

  Future<void> _loadRemoteConfig({
    required final String logContext,
    final Future<void> Function()? setup,
    final Future<void> Function()? preFetch,
    final bool showLoading = false,
  }) async {
    if (isClosed || _isLoading) return;
    _isLoading = true;
    if (showLoading) {
      emit(const RemoteConfigState.loading());
    }

    try {
      await CubitExceptionHandler.executeAsyncVoid(
        operation: () async {
          if (setup != null) {
            await setup();
          }
          if (preFetch != null) {
            await preFetch();
          }
          await _remoteConfigService.forceFetch();
        },
        isAlive: () => !isClosed,
        logContext: logContext,
        onSuccess: _emitLoadedState,
        onError: (final message) {
          if (isClosed) return;
          emit(RemoteConfigState.error(message));
        },
      );
    } finally {
      _isLoading = false;
    }
  }

  void _emitLoadedState() {
    if (isClosed) return;
    _hasInitialized = true;
    final String dataSource = _remoteConfigService.getString(
      RemoteConfigKeys.lastDataSource,
    );
    final String lastSyncedRaw = _remoteConfigService.getString(
      RemoteConfigKeys.lastSyncedAt,
    );
    final DateTime? lastSyncedAt = lastSyncedRaw.isEmpty
        ? null
        : DateTime.tryParse(lastSyncedRaw)?.toUtc();
    emit(
      RemoteConfigState.loaded(
        isAwesomeFeatureEnabled: _remoteConfigService.getBool(
          RemoteConfigKeys.awesomeFeatureEnabled,
        ),
        testValue: _remoteConfigService.getString(RemoteConfigKeys.testValue1),
        dataSource: dataSource.isEmpty ? null : dataSource,
        lastSyncedAt: lastSyncedAt,
      ),
    );
  }
}
