import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';

extension DeepLinkTargetLocationX on DeepLinkTarget {
  String get location => switch (this) {
    DeepLinkTarget.counter => AppRoutes.counterPath,
    DeepLinkTarget.example => AppRoutes.examplePath,
    DeepLinkTarget.charts => AppRoutes.chartsPath,
    DeepLinkTarget.settings => AppRoutes.settingsPath,
    DeepLinkTarget.chat => AppRoutes.chatPath,
    DeepLinkTarget.websocket => AppRoutes.websocketPath,
    DeepLinkTarget.realtimeMarket => AppRoutes.realtimeMarketPath,
    DeepLinkTarget.googleMaps => AppRoutes.googleMapsPath,
    DeepLinkTarget.graphqlDemo => AppRoutes.graphqlPath,
    DeepLinkTarget.profile => AppRoutes.profilePath,
    DeepLinkTarget.eventBusDemo => AppRoutes.eventBusDemoPath,
  };
}
