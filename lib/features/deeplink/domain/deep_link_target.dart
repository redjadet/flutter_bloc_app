import 'package:flutter_bloc_app/core/router/app_routes.dart';

/// Supported deep link destinations within the application.
enum DeepLinkTarget {
  counter(AppRoutes.counterPath),
  example(AppRoutes.examplePath),
  charts(AppRoutes.chartsPath),
  settings(AppRoutes.settingsPath),
  chat(AppRoutes.chatPath),
  websocket(AppRoutes.websocketPath),
  googleMaps(AppRoutes.googleMapsPath),
  graphqlDemo(AppRoutes.graphqlPath),
  profile(AppRoutes.profilePath);

  const DeepLinkTarget(this.location);

  /// The GoRouter location to navigate to.
  final String location;
}
