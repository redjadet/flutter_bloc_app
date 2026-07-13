import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/secure_probe_repository.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/reset_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/select_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/trigger_secure_probe.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/cubit/certificate_pinning_demo_state.dart';
import 'package:networking/networking.dart';

class CertificatePinningDemoCubit extends Cubit<CertificatePinningDemoState> {
  CertificatePinningDemoCubit({
    required final CertificatePinningConfig config,
    required final MockCertificateScenarioController scenarioController,
    required final CertificatePinningLogger logger,
    required this._triggerSecureProbe,
    required this._selectMockScenario,
    required this._resetMockScenario,
  }) : _config = config,
       _scenarioController = scenarioController,
       _logger = logger,
       super(
         CertificatePinningDemoState(
           mode: config.mode,
           scenario: scenarioController.scenario,
           logLines: logger.entries.map((final e) => e.displayLine).toList(),
         ),
       );

  final CertificatePinningConfig _config;
  final MockCertificateScenarioController _scenarioController;
  final CertificatePinningLogger _logger;
  final TriggerSecureProbe _triggerSecureProbe;
  final SelectMockScenario _selectMockScenario;
  final ResetMockScenario _resetMockScenario;

  void refreshSnapshot() {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        mode: _config.mode,
        scenario: _scenarioController.scenario,
        logLines: _logger.entries.map((final e) => e.displayLine).toList(),
      ),
    );
  }

  void selectScenario(final MockCertificateScenario scenario) {
    _selectMockScenario(scenario);
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        scenario: scenario,
        status: CertificatePinningDemoStatus.initial,
        clearFailure: true,
        clearMatch: true,
      ),
    );
  }

  void resetScenario() {
    _resetMockScenario();
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        scenario: _scenarioController.scenario,
        status: CertificatePinningDemoStatus.initial,
        clearFailure: true,
        clearMatch: true,
      ),
    );
  }

  void clearLogs() {
    _logger.clear();
    if (isClosed) {
      return;
    }
    emit(state.copyWith(logLines: const <String>[]));
  }

  Future<void> triggerProbe() async {
    if (isClosed) {
      return;
    }
    emit(
      state.copyWith(
        status: CertificatePinningDemoStatus.validating,
        clearFailure: true,
        clearMatch: true,
      ),
    );

    final SecureProbeOutcome outcome = await _triggerSecureProbe();
    if (isClosed) {
      return;
    }

    final List<String> logs = _logger.entries
        .map((final e) => e.displayLine)
        .toList();

    switch (outcome) {
      case SecureProbeSuccess(:final matchKind):
        emit(
          state.copyWith(
            status: CertificatePinningDemoStatus.success,
            matchKind: matchKind,
            logLines: logs,
            clearFailure: true,
          ),
        );
      case SecureProbeFailure(:final failure):
        emit(
          state.copyWith(
            status: CertificatePinningDemoStatus.failure,
            failure: failure,
            logLines: logs,
            clearMatch: true,
          ),
        );
    }
  }
}
