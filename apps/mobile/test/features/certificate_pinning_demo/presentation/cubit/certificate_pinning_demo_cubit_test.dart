import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/secure_probe_repository.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/reset_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/select_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/trigger_secure_probe.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/cubit/certificate_pinning_demo_cubit.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/cubit/certificate_pinning_demo_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';

class _MockProbeRepo extends Mock implements SecureProbeRepository {}

void main() {
  late MockCertificateScenarioController scenarios;
  late CertificatePinningLogger logger;
  late _MockProbeRepo repo;
  late CertificatePinningConfig config;

  setUp(() {
    scenarios = MockCertificateScenarioController();
    logger = CertificatePinningLogger();
    repo = _MockProbeRepo();
    config = CertificatePinningConfig.disabled();
  });

  CertificatePinningDemoCubit buildCubit() => CertificatePinningDemoCubit(
    config: config,
    scenarioController: scenarios,
    logger: logger,
    triggerSecureProbe: TriggerSecureProbe(repo),
    selectMockScenario: SelectMockScenario(scenarios),
    resetMockScenario: ResetMockScenario(scenarios),
  );

  blocTest<CertificatePinningDemoCubit, CertificatePinningDemoState>(
    'selectScenario updates scenario and resets status',
    build: buildCubit,
    act: (final cubit) =>
        cubit.selectScenario(MockCertificateScenario.invalidPin),
    expect: () => <Matcher>[
      isA<CertificatePinningDemoState>().having(
        (final s) => s.scenario,
        'scenario',
        MockCertificateScenario.invalidPin,
      ),
    ],
  );

  blocTest<CertificatePinningDemoCubit, CertificatePinningDemoState>(
    'triggerProbe emits validating then success',
    build: buildCubit,
    setUp: () {
      when(() => repo.probe()).thenAnswer(
        (final _) async => const SecureProbeSuccess(
          matchKind: CertificatePinMatchKind.primary,
        ),
      );
    },
    act: (final cubit) => cubit.triggerProbe(),
    expect: () => <Matcher>[
      isA<CertificatePinningDemoState>().having(
        (final s) => s.status,
        'status',
        CertificatePinningDemoStatus.validating,
      ),
      isA<CertificatePinningDemoState>()
          .having(
            (final s) => s.status,
            'status',
            CertificatePinningDemoStatus.success,
          )
          .having(
            (final s) => s.matchKind,
            'matchKind',
            CertificatePinMatchKind.primary,
          ),
    ],
  );

  blocTest<CertificatePinningDemoCubit, CertificatePinningDemoState>(
    'triggerProbe emits safe failure without raw details',
    build: buildCubit,
    setUp: () {
      when(() => repo.probe()).thenAnswer(
        (final _) async => const SecureProbeFailure(
          CertificatePinningDemoPinFailure(l10nCode: 'pinMismatch'),
        ),
      );
    },
    act: (final cubit) => cubit.triggerProbe(),
    expect: () => <Matcher>[
      isA<CertificatePinningDemoState>().having(
        (final s) => s.status,
        'status',
        CertificatePinningDemoStatus.validating,
      ),
      isA<CertificatePinningDemoState>()
          .having(
            (final s) => s.status,
            'status',
            CertificatePinningDemoStatus.failure,
          )
          .having((final s) => s.failure?.l10nCode, 'l10nCode', 'pinMismatch'),
    ],
  );

  test('mock validator logs do not include full pins', () async {
    final MockCertificatePinValidator mock = MockCertificatePinValidator(
      scenarioController: scenarios,
      validationTimeout: const Duration(milliseconds: 5),
      logger: logger,
      delay: (final _) async {},
    );
    await mock.validate(
      host: 'demo.local',
      port: 443,
      certificateBytes: Uint8List.fromList(<int>[1, 2, 3]),
    );
    expect(logger.entries, isNotEmpty);
    expect(logger.entries.first.displayLine.contains('sha256/'), isFalse);
  });
}
