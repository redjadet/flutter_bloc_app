import 'package:flutter_bloc_app/app/router/app_routes.dart';
import 'package:flutter_bloc_app/app/router/route_scoped_page.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/domain/secure_core_repository.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/cubit/secure_messaging_demo_cubit.dart';
import 'package:flutter_bloc_app/features/secure_messaging_demo/presentation/pages/secure_messaging_demo_page.dart';
import 'package:go_router/go_router.dart';

RouteBase createSecureMessagingDemoRoute(
  SecureMessagingDemoRouteFactory factory,
) => factory.createRoute();

class const SecureMessagingDemoRouteFactory({
  required final SecureCoreRepository repository,
}) {
  RouteBase createRoute() =>
      RouteScopedPage.routeWithCubit<SecureMessagingDemoCubit>(
        path: AppRoutes.secureMessagingDemoPath,
        name: AppRoutes.secureMessagingDemo,
        create: (_, _) => SecureMessagingDemoCubit(repository: repository),
        init: (cubit) => cubit.initialize(),
        child: const SecureMessagingDemoPage(),
      );
}
