/// Shared constants for the universal link configuration.
class DeepLinkConfig {
  const DeepLinkConfig._();

  /// HTTPS host that owns the apple-app-site-association / assetlinks.json files.
  static const String universalHost = 'links.flutterbloc.app';

  /// Primary scheme used for universal links.
  static const String universalScheme = 'https';

  /// Optional custom scheme for local testing (does not require HTTPS setup).
  static const String fallbackScheme = 'flutter-bloc-app';
}
