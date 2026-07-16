import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/firebase_app_check_attestation_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_showcase_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_certificate_pin_policy_summary_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/probe_app_check_attestation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/run_native_security_operation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_security_showcase_section.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

import '../../../../test_helpers.dart';

class _FakeNativeSecurityShowcaseService
    implements NativeSecurityShowcaseService {
  _FakeNativeSecurityShowcaseService({required this.result});

  final NativeSecurityOperationResult result;
  final List<NativeSecurityOperation> invocations = <NativeSecurityOperation>[];

  @override
  Future<NativeSecurityOperationResult> run(
    final NativeSecurityOperation operation,
  ) async {
    invocations.add(operation);
    return result;
  }
}

class _FakeFirebaseAppCheckAttestationService
    implements FirebaseAppCheckAttestationService {
  @override
  Future<AppCheckAttestationResult> probeCachedToken() async =>
      const AppCheckAttestationResult(
        status: AppCheckAttestationStatus.unavailable,
        providerLabel: 'none',
        reasonCode: 'not_configured_or_token_null',
      );
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

NativeSecurityShowcaseCubit _buildCubit({
  required final NativeSecurityOperationResult operationResult,
  final bool canOpenMutableDemo = false,
}) => NativeSecurityShowcaseCubit(
  runOperation: RunNativeSecurityOperationUseCase(
    _FakeNativeSecurityShowcaseService(result: operationResult),
  ),
  probeAppCheck: ProbeAppCheckAttestationUseCase(
    _FakeFirebaseAppCheckAttestationService(),
  ),
  loadCertSummary: const LoadCertificatePinPolicySummaryUseCase(
    _fakeCertificateSummary,
  ),
  pinningConfig: CertificatePinningConfig.disabled(),
  canOpenMutableDemo: canOpenMutableDemo,
);

Widget _pumpableSection(final NativeSecurityShowcaseCubit cubit) =>
    wrapWithProviders(
      child: BlocProvider<NativeSecurityShowcaseCubit>.value(
        value: cubit,
        child: const SingleChildScrollView(
          child: NativeSecurityShowcaseSection(),
        ),
      ),
    );

void main() {
  group('NativeSecurityShowcaseSection', () {
    const unavailableResult = NativeSecurityOperationResult(
      status: NativeSecurityStatus.unavailable,
      reasonCode: 'mobile_only',
      platform: 'unknown',
    );

    testWidgets('shows the section and all five card keys', (
      final tester,
    ) async {
      final cubit = _buildCubit(operationResult: unavailableResult);
      addTearDown(cubit.close);

      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('native-security-showcase-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('native-security-card-crypto')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('native-security-card-certificate')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('native-security-card-storage')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('native-security-card-app-check')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('native-security-card-biometric')),
        findsOneWidget,
      );
    });

    testWidgets('crypto card shows two separate run buttons', (
      final tester,
    ) async {
      final cubit = _buildCubit(operationResult: unavailableResult);
      addTearDown(cubit.close);

      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('native-security-run-crypto')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('native-security-run-aes')),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping run-crypto shows the mobile-only outcome off native platforms',
      (final tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        final cubit = _buildCubit(operationResult: unavailableResult);
        addTearDown(cubit.close);

        await tester.pumpWidget(_pumpableSection(cubit));
        await tester.pump();

        await tester.tap(
          find.byKey(const ValueKey<String>('native-security-run-crypto')),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining(l10n.nativeSecurityStatusUnavailable),
          findsWidgets,
        );
      },
    );

    testWidgets('certificate card hides the open-demo button when disabled', (
      final tester,
    ) async {
      final cubit = _buildCubit(
        operationResult: unavailableResult,
        canOpenMutableDemo: false,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey<String>('native-security-open-certificate-demo'),
        ),
        findsNothing,
      );
    });

    testWidgets('certificate card shows the open-demo button when enabled', (
      final tester,
    ) async {
      final cubit = _buildCubit(
        operationResult: unavailableResult,
        canOpenMutableDemo: true,
      );
      addTearDown(cubit.close);

      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey<String>('native-security-open-certificate-demo'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('never renders raw secret-looking material', (
      final tester,
    ) async {
      const successResult = NativeSecurityOperationResult(
        status: NativeSecurityStatus.success,
        reasonCode: 'ok',
        platform: 'android',
        hardwareBacked: true,
        algorithm: 'P256',
        verified: true,
      );
      final cubit = _buildCubit(operationResult: successResult);
      addTearDown(cubit.close);

      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey<String>('native-security-run-crypto')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('native-security-run-storage')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('native-security-run-storage')),
      );
      await tester.pumpAndSettle();

      final Iterable<Text> texts = tester
          .widgetList<Text>(find.byType(Text))
          .where((final widget) => widget.data != null);
      for (final Text text in texts) {
        expect(text.data, isNot(contains('-----BEGIN')));
        expect(text.data!.length, lessThan(200));
      }
    });

    testWidgets('keeps all five cards on compact and wide surfaces', (
      final tester,
    ) async {
      final cubit = _buildCubit(operationResult: unavailableResult);
      addTearDown(cubit.close);

      Future<void> assertCardsVisible() async {
        for (final String key in <String>[
          'native-security-card-crypto',
          'native-security-card-certificate',
          'native-security-card-storage',
          'native-security-card-app-check',
          'native-security-card-biometric',
        ]) {
          expect(find.byKey(ValueKey<String>(key)), findsOneWidget);
        }
      }

      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();
      await assertCardsVisible();

      await tester.binding.setSurfaceSize(const Size(1024, 900));
      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();
      await assertCardsVisible();

      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('App Check setup-needed state shows Console guidance', (
      final tester,
    ) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final cubit = _buildCubit(operationResult: unavailableResult);
      addTearDown(cubit.close);

      await tester.pumpWidget(_pumpableSection(cubit));
      await tester.pump();

      expect(
        find.textContaining(l10n.nativeSecurityAppCheckIdleHint),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('native-security-run-app-check')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('native-security-run-app-check')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('native-security-app-check-setup-needed'),
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(l10n.nativeSecurityAppCheckStatusSetupNeeded),
        findsOneWidget,
      );
      expect(
        find.textContaining(l10n.nativeSecurityAppCheckSetupGuidance),
        findsOneWidget,
      );
      expect(find.textContaining('-----BEGIN'), findsNothing);
    });
  });
}
