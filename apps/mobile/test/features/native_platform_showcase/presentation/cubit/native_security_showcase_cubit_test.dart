import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_certificate_pin_policy_summary_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/probe_app_check_attestation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/run_native_security_operation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';

class _MockRunNativeSecurityOperationUseCase extends Mock
    implements RunNativeSecurityOperationUseCase {}

class _MockProbeAppCheckAttestationUseCase extends Mock
    implements ProbeAppCheckAttestationUseCase {}

void main() {
  group('NativeSecurityShowcaseCubit', () {
    late _MockRunNativeSecurityOperationUseCase runOperation;
    late _MockProbeAppCheckAttestationUseCase probeAppCheck;
    late CertificatePinningConfig pinningConfig;

    const successResult = NativeSecurityOperationResult(
      status: NativeSecurityStatus.success,
      reasonCode: 'ok',
      platform: 'android',
    );

    setUp(() {
      runOperation = _MockRunNativeSecurityOperationUseCase();
      probeAppCheck = _MockProbeAppCheckAttestationUseCase();
      pinningConfig = CertificatePinningConfig.disabled();
    });

    NativeSecurityShowcaseCubit buildCubit({
      final bool canOpenMutableDemo = false,
    }) => NativeSecurityShowcaseCubit(
      runOperation: runOperation,
      probeAppCheck: probeAppCheck,
      loadCertSummary: const LoadCertificatePinPolicySummaryUseCase(
        _fakeCertificateSummary,
      ),
      pinningConfig: pinningConfig,
      canOpenMutableDemo: canOpenMutableDemo,
    );

    test('constructor loads the certificate summary synchronously', () {
      final cubit = buildCubit(canOpenMutableDemo: true);
      addTearDown(cubit.close);

      expect(cubit.state.certificateSummary.canOpenMutableDemo, isTrue);
      expect(cubit.state.certificateSummary.modeName, pinningConfig.mode.name);
    });

    blocTest<NativeSecurityShowcaseCubit, NativeSecurityShowcaseState>(
      'runP256 sets inFlight then applies the result to p256Result only',
      build: () {
        when(
          () => runOperation(NativeSecurityOperation.p256SignVerify),
        ).thenAnswer((_) async => successResult);
        return buildCubit();
      },
      act: (final cubit) => cubit.runP256(),
      expect: () => <Matcher>[
        isA<NativeSecurityShowcaseState>().having(
          (final s) => s.inFlight,
          'inFlight',
          NativeSecurityOperation.p256SignVerify,
        ),
        isA<NativeSecurityShowcaseState>()
            .having((final s) => s.inFlight, 'inFlight', isNull)
            .having((final s) => s.p256Result, 'p256Result', successResult)
            .having((final s) => s.aesResult, 'aesResult', isNull),
      ],
    );

    blocTest<NativeSecurityShowcaseCubit, NativeSecurityShowcaseState>(
      'runAesGcm preserves a prior p256Result',
      build: () {
        when(
          () => runOperation(NativeSecurityOperation.p256SignVerify),
        ).thenAnswer((_) async => successResult);
        when(
          () => runOperation(NativeSecurityOperation.aesGcmRoundTrip),
        ).thenAnswer((_) async => successResult);
        return buildCubit();
      },
      act: (final cubit) async {
        await cubit.runP256();
        await cubit.runAesGcm();
      },
      verify: (final cubit) {
        expect(cubit.state.p256Result, successResult);
        expect(cubit.state.aesResult, successResult);
      },
    );

    test('ignores a duplicate run while an operation is in flight', () async {
      final completer = Completer<NativeSecurityOperationResult>();
      when(
        () => runOperation(NativeSecurityOperation.p256SignVerify),
      ).thenAnswer((_) => completer.future);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final first = cubit.runP256();
      final second = cubit.runP256();
      completer.complete(successResult);
      await Future.wait<void>(<Future<void>>[first, second]);

      verify(
        () => runOperation(NativeSecurityOperation.p256SignVerify),
      ).called(1);
    });

    test(
      'maps a throwing native operation to a failed outcome and clears busy',
      () async {
        when(
          () => runOperation(NativeSecurityOperation.secureStorageLifecycle),
        ).thenThrow(StateError('boom'));
        final cubit = buildCubit();
        addTearDown(cubit.close);

        await cubit.runSecureStorage();

        expect(cubit.state.inFlight, isNull);
        expect(cubit.state.isBusy, isFalse);
        expect(cubit.state.storageResult?.status, NativeSecurityStatus.failed);
        expect(cubit.state.storageResult?.reasonCode, 'platform_error');
      },
    );

    test('never emits after the cubit is closed', () async {
      final completer = Completer<NativeSecurityOperationResult>();
      when(
        () => runOperation(NativeSecurityOperation.secureStorageLifecycle),
      ).thenAnswer((_) => completer.future);
      final cubit = buildCubit();

      final states = <NativeSecurityShowcaseState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      final run = cubit.runSecureStorage();
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      completer.complete(successResult);
      await run;

      expect(states, hasLength(1));
      expect(
        states.single.inFlight,
        NativeSecurityOperation.secureStorageLifecycle,
      );
      expect(cubit.isClosed, isTrue);
    });

    blocTest<NativeSecurityShowcaseCubit, NativeSecurityShowcaseState>(
      'runAppCheck sets appCheckInFlight then stores the result',
      build: () {
        when(() => probeAppCheck()).thenAnswer(
          (_) async => const AppCheckAttestationResult(
            status: AppCheckAttestationStatus.issued,
            providerLabel: 'debug',
            reasonCode: 'ok',
          ),
        );
        return buildCubit();
      },
      act: (final cubit) => cubit.runAppCheck(),
      expect: () => <Matcher>[
        isA<NativeSecurityShowcaseState>().having(
          (final s) => s.appCheckInFlight,
          'appCheckInFlight',
          isTrue,
        ),
        isA<NativeSecurityShowcaseState>()
            .having(
              (final s) => s.appCheckInFlight,
              'appCheckInFlight',
              isFalse,
            )
            .having(
              (final s) => s.appCheckResult?.status,
              'appCheckResult.status',
              AppCheckAttestationStatus.issued,
            )
            .having((final s) => s.p256Result, 'p256Result', isNull),
      ],
    );

    test(
      'ignores a duplicate App Check probe while one is in flight',
      () async {
        final completer = Completer<AppCheckAttestationResult>();
        when(() => probeAppCheck()).thenAnswer((_) => completer.future);
        final cubit = buildCubit();
        addTearDown(cubit.close);

        final first = cubit.runAppCheck();
        final second = cubit.runAppCheck();
        completer.complete(
          const AppCheckAttestationResult(
            status: AppCheckAttestationStatus.issued,
            providerLabel: 'debug',
            reasonCode: 'ok',
          ),
        );
        await Future.wait<void>(<Future<void>>[first, second]);

        verify(() => probeAppCheck()).called(1);
      },
    );

    test('blocks crypto while App Check is in flight', () async {
      final completer = Completer<AppCheckAttestationResult>();
      when(() => probeAppCheck()).thenAnswer((_) => completer.future);
      when(
        () => runOperation(NativeSecurityOperation.p256SignVerify),
      ).thenAnswer((_) async => successResult);
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final appCheck = cubit.runAppCheck();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isBusy, isTrue);
      await cubit.runP256();
      completer.complete(
        const AppCheckAttestationResult(
          status: AppCheckAttestationStatus.issued,
          providerLabel: 'debug',
          reasonCode: 'ok',
        ),
      );
      await appCheck;

      verifyNever(() => runOperation(NativeSecurityOperation.p256SignVerify));
    });

    test('blocks App Check while a native op is in flight', () async {
      final completer = Completer<NativeSecurityOperationResult>();
      when(
        () => runOperation(NativeSecurityOperation.p256SignVerify),
      ).thenAnswer((_) => completer.future);
      when(() => probeAppCheck()).thenAnswer(
        (_) async => const AppCheckAttestationResult(
          status: AppCheckAttestationStatus.issued,
          providerLabel: 'debug',
          reasonCode: 'ok',
        ),
      );
      final cubit = buildCubit();
      addTearDown(cubit.close);

      final crypto = cubit.runP256();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.isBusy, isTrue);
      await cubit.runAppCheck();
      completer.complete(successResult);
      await crypto;

      verifyNever(() => probeAppCheck());
    });

    test(
      'maps a throwing App Check probe to failed without rethrowing',
      () async {
        when(() => probeAppCheck()).thenThrow(StateError('boom'));
        final cubit = buildCubit();
        addTearDown(cubit.close);

        await cubit.runAppCheck();

        expect(cubit.state.appCheckInFlight, isFalse);
        expect(
          cubit.state.appCheckResult?.status,
          AppCheckAttestationStatus.failed,
        );
        expect(cubit.state.appCheckResult?.reasonCode, 'app_check_error');
      },
    );

    blocTest<NativeSecurityShowcaseCubit, NativeSecurityShowcaseState>(
      'runBiometric applies its result to biometricResult only',
      build: () {
        when(
          () =>
              runOperation(NativeSecurityOperation.biometricProtectedOperation),
        ).thenAnswer(
          (_) async => const NativeSecurityOperationResult(
            status: NativeSecurityStatus.denied,
            reasonCode: 'biometric_canceled',
            platform: 'ios',
          ),
        );
        return buildCubit();
      },
      act: (final cubit) => cubit.runBiometric(),
      verify: (final cubit) {
        expect(
          cubit.state.biometricResult?.status,
          NativeSecurityStatus.denied,
        );
        expect(cubit.state.storageResult, isNull);
      },
    );

    blocTest<NativeSecurityShowcaseCubit, NativeSecurityShowcaseState>(
      'loadCertificateSummary refreshes the certificate summary',
      build: () => buildCubit(),
      act: (final cubit) => cubit.loadCertificateSummary(),
      expect: () => <Matcher>[
        isA<NativeSecurityShowcaseState>().having(
          (final s) => s.certificateSummary.modeName,
          'certificateSummary.modeName',
          pinningConfig.mode.name,
        ),
      ],
    );
  });
}

CertificatePinPolicySummary _fakeCertificateSummary(
  final CertificatePinningConfig config, {
  required final bool canOpenMutableDemo,
}) => CertificatePinPolicySummary(
  modeName: config.mode.name,
  pinHashKindName: config.pinHashKind.name,
  configuredHostCount: config.allowedHosts.length,
  primaryPinCount: 0,
  backupPinCount: 0,
  canOpenMutableDemo: canOpenMutableDemo,
);
