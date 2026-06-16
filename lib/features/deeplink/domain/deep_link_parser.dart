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
    if (_isWebHttpScheme(uri.scheme) && !_isSupportedWebHost(uri)) {
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
      // Hash routes live in the fragment; bare http://localhost/ has no path
      // segments — do not hijack GoRouter navigation to counter.
      if (_isWebHttpScheme(uri.scheme)) {
        if (_isLocalhostHost(uri.host)) {
          return null;
        }
        if (uri.scheme == DeepLinkConfig.universalScheme &&
            _isUniversalLinkHost(uri.host)) {
          return DeepLinkTarget.counter;
        }
        return null;
      }
      return DeepLinkTarget.counter;
    }

    final String key = segments.first;
    return _segmentMap[key];
  }

  bool _isSupportedScheme(final String scheme) =>
      scheme == DeepLinkConfig.universalScheme ||
      scheme == DeepLinkConfig.fallbackScheme ||
      _isWebHttpScheme(scheme);

  bool _isSupportedWebHost(final Uri uri) =>
      _isLocalhostHost(uri.host) ||
      (uri.scheme == DeepLinkConfig.universalScheme &&
          _isUniversalLinkHost(uri.host));

  bool _isUniversalLinkHost(final String host) =>
      host.toLowerCase() == DeepLinkConfig.universalHost;

  bool _isLocalhostHost(final String host) {
    final String normalized = host.toLowerCase();
    return normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '::1';
  }

  static bool _isWebHttpScheme(final String scheme) =>
      scheme == 'http' || scheme == 'https';

  static const Map<String, DeepLinkTarget> _segmentMap =
      <String, DeepLinkTarget>{
        'counter': DeepLinkTarget.counter,
        'home': DeepLinkTarget.counter,
        'example': DeepLinkTarget.example,
        'charts': DeepLinkTarget.charts,
        'settings': DeepLinkTarget.settings,
        'chat': DeepLinkTarget.chat,
        'websocket': DeepLinkTarget.websocket,
        'realtime-market': DeepLinkTarget.realtimeMarket,
        'google-maps': DeepLinkTarget.googleMaps,
        'graphql-demo': DeepLinkTarget.graphqlDemo,
        'profile': DeepLinkTarget.profile,
        'event-bus-demo': DeepLinkTarget.eventBusDemo,
        'native-platform-showcase': DeepLinkTarget.nativePlatformShowcase,
      };
}
