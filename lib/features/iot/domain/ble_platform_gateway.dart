/// Platform capability probe (no Flutter imports in domain).
abstract class BlePlatformGateway {
  bool get supportsRealBle;

  bool get supportsRealClassic;
}
