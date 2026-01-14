import 'package:flutter_bloc_app/core/router/app_routes.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';
import 'package:flutter_bloc_app/features/deeplink/presentation/deep_link_target_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeepLinkTargetLocationX', () {
    test('location returns correct path for counter', () {
      expect(DeepLinkTarget.counter.location, AppRoutes.counterPath);
    });

    test('location returns correct path for example', () {
      expect(DeepLinkTarget.example.location, AppRoutes.examplePath);
    });

    test('location returns correct path for charts', () {
      expect(DeepLinkTarget.charts.location, AppRoutes.chartsPath);
    });

    test('location returns correct path for settings', () {
      expect(DeepLinkTarget.settings.location, AppRoutes.settingsPath);
    });

    test('location returns correct path for chat', () {
      expect(DeepLinkTarget.chat.location, AppRoutes.chatPath);
    });

    test('location returns correct path for websocket', () {
      expect(DeepLinkTarget.websocket.location, AppRoutes.websocketPath);
    });

    test('location returns correct path for googleMaps', () {
      expect(DeepLinkTarget.googleMaps.location, AppRoutes.googleMapsPath);
    });

    test('location returns correct path for graphqlDemo', () {
      expect(DeepLinkTarget.graphqlDemo.location, AppRoutes.graphqlPath);
    });

    test('location returns correct path for profile', () {
      expect(DeepLinkTarget.profile.location, AppRoutes.profilePath);
    });
  });
}
