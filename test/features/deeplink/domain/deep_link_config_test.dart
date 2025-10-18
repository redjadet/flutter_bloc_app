import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeepLinkConfig', () {
    test('exposes expected universal link constants', () {
      expect(DeepLinkConfig.universalHost, 'links.flutterbloc.app');
      expect(DeepLinkConfig.universalScheme, 'https');
      expect(DeepLinkConfig.fallbackScheme, 'flutter-bloc-app');
    });
  });
}
