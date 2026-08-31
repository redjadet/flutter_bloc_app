import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/reset_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/select_mock_scenario.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/use_cases/trigger_secure_probe.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/cubit/certificate_pinning_demo_cubit.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/presentation/pages/certificate_pinning_demo_page.dart';
import 'package:go_router/go_router.dart';
import 'package:networking/networking.dart';

/// Developer-only certificate pinning demo (blocked in prod / release).
RouteBase createCertificatePinningDemoRoute(
  CertificatePinningDemoRouteFactory factory,
) => factory.createRoute();

class const CertificatePinningDemoRouteFactory({
  required final CertificatePinningConfig config,
  required final MockCertificateScenarioController scenarioController,
  required final CertificatePinningLogger logger,
  required final TriggerSecureProbe triggerSecureProbe,
  required final SelectMockScenario selectMockScenario,
  required final ResetMockScenario resetMockScenario,
}) {
  RouteBase createRoute() =>
      RouteScopedPage.routeWithCubit<CertificatePinningDemoCubit>(
        path: AppRoutes.certificatePinningDemoPath,
        name: AppRoutes.certificatePinningDemo,
        redirect: (_, _) {
          if (kReleaseMode || FlavorManager.I.isProd) {
            return AppRoutes.counterPath;
          }
          return null;
        },
        create: (_, _) => CertificatePinningDemoCubit(
          config: config,
          scenarioController: scenarioController,
          logger: logger,
          triggerSecureProbe: triggerSecureProbe,
          selectMockScenario: selectMockScenario,
          resetMockScenario: resetMockScenario,
        ),
        init: (cubit) async => cubit.refreshSnapshot(),
        child: const CertificatePinningDemoPage(),
      );
}
