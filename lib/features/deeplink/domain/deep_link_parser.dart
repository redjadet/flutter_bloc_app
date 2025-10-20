import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_config.dart';
import 'package:flutter_bloc_app/features/deeplink/domain/deep_link_target.dart';

/// Maps incoming URIs to in-app destinations.
class DeepLinkParser {
  const DeepLinkParser();

  /// Returns the matching [DeepLinkTarget] for the provided [uri].
  /// Returns null when the URI is not supported.
  DeepLinkTarget? parse(final Uri uri) {
    if (!_isSupportedScheme(uri.scheme)) {
      return null;
    }
    if (uri.scheme == DeepLinkConfig.universalScheme &&
        uri.host != DeepLinkConfig.universalHost) {
      return null;
    }

    final List<String> segments = uri.pathSegments
        .where((final segment) => segment.isNotEmpty)
        .map((final segment) => segment.toLowerCase())
        .toList();

    if (segments.isEmpty) {
      if (uri.scheme == DeepLinkConfig.fallbackScheme) {
        final String hostKey = uri.host.toLowerCase();
        if (hostKey.isNotEmpty) {
          return _segmentMap[hostKey];
        }
      }
      return DeepLinkTarget.counter;
    }

    final String key = segments.first;
    return _segmentMap[key];
  }

  bool _isSupportedScheme(final String scheme) =>
      scheme == DeepLinkConfig.universalScheme ||
      scheme == DeepLinkConfig.fallbackScheme;

  static const Map<String, DeepLinkTarget> _segmentMap =
      <String, DeepLinkTarget>{
        'counter': DeepLinkTarget.counter,
        'home': DeepLinkTarget.counter,
        'example': DeepLinkTarget.example,
        'charts': DeepLinkTarget.charts,
        'settings': DeepLinkTarget.settings,
        'chat': DeepLinkTarget.chat,
        'websocket': DeepLinkTarget.websocket,
        'google-maps': DeepLinkTarget.googleMaps,
        'graphql-demo': DeepLinkTarget.graphqlDemo,
        'profile': DeepLinkTarget.profile,
      };
}
