part of 'remote_config_diagnostics_section.dart';

class _StatusPalette {
  const _StatusPalette({
    required this.background,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color background;
  final Color color;
  final IconData icon;
  final String label;
}

enum _RemoteConfigStatus { idle, loading, loaded, error }

class _RemoteConfigViewData extends Equatable {
  const _RemoteConfigViewData({
    required this.status,
    this.errorMessage,
    this.isAwesomeFeatureEnabled = false,
    this.testValue,
  });

  factory _RemoteConfigViewData.fromState(final RemoteConfigState state) {
    if (state is RemoteConfigLoading) {
      return const _RemoteConfigViewData(status: _RemoteConfigStatus.loading);
    }
    if (state is RemoteConfigLoaded) {
      return _RemoteConfigViewData(
        status: _RemoteConfigStatus.loaded,
        isAwesomeFeatureEnabled: state.isAwesomeFeatureEnabled,
        testValue: state.testValue,
      );
    }
    if (state is RemoteConfigError) {
      return _RemoteConfigViewData(
        status: _RemoteConfigStatus.error,
        errorMessage: state.message,
      );
    }
    return const _RemoteConfigViewData(status: _RemoteConfigStatus.idle);
  }

  final _RemoteConfigStatus status;
  final String? errorMessage;
  final bool isAwesomeFeatureEnabled;
  final String? testValue;

  bool get showFlagStatus => status == _RemoteConfigStatus.loaded;
  bool get showTestValue => status == _RemoteConfigStatus.loaded;
  bool get isLoading => status == _RemoteConfigStatus.loading;

  @override
  List<Object?> get props => <Object?>[
    status,
    errorMessage,
    isAwesomeFeatureEnabled,
    testValue,
  ];
}
