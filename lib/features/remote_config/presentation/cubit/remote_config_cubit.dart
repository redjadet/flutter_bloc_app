import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/data/repositories/remote_config_repository.dart';

part 'remote_config_state.dart';

class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  RemoteConfigCubit(this._remoteConfigRepository)
    : super(RemoteConfigInitial());

  final RemoteConfigRepository _remoteConfigRepository;

  Future<void> initialize() async {
    await _remoteConfigRepository.initialize();
    await fetchValues();
  }

  Future<void> fetchValues() async {
    if (isClosed) return;
    await _remoteConfigRepository.forceFetch();
    if (isClosed) return;
    emit(
      RemoteConfigLoaded(
        isAwesomeFeatureEnabled: _remoteConfigRepository.getBool(
          'awesome_feature_enabled',
        ),
      ),
    );
  }
}
