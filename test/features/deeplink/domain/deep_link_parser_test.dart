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

    test('supports fallback scheme for development', () {
      final target = parser.parse(
        Uri.parse('${DeepLinkConfig.fallbackScheme}://settings'),
      );
      expect(target, DeepLinkTarget.settings);
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
