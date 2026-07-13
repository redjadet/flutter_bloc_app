import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/bootstrap/bootstrap_coordinator.dart';
import 'package:flutter_bloc_app/app/config/app_runtime_config.dart';
import 'package:flutter_bloc_app/app/config/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final Flavor originalFlavor = FlavorManager.current;

  setUp(() {
    BootstrapCoordinator.resetForTest();
    // VM tests are not web; keep backends on the blocking path by default.
    BootstrapCoordinator.shouldDeferBackendInit = () => false;
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
        calls.add('runApp:${app.runtimeType}');
        startedApp = app;
      };

      await BootstrapCoordinator.bootstrapApp(Flavor.dev);

      expect(calls.first, 'binding');
      expect(calls[1], 'platform');
      expect(calls, containsAll(<String>['secrets:true', 'version']));
      expect(calls, containsAll(<String>['firebase', 'supabase']));
      expect(calls, containsAllInOrder(<String>['firebase', 'firebase-ui']));
      expect(calls, containsAllInOrder(<String>['firebase', 'crashlytics']));
      expect(calls, containsAllInOrder(<String>['di', 'runtime-config']));
      expect(
        calls,
        containsAllInOrder(<String>['runtime-config', 'migration']),
      );
      expect(calls.last, 'runApp:MyApp');
      expect(
        calls.indexOf('secrets:true'),
        lessThan(calls.indexOf('firebase')),
      );
      expect(calls.indexOf('version'), lessThan(calls.indexOf('firebase')));
      expect(
        calls.indexOf('platform'),
        lessThan(calls.indexOf('secrets:true')),
      );
      expect(FlavorManager.current, Flavor.dev);
      expect(startedApp, isA<Widget>());
    });

    test(
      'bootstrapApp paints WebLaunchSplash before MyApp when web splash enabled',
      () async {
        final List<String> started = <String>[];

        BootstrapCoordinator.shouldShowWebLaunchSplash = () => true;
        BootstrapCoordinator.ensureBindingInitialized = () {};
        BootstrapCoordinator.initializePlatform = () async {};
        BootstrapCoordinator.loadSecrets =
            ({required final bool allowAssetFallback}) async {};
        BootstrapCoordinator.loadAppVersion = () async {};
        BootstrapCoordinator.initializeFirebase = () async => false;
        BootstrapCoordinator.configureFirebaseUi = () {};
        BootstrapCoordinator.registerCrashlyticsHandlers = () {};
        BootstrapCoordinator.initializeSupabase = () async {};
        BootstrapCoordinator.setupDependencies = () async {};
        BootstrapCoordinator.readRuntimeConfig = () =>
            AppRuntimeConfig(flavor: Flavor.dev, skeletonDelay: Duration.zero);
        BootstrapCoordinator.runMigration = () async {};
        BootstrapCoordinator.startApp = (final app) {
          started.add(app.runtimeType.toString());
        };

        await BootstrapCoordinator.bootstrapApp(Flavor.dev);

        expect(started, <String>['WebLaunchSplash', 'MyApp']);
      },
    );

    test(
      'bootstrapApp defers Supabase until after MyApp when deferral enabled',
      () async {
        final List<String> calls = <String>[];
        Future<void> Function()? deferredStarter;

        BootstrapCoordinator.shouldDeferBackendInit = () => true;
        BootstrapCoordinator.scheduleDeferredWork = (final work) {
          deferredStarter = work;
        };
        BootstrapCoordinator.notifyBackendAvailabilityUpdated = () =>
            calls.add('availability-tick');
        BootstrapCoordinator.ensureBindingInitialized = () {};
        BootstrapCoordinator.initializePlatform = () async {};
        BootstrapCoordinator.loadSecrets =
            ({required final bool allowAssetFallback}) async {};
        BootstrapCoordinator.loadAppVersion = () async {};
        BootstrapCoordinator.initializeFirebase = () async {
          calls.add('firebase');
          return true;
        };
        BootstrapCoordinator.configureFirebaseUi = () =>
            calls.add('firebase-ui');
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
          calls.add('runApp:${app.runtimeType}');
        };

        await BootstrapCoordinator.bootstrapApp(Flavor.dev);

        expect(calls, <String>[
          'firebase',
          'firebase-ui',
          'crashlytics',
          'di',
          'runtime-config',
          'migration',
          'runApp:MyApp',
        ]);
        expect(deferredStarter, isNotNull);
        await deferredStarter!();
        expect(calls.take(7), <String>[
          'firebase',
          'firebase-ui',
          'crashlytics',
          'di',
          'runtime-config',
          'migration',
          'runApp:MyApp',
        ]);
        expect(calls, contains('supabase'));
        expect(calls.last, 'availability-tick');
        expect(
          calls.indexOf('firebase'),
          lessThan(calls.indexOf('runApp:MyApp')),
        );
        expect(
          calls.indexOf('runApp:MyApp'),
          lessThan(calls.indexOf('supabase')),
        );
      },
    );

    test(
      'deferred Supabase failure still notifies availability updates',
      () async {
        final List<String> calls = <String>[];
        Future<void> Function()? deferredStarter;

        BootstrapCoordinator.shouldDeferBackendInit = () => true;
        BootstrapCoordinator.scheduleDeferredWork = (final work) {
          deferredStarter = work;
        };
        BootstrapCoordinator.notifyBackendAvailabilityUpdated = () =>
            calls.add('availability-tick');
        BootstrapCoordinator.ensureBindingInitialized = () {};
        BootstrapCoordinator.initializePlatform = () async {};
        BootstrapCoordinator.loadSecrets =
            ({required final bool allowAssetFallback}) async {};
        BootstrapCoordinator.loadAppVersion = () async {};
        BootstrapCoordinator.initializeFirebase = () async => false;
        BootstrapCoordinator.configureFirebaseUi = () =>
            calls.add('firebase-ui');
        BootstrapCoordinator.registerCrashlyticsHandlers = () =>
            calls.add('crashlytics');
        BootstrapCoordinator.initializeSupabase = () async =>
            throw StateError('supabase boom');
        BootstrapCoordinator.setupDependencies = () async {};
        BootstrapCoordinator.readRuntimeConfig = () =>
            AppRuntimeConfig(flavor: Flavor.dev, skeletonDelay: Duration.zero);
        BootstrapCoordinator.runMigration = () async {};
        BootstrapCoordinator.startApp = (final _) {};

        await BootstrapCoordinator.bootstrapApp(Flavor.dev);
        await deferredStarter!();

        expect(calls, contains('availability-tick'));
        expect(calls, isNot(contains('firebase-ui')));
      },
    );

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

        expect(calls, containsAll(<String>['firebase', 'supabase']));
        expect(calls, isNot(contains('firebase-ui')));
        expect(calls, isNot(contains('crashlytics')));
        expect(FlavorManager.current, Flavor.staging);
      },
    );

    test(
      'bootstrapApp does not allow asset secrets fallback for non-dev flavors',
      () async {
        final List<String> calls = <String>[];

        BootstrapCoordinator.ensureBindingInitialized = () {};
        BootstrapCoordinator.initializePlatform = () async {};
        BootstrapCoordinator.loadSecrets =
            ({required final bool allowAssetFallback}) async {
              calls.add('secrets:$allowAssetFallback');
            };
        BootstrapCoordinator.loadAppVersion = () async {};
        BootstrapCoordinator.initializeFirebase = () async => false;
        BootstrapCoordinator.configureFirebaseUi = () {};
        BootstrapCoordinator.registerCrashlyticsHandlers = () {};
        BootstrapCoordinator.initializeSupabase = () async {};
        BootstrapCoordinator.setupDependencies = () async {};
        BootstrapCoordinator.readRuntimeConfig = () =>
            AppRuntimeConfig(flavor: Flavor.prod, skeletonDelay: Duration.zero);
        BootstrapCoordinator.runMigration = () async {};
        BootstrapCoordinator.startApp = (final _) {};

        await BootstrapCoordinator.bootstrapApp(Flavor.prod);

        expect(calls, <String>['secrets:false']);
        expect(FlavorManager.current, Flavor.prod);
      },
    );
  });
}
