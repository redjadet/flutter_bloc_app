import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';

extension DeepLinkTargetLocationX on DeepLinkTarget {
  String get location {
    switch (this) {
      case DeepLinkTarget.counter:
        return AppRoutes.counterPath;
      case DeepLinkTarget.example:
        return AppRoutes.examplePath;
      case DeepLinkTarget.charts:
        return AppRoutes.chartsPath;
      case DeepLinkTarget.settings:
        return AppRoutes.settingsPath;
      case DeepLinkTarget.chat:
        return AppRoutes.chatPath;
      case DeepLinkTarget.websocket:
        return AppRoutes.websocketPath;
      case DeepLinkTarget.googleMaps:
        return AppRoutes.googleMapsPath;
      case DeepLinkTarget.graphqlDemo:
        return AppRoutes.graphqlPath;
      case DeepLinkTarget.profile:
        return AppRoutes.profilePath;
    }
  }
}
