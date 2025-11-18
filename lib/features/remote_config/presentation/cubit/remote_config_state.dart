part of 'remote_config_cubit.dart';

abstract class RemoteConfigState extends Equatable {
  const RemoteConfigState();

  @override
  List<Object?> get props => <Object?>[];
}

class RemoteConfigInitial extends RemoteConfigState {
  const RemoteConfigInitial();
}

class RemoteConfigLoading extends RemoteConfigState {
  const RemoteConfigLoading();
}

class RemoteConfigLoaded extends RemoteConfigState {
  const RemoteConfigLoaded({
    required this.isAwesomeFeatureEnabled,
    required this.testValue,
  });

  final bool isAwesomeFeatureEnabled;
  final String testValue;

  @override
  List<Object?> get props => <Object?>[isAwesomeFeatureEnabled, testValue];
}

class RemoteConfigError extends RemoteConfigState {
  const RemoteConfigError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
