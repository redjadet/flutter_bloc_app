import 'package:flutter_bloc_app/app/router/route_groups.dart';
import 'package:flutter_bloc_app/app/router/routes_core.dart';
import 'package:flutter_bloc_app/app/router/routes_demos.dart';
import 'package:go_router/go_router.dart';

/// Creates the list of application routes with async init where needed.
List<GoRoute> createAppRoutes() => <GoRoute>[
  ...createCoreRoutes(),
  ...createDemoRoutes(),
  ...createAuxiliaryRoutes(),
];
