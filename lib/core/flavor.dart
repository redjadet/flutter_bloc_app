enum Flavor { dev, staging, prod }

class FlavorManager {
  FlavorManager._internal();
  static final FlavorManager _instance = FlavorManager._internal();
  static FlavorManager get I => _instance;

  Flavor _flavor = _parseFlavor(
    const String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
  );

  static void set(Flavor flavor) {
    _instance._flavor = flavor;
  }

  Flavor get flavor => _flavor;
  bool get isDev => _flavor == Flavor.dev;
  bool get isStaging => _flavor == Flavor.staging;
  bool get isProd => _flavor == Flavor.prod;
  String get name => switch (_flavor) {
    Flavor.dev => 'dev',
    Flavor.staging => 'staging',
    Flavor.prod => 'prod',
  };
}

Flavor _parseFlavor(String value) {
  switch (value.toLowerCase()) {
    case 'dev':
      return Flavor.dev;
    case 'staging':
    case 'stage':
      return Flavor.staging;
    case 'prod':
    case 'production':
      return Flavor.prod;
    default:
      return Flavor.dev;
  }
}
