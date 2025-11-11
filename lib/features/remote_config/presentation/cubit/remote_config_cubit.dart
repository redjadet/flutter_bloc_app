import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';

part 'remote_config_state.dart';

class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  RemoteConfigCubit(this._remoteConfigService) : super(RemoteConfigInitial());

  final RemoteConfigService _remoteConfigService;

  Future<void> initialize() async {
    await _remoteConfigService.initialize();
    await fetchValues();
  }

  Future<void> fetchValues() async {
    if (isClosed) return;
    await _remoteConfigService.forceFetch();
    if (isClosed) return;
    emit(
      RemoteConfigLoaded(
        isAwesomeFeatureEnabled: _remoteConfigService.getBool(
          'awesome_feature_enabled',
        ),
      ),
    );
  }
}
