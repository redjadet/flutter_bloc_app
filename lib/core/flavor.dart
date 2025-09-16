enum Flavor { dev, staging, qa, beta, prod }

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
  bool get isQa => _flavor == Flavor.qa;
  bool get isBeta => _flavor == Flavor.beta;
  bool get isProd => _flavor == Flavor.prod;
  String get name => switch (_flavor) {
    Flavor.dev => 'dev',
    Flavor.staging => 'staging',
    Flavor.qa => 'qa',
    Flavor.beta => 'beta',
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
    case 'qa':
      return Flavor.qa;
    case 'beta':
      return Flavor.beta;
    case 'prod':
    case 'production':
      return Flavor.prod;
    default:
      return Flavor.dev;
  }
}
