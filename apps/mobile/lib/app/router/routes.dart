import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:go_router/go_router.dart';

class const AppRouteFactories({
  required final CoreRouteFactory core,
  required final AuxiliaryRouteFactory auxiliary,
  required final DemoRouteFactory demo,
});

/// Creates the list of application routes with async init where needed.
List<RouteBase> createAppRoutes(AppRouteFactories factories) => <RouteBase>[
  ...createCoreRoutes(factories.core),
  ...createDemoRoutes(factories.demo),
  ...createAuxiliaryRoutes(factories.auxiliary),
  createCounterRoute(factories.core),
];
