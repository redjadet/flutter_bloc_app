import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/app/app_scope.dart';
import 'package:flutter_bloc_app/app/composition/app_scope_dependencies.dart';
import 'package:flutter_bloc_app/app/router/go_router_refresh_stream.dart';
import 'package:go_router/go_router.dart' show GoRouter;

/// Main application widget
class MyApp extends StatefulWidget {
  const MyApp({
    required this.router,
    required this.dependencies,
    this.authRefresh,
    super.key,
  });

  final GoRouter router;
  final AppScopeDependencies dependencies;
  final GoRouterRefreshStream? authRefresh;

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
