import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_config.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_parser.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const DeepLinkParser parser = DeepLinkParser();

  group('DeepLinkParser', () {
    test('returns counter for empty path', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}',
        ),
      );
      expect(target, DeepLinkTarget.counter);
    });

    test('parses known segment', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}/chat',
        ),
      );
      expect(target, DeepLinkTarget.chat);
    });

    test('parses event-bus-demo segment', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}/event-bus-demo',
        ),
      );
      expect(target, DeepLinkTarget.eventBusDemo);
    });

    test('parses native-platform-showcase segment', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}/native-platform-showcase',
        ),
      );
      expect(target, DeepLinkTarget.nativePlatformShowcase);
    });

    test('supports fallback scheme for native-platform-showcase host', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.fallbackScheme}://native-platform-showcase',
        ),
      );
      expect(target, DeepLinkTarget.nativePlatformShowcase);
    });

    test('parses realtime-market segment', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}/realtime-market',
        ),
      );
      expect(target, DeepLinkTarget.realtimeMarket);
    });

    test('parses universal host case-insensitively', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.universalScheme}://LINKS.FLUTTERBLOC.APP/chat',
        ),
      );
      expect(target, DeepLinkTarget.chat);
    });

    test('supports localhost web links for local web development', () {
      final target = parser.parse(Uri.parse('http://localhost:7357/settings'));
      expect(target, DeepLinkTarget.settings);
    });

    test('supports loopback web links for local web development', () {
      final target = parser.parse(Uri.parse('http://127.0.0.1:7357/chat'));
      expect(target, DeepLinkTarget.chat);
    });

    test('supports fallback scheme for development', () {
      final target = parser.parse(
        Uri.parse('${DeepLinkConfig.fallbackScheme}://settings'),
      );
      expect(target, DeepLinkTarget.settings);
    });

    test('supports fallback scheme for realtime-market host', () {
      final target = parser.parse(
        Uri.parse('${DeepLinkConfig.fallbackScheme}://realtime-market'),
      );
      expect(target, DeepLinkTarget.realtimeMarket);
    });

    test('returns null for unsupported host', () {
      final target = parser.parse(
        Uri.parse('${DeepLinkConfig.universalScheme}://example.com/settings'),
      );
      expect(target, isNull);
    });

    test('returns null for unknown segment', () {
      final target = parser.parse(
        Uri.parse(
          '${DeepLinkConfig.universalScheme}://${DeepLinkConfig.universalHost}/unknown',
        ),
      );
      expect(target, isNull);
    });
  });
}
