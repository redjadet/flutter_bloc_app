import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/carrier_line_demo.dart';
import 'package:go_router/go_router.dart';
import 'package:utilities/utilities.dart';

RouteBase createCarrierLineDemoRoute(CarrierLineDemoRouteFactory factory) =>
    factory.createRoute();

class const CarrierLineDemoRouteFactory({
  required final CarrierInboxRepository inboxRepository,
  required final CarrierRealtimeClient Function() createRealtimeClient,
  required final LineStatusRepository lineStatusRepository,
  required final FcmMessagingService fcmMessagingService,
}) {
  RouteBase createRoute() => RouteScopedPage.routeWithCubit<CarrierLineCubit>(
    path: AppRoutes.carrierLineDemoPath,
    name: AppRoutes.carrierLineDemo,
    redirect: (_, _) {
      // Demo-only surface: keep out of prod/release exposure.
      if (kReleaseMode || FlavorManager.I.isProd) {
        return AppRoutes.counterPath;
      }
      return null;
    },
    create: (_, _) => CarrierLineCubit(
      inboxRepository: inboxRepository,
      realtimeClient: createRealtimeClient(),
      lineStatusRepository: lineStatusRepository,
      fcmMessagingService: fcmMessagingService,
    ),
    init: (CarrierLineCubit cubit) => cubit.start(),
    child: const CarrierLineDemoPage(),
  );
}
