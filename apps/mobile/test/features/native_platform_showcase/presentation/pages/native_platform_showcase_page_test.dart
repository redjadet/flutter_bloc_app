import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/certificate_pin_policy_summary.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_platform_info_repository.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/firebase_app_check_attestation_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_operation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_showcase_service.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_security_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/platform_showcase_data.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_certificate_pin_policy_summary_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/load_native_platform_showcase_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/probe_app_check_attestation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/run_native_security_operation_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/share_native_showcase_text_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/trigger_native_showcase_haptic_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/use_cases/watch_native_showcase_telemetry_use_case.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_security_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/pages/native_platform_showcase_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:networking/networking.dart';

import '../../../../test_helpers.dart';

class _TestNativeSecurityShowcaseCubit extends NativeSecurityShowcaseCubit {
  _TestNativeSecurityShowcaseCubit()
    : super(
        runOperation: RunNativeSecurityOperationUseCase(
          _UnavailableNativeSecurityShowcaseService(),
        ),
        probeAppCheck: ProbeAppCheckAttestationUseCase(
          _UnavailableFirebaseAppCheckAttestationService(),
        ),
        loadCertSummary: const LoadCertificatePinPolicySummaryUseCase(
          _fakeCertificateSummary,
        ),
        pinningConfig: CertificatePinningConfig.disabled(),
        canOpenMutableDemo: false,
      );

  static CertificatePinPolicySummary _fakeCertificateSummary(
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
}

class _UnavailableNativeSecurityShowcaseService
    implements NativeSecurityShowcaseService {
  @override
  Future<NativeSecurityOperationResult> run(
    final NativeSecurityOperation operation,
  ) async => const NativeSecurityOperationResult(
    status: NativeSecurityStatus.unavailable,
    reasonCode: 'mobile_only',
    platform: 'unknown',
  );
}

class _UnavailableFirebaseAppCheckAttestationService
    implements FirebaseAppCheckAttestationService {
  @override
  Future<AppCheckAttestationResult> probeCachedToken() async =>
      const AppCheckAttestationResult(
        status: AppCheckAttestationStatus.unavailable,
        providerLabel: 'none',
        reasonCode: 'not_configured_or_token_null',
      );
}

Widget _wrapWithSecurityProvider(final Widget child) =>
    BlocProvider<NativeSecurityShowcaseCubit>(
      create: (_) => _TestNativeSecurityShowcaseCubit(),
      child: child,
    );

class _TestNativePlatformShowcaseCubit extends NativePlatformShowcaseCubit {
  _TestNativePlatformShowcaseCubit({
    final WatchNativeShowcaseTelemetryUseCase? watchTelemetry,
  }) : super(
         loadShowcase: LoadNativePlatformShowcaseUseCase(_ThrowingRepository()),
         watchTelemetry:
             watchTelemetry ?? _EmptyWatchNativeShowcaseTelemetryUseCase(),
         triggerHaptic: _EmptyTriggerNativeShowcaseHapticUseCase(),
         shareText: _EmptyShareNativeShowcaseTextUseCase(),
       );

  void setState(final NativePlatformShowcaseState value) => emit(value);
}

class _EmptyWatchNativeShowcaseTelemetryUseCase
    implements WatchNativeShowcaseTelemetryUseCase {
  @override
  Stream<NativeShowcaseTelemetrySnapshot> call() => const Stream.empty();
}

class _EmptyTriggerNativeShowcaseHapticUseCase
    implements TriggerNativeShowcaseHapticUseCase {
  @override
  Future<NativeInteropCallResult> call() async => const NativeInteropCallResult(
    kind: NativeInteropBridgeKind.swift,
    status: NativeInteropStatus.unavailable,
    message: 'test',
  );
}

class _EmptyShareNativeShowcaseTextUseCase
    implements ShareNativeShowcaseTextUseCase {
  @override
  Future<NativeInteropCallResult> call(final String text) async =>
      const NativeInteropCallResult(
        kind: NativeInteropBridgeKind.swift,
        status: NativeInteropStatus.unavailable,
        message: 'test',
      );
}

class _ThrowingRepository implements NativePlatformInfoRepository {
  @override
  Future<PlatformShowcaseData> loadShowcase() {
    throw UnimplementedError();
  }
}

class _MockNativePlatformInfoRepository extends Mock
    implements NativePlatformInfoRepository {}

void main() {
  group('NativePlatformShowcasePage', () {
    final loadedData = PlatformShowcaseData(
      platform: AppPlatformKind.ios,
      capabilities: NativeCapabilityKind.values
          .map(
            (final kind) =>
                NativeCapability(kind: kind, platformDetail: 'detail-$kind'),
          )
          .toList(growable: false),
      interopResults: const <NativeInteropCallResult>[
        NativeInteropCallResult(
          kind: NativeInteropBridgeKind.swift,
          status: NativeInteropStatus.success,
          message: 'Hello from Swift',
        ),
        NativeInteropCallResult(
          kind: NativeInteropBridgeKind.kotlin,
          status: NativeInteropStatus.unavailable,
          message: 'Kotlin bridge not used on iOS',
        ),
        NativeInteropCallResult(
          kind: NativeInteropBridgeKind.cpp,
          status: NativeInteropStatus.success,
          message: 'Hello from C (3 + 4 = 7)',
        ),
      ],
    );

    testWidgets(
      'shows full runtime platform label on iOS portrait without overflow',
      (final tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final cubit = _TestNativePlatformShowcaseCubit()
          ..setState(NativePlatformShowcaseState.loaded(loadedData));

        await tester.pumpWidget(
          wrapWithProviders(
            child: Theme(
              data: ThemeData(platform: TargetPlatform.iOS),
              child: BlocProvider<NativePlatformShowcaseCubit>.value(
                value: cubit,
                child: _wrapWithSecurityProvider(
                  const NativePlatformShowcasePage(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(l10n.nativePlatformShowcaseRuntimePlatformLabel),
          findsOneWidget,
        );
        expect(
          find.text(l10n.nativePlatformShowcaseUiFamilyLabel),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('renders summary, lessons, and capability tiles when loaded', (
      final tester,
    ) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      tester.view.physicalSize = const Size(390, 6200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final cubit = _TestNativePlatformShowcaseCubit()
        ..setState(NativePlatformShowcaseState.loaded(loadedData));

      await tester.pumpWidget(
        wrapWithProviders(
          child: BlocProvider<NativePlatformShowcaseCubit>.value(
            value: cubit,
            child: _wrapWithSecurityProvider(
              const NativePlatformShowcasePage(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(l10n.nativePlatformShowcaseTitle), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('native-platform-showcase-summary')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.nativePlatformShowcaseInteropTitle),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('native-platform-showcase-interop-swift'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('native-platform-showcase-platform-view'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('native-platform-showcase-haptic-button'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('native-platform-showcase-lesson-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'native-platform-showcase-capability-nativeViewEmbedding',
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows error message when load fails', (final tester) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final cubit = _TestNativePlatformShowcaseCubit()
        ..setState(
          const NativePlatformShowcaseState.error(
            failure: NativePlatformShowcaseFailureKind.loadFailed,
          ),
        );

      await tester.pumpWidget(
        wrapWithProviders(
          child: BlocProvider<NativePlatformShowcaseCubit>.value(
            value: cubit,
            child: _wrapWithSecurityProvider(
              const NativePlatformShowcasePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.nativePlatformShowcaseLoadError), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('native-platform-showcase-retry')),
        findsOneWidget,
      );
    });

    testWidgets('retry tap calls load again after error', (final tester) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final repository = _MockNativePlatformInfoRepository();
      var attempts = 0;

      when(() => repository.loadShowcase()).thenAnswer((_) async {
        attempts += 1;
        if (attempts == 1) {
          throw Exception('fail');
        }
        return loadedData;
      });

      await tester.pumpWidget(
        wrapWithProviders(
          child: Theme(
            data: ThemeData.light().copyWith(
              splashFactory: NoSplash.splashFactory,
            ),
            child: BlocProvider(
              create: (_) => NativePlatformShowcaseCubit(
                loadShowcase: LoadNativePlatformShowcaseUseCase(repository),
                watchTelemetry: _EmptyWatchNativeShowcaseTelemetryUseCase(),
                triggerHaptic: _EmptyTriggerNativeShowcaseHapticUseCase(),
                shareText: _EmptyShareNativeShowcaseTextUseCase(),
              )..load(),
              child: _wrapWithSecurityProvider(
                const NativePlatformShowcasePage(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.nativePlatformShowcaseLoadError), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('native-platform-showcase-retry')),
      );
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text(l10n.nativePlatformShowcaseIntro), findsOneWidget);
    });

    testWidgets('shows telemetry section when loaded', (final tester) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      tester.view.physicalSize = const Size(390, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final cubit = _TestNativePlatformShowcaseCubit()
        ..setState(NativePlatformShowcaseState.loaded(loadedData));

      await tester.pumpWidget(
        wrapWithProviders(
          child: BlocProvider<NativePlatformShowcaseCubit>.value(
            value: cubit,
            child: _wrapWithSecurityProvider(
              const NativePlatformShowcasePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('native-platform-showcase-telemetry'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(l10n.nativePlatformShowcaseTelemetryTitle),
        findsOneWidget,
      );
    });

    testWidgets('renders streaming telemetry labels', (final tester) async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      tester.view.physicalSize = const Size(390, 6200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final cubit = _TestNativePlatformShowcaseCubit()
        ..setState(
          NativePlatformShowcaseState.loaded(
            loadedData,
            telemetry: NativeShowcaseTelemetrySnapshot(
              status: NativeShowcaseTelemetryStatus.streaming,
              sequence: 1,
              sampleCount: 12,
              averageValue: 42.5,
              sourceRateHz: 60,
              deliveredRateHz: 4,
              droppedCount: 3,
              emittedAt: _epoch,
            ),
          ),
        );

      await tester.pumpWidget(
        wrapWithProviders(
          child: BlocProvider<NativePlatformShowcaseCubit>.value(
            value: cubit,
            child: _wrapWithSecurityProvider(
              const NativePlatformShowcasePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.nativePlatformShowcaseTelemetrySourceRateLabel),
        findsOneWidget,
      );
      expect(
        find.text(l10n.nativePlatformShowcaseTelemetryDeliveredRateLabel),
        findsOneWidget,
      );
      expect(find.text('42.50'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('native-platform-showcase-summary')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('native-platform-showcase-interop-swift'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'unavailable telemetry keeps summary and interop sections visible',
      (final tester) async {
        final l10n = lookupAppLocalizations(const Locale('en'));
        tester.view.physicalSize = const Size(390, 6200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final cubit = _TestNativePlatformShowcaseCubit()
          ..setState(
            NativePlatformShowcaseState.loaded(
              loadedData,
              telemetry: NativeShowcaseTelemetrySnapshot(
                status: NativeShowcaseTelemetryStatus.unavailable,
                sequence: 0,
                sampleCount: 0,
                averageValue: 0,
                sourceRateHz: 0,
                deliveredRateHz: 0,
                droppedCount: 0,
                emittedAt: _epoch,
              ),
            ),
          );

        await tester.pumpWidget(
          wrapWithProviders(
            child: BlocProvider<NativePlatformShowcaseCubit>.value(
              value: cubit,
              child: _wrapWithSecurityProvider(
                const NativePlatformShowcasePage(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(l10n.nativePlatformShowcaseTelemetryUnavailable),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const ValueKey<String>('native-platform-showcase-summary'),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const ValueKey<String>('native-platform-showcase-interop-swift'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('failed telemetry keeps summary and interop sections visible', (
      final tester,
    ) async {
      tester.view.physicalSize = const Size(390, 6200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final cubit = _TestNativePlatformShowcaseCubit()
        ..setState(
          NativePlatformShowcaseState.loaded(
            loadedData,
            telemetry: NativeShowcaseTelemetrySnapshot(
              status: NativeShowcaseTelemetryStatus.failed,
              sequence: 1,
              sampleCount: 0,
              averageValue: 0,
              sourceRateHz: 60,
              deliveredRateHz: 4,
              droppedCount: 0,
              emittedAt: _epoch,
              message: 'Telemetry stream failed',
            ),
          ),
        );

      await tester.pumpWidget(
        wrapWithProviders(
          child: BlocProvider<NativePlatformShowcaseCubit>.value(
            value: cubit,
            child: _wrapWithSecurityProvider(
              const NativePlatformShowcasePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Telemetry stream failed'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('native-platform-showcase-summary')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('native-platform-showcase-interop-swift'),
        ),
        findsOneWidget,
      );
    });
  });
}

final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);
