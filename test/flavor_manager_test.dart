import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    FlavorManager.set(Flavor.dev);
  });

  test('FlavorManager exposes flags and name for each flavor', () {
    FlavorManager.set(Flavor.prod);
    expect(FlavorManager.I.isProd, isTrue);
    expect(FlavorManager.I.name, 'prod');

    FlavorManager.set(Flavor.beta);
    expect(FlavorManager.I.isBeta, isTrue);
    expect(FlavorManager.I.name, 'beta');

    FlavorManager.set(Flavor.qa);
    expect(FlavorManager.I.isQa, isTrue);
    expect(FlavorManager.I.name, 'qa');

    FlavorManager.set(Flavor.staging);
    expect(FlavorManager.I.isStaging, isTrue);
    expect(FlavorManager.I.name, 'staging');

    FlavorManager.set(Flavor.dev);
    expect(FlavorManager.I.isDev, isTrue);
    expect(FlavorManager.I.name, 'dev');
  });

  test('parseFlavorForTest resolves aliases and defaults to dev', () {
    expect(parseFlavorForTest('stage'), Flavor.staging);
    expect(parseFlavorForTest('production'), Flavor.prod);
    expect(parseFlavorForTest('unknown'), Flavor.dev);
  });
}
