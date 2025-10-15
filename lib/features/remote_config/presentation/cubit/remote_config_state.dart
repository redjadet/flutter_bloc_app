part of 'remote_config_cubit.dart';

abstract class RemoteConfigState extends Equatable {
  const RemoteConfigState();

  @override
  List<Object> get props => [];
}

class RemoteConfigInitial extends RemoteConfigState {}

class RemoteConfigLoaded extends RemoteConfigState {
  const RemoteConfigLoaded({required this.isAwesomeFeatureEnabled});

  final bool isAwesomeFeatureEnabled;

  @override
  List<Object> get props => [isAwesomeFeatureEnabled];
}
