part of 'remote_config_cubit.dart';

sealed class RemoteConfigState extends Equatable {
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
    this.dataSource,
    this.lastSyncedAt,
  });

  final bool isAwesomeFeatureEnabled;
  final String testValue;
  final String? dataSource;
  final DateTime? lastSyncedAt;

  @override
  List<Object?> get props => <Object?>[
    isAwesomeFeatureEnabled,
    testValue,
    dataSource,
    lastSyncedAt,
  ];
}

class RemoteConfigError extends RemoteConfigState {
  const RemoteConfigError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
