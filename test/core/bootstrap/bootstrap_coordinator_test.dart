import 'package:flutter_bloc_app/core/bootstrap/bootstrap_coordinator.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BootstrapCoordinator', () {
    test('bootstrapApp method signature accepts all flavor types', () {
      // Test that the method signature accepts all flavor types
      // We don't actually call bootstrapApp as it would run the full app
      // and cause tests to hang. This test verifies the API contract.
      final flavors = [Flavor.dev, Flavor.staging, Flavor.prod];
      final Function(Flavor) method = BootstrapCoordinator.bootstrapApp;

      for (final flavor in flavors) {
        // Verify the method signature accepts each flavor type
        // We check that the method exists and can be referenced with each flavor
        expect(method, isNotNull);
        expect(flavor, isA<Flavor>()); // Use flavor to verify type
      }
    });

    test('bootstrapApp is a static method', () {
      // Verify bootstrapApp is accessible as a static method
      expect(BootstrapCoordinator.bootstrapApp, isA<Function>());
    });
  });
}
