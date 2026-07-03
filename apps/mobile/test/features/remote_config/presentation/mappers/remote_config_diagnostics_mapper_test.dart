import 'package:flutter_bloc_app/core/diagnostics/remote_config_diagnostics_view_data.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_state.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/mappers/remote_config_diagnostics_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapRemoteConfigStateToDiagnosticsViewData', () {
    test('maps loading, loaded, error, and initial', () {
      expect(
        mapRemoteConfigStateToDiagnosticsViewData(
          const RemoteConfigState.loading(),
        ).status,
        RemoteConfigDiagnosticsStatus.loading,
      );

      final RemoteConfigDiagnosticsViewData loaded =
          mapRemoteConfigStateToDiagnosticsViewData(
            const RemoteConfigState.loaded(
              isAwesomeFeatureEnabled: true,
              testValue: 'x',
              dataSource: 'remote',
            ),
          );
      expect(loaded.status, RemoteConfigDiagnosticsStatus.loaded);
      expect(loaded.isAwesomeFeatureEnabled, isTrue);
      expect(loaded.testValue, 'x');
      expect(loaded.dataSource, 'remote');

      final RemoteConfigDiagnosticsViewData err =
          mapRemoteConfigStateToDiagnosticsViewData(
            const RemoteConfigState.error('oops'),
          );
      expect(err.status, RemoteConfigDiagnosticsStatus.error);
      expect(err.errorMessage, 'oops');

      expect(
        mapRemoteConfigStateToDiagnosticsViewData(
          const RemoteConfigState.initial(),
        ).status,
        RemoteConfigDiagnosticsStatus.idle,
      );
    });
  });
}
