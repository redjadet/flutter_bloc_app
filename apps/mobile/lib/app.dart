import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/app/composition/app_scope_dependencies.dart';
import 'package:flutter_bloc_app/app/router/go_router_refresh_stream.dart';
import 'package:go_router/go_router.dart' show GoRouter;

/// Main application widget
class const MyApp({
  required final GoRouter router,
  required final AppScopeDependencies dependencies,
  final GoRouterRefreshStream? authRefresh,
  super.key,
}) extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => AppScope(
    router: widget.router,
    dependencies: widget.dependencies,
  );

  @override
  void dispose() {
    widget.authRefresh?.dispose();
    super.dispose();
  }
}
