import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/bootstrap/bootstrap_coordinator.dart';
import 'package:flutter_bloc_app/core/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Flavor originalFlavor = FlavorManager.current;

  setUp(() {
    BootstrapCoordinator.resetForTest();
  });

  tearDown(() {
    BootstrapCoordinator.resetForTest();
    FlavorManager.current = originalFlavor;
  });

  group('BootstrapCoordinator Additional Tests', () {
    test('bootstrapApp runs bootstrap steps in order and starts app', () async {
      final List<String> calls = <String>[];
      Widget? startedApp;

      BootstrapCoordinator.ensureBindingInitialized = () =>
          calls.add('binding');
      BootstrapCoordinator.initializePlatform = () async {
        calls.add('platform');
      };
      BootstrapCoordinator.loadSecrets =
          ({required final bool allowAssetFallback}) async {
            calls.add('secrets:$allowAssetFallback');
          };
      BootstrapCoordinator.loadAppVersion = () async {
        calls.add('version');
      };
      BootstrapCoordinator.initializeFirebase = () async {
        calls.add('firebase');
        return true;
      };
      BootstrapCoordinator.configureFirebaseUi = () => calls.add('firebase-ui');
      BootstrapCoordinator.registerCrashlyticsHandlers = () =>
          calls.add('crashlytics');
      BootstrapCoordinator.initializeSupabase = () async {
        calls.add('supabase');
      };
      BootstrapCoordinator.setupDependencies = () async {
        calls.add('di');
      };
      BootstrapCoordinator.readRuntimeConfig = () {
        calls.add('runtime-config');
        return AppRuntimeConfig(
          flavor: Flavor.dev,
          skeletonDelay: Duration.zero,
        );
      };
      BootstrapCoordinator.runMigration = () async {
        calls.add('migration');
      };
      BootstrapCoordinator.startApp = (final app) {
        calls.add('runApp');
        startedApp = app;
      };

      await BootstrapCoordinator.bootstrapApp(Flavor.dev);

      expect(calls, <String>[
        'binding',
        'platform',
        'secrets:true',
        'version',
        'firebase',
        'firebase-ui',
        'crashlytics',
        'supabase',
        'di',
        'runtime-config',
        'migration',
        'runApp',
      ]);
      expect(FlavorManager.current, Flavor.dev);
      expect(startedApp, isA<Widget>());
    });

    test(
      'bootstrapApp skips Firebase UI wiring when Firebase is unavailable',
      () async {
        final List<String> calls = <String>[];

        BootstrapCoordinator.ensureBindingInitialized = () {};
        BootstrapCoordinator.initializePlatform = () async {};
        BootstrapCoordinator.loadSecrets =
            ({required final bool allowAssetFallback}) async {};
        BootstrapCoordinator.loadAppVersion = () async {};
        BootstrapCoordinator.initializeFirebase = () async {
          calls.add('firebase');
          return false;
        };
        BootstrapCoordinator.configureFirebaseUi = () =>
            calls.add('firebase-ui');
        BootstrapCoordinator.registerCrashlyticsHandlers = () =>
            calls.add('crashlytics');
        BootstrapCoordinator.initializeSupabase = () async {
          calls.add('supabase');
        };
        BootstrapCoordinator.setupDependencies = () async {};
        BootstrapCoordinator.readRuntimeConfig = () => AppRuntimeConfig(
          flavor: Flavor.staging,
          skeletonDelay: Duration.zero,
        );
        BootstrapCoordinator.runMigration = () async {};
        BootstrapCoordinator.startApp = (final _) {};

        await BootstrapCoordinator.bootstrapApp(Flavor.staging);

        expect(calls, <String>['firebase', 'supabase']);
        expect(FlavorManager.current, Flavor.staging);
      },
    );
  });
}
