import 'package:flutter/foundation.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
import 'package:flutter_bloc_app/features/agent_comms_demo/agent_comms_demo.dart';
import 'package:go_router/go_router.dart';

/// Developer-only agent communication layer demo (blocked in prod / release).
RouteBase createAgentCommsDemoRoute(AgentCommsDemoRouteFactory factory) =>
    factory.createRoute();

class const AgentCommsDemoRouteFactory({
  required final AgentEngineSession Function() createSession,
  final TrustedNativeHelper trustedHelper = const NoOpTrustedNativeHelper(),
}) {
  RouteBase createRoute() => RouteScopedPage.routeWithCubit<AgentCommsCubit>(
    path: AppRoutes.agentCommsDemoPath,
    name: AppRoutes.agentCommsDemo,
    redirect: (_, _) {
      if (kReleaseMode || FlavorManager.I.isProd) {
        return AppRoutes.counterPath;
      }
      return null;
    },
    create: (_, _) =>
        AgentCommsCubit(session: createSession(), trustedHelper: trustedHelper),
    child: const AgentCommsDemoPage(),
  );
}
