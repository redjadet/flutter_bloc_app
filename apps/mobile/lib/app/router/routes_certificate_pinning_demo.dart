import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/utils/bloc_provider_helpers.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/reset_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/select_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/trigger_secure_probe.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/cubit/certificate_pinning_demo_cubit.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/pages/certificate_pinning_demo_page.dart';
import 'package:go_router/go_router.dart';
import 'package:networking/networking.dart';

/// Developer-only certificate pinning demo (blocked in prod / release).
RouteBase createCertificatePinningDemoRoute() => GoRoute(
  path: AppRoutes.certificatePinningDemoPath,
  name: AppRoutes.certificatePinningDemo,
  redirect: (final context, final state) {
    if (kReleaseMode || FlavorManager.I.isProd) {
      return AppRoutes.counterPath;
    }
    return null;
  },
  builder: (final context, final state) =>
      BlocProviderHelpers.withAsyncInit<CertificatePinningDemoCubit>(
        create: () => CertificatePinningDemoCubit(
          config: getIt<CertificatePinningConfig>(),
          scenarioController: getIt<MockCertificateScenarioController>(),
          logger: getIt<CertificatePinningLogger>(),
          triggerSecureProbe: getIt<TriggerSecureProbe>(),
          selectMockScenario: getIt<SelectMockScenario>(),
          resetMockScenario: getIt<ResetMockScenario>(),
        ),
        init: (final cubit) async => cubit.refreshSnapshot(),
        child: const CertificatePinningDemoPage(),
      ),
);
