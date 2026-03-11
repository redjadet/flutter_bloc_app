import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(resetMainBootstrapHooksForTest);

  group('main_bootstrap', () {
    test(
      'runAppWithFlavor initializes binding and registers FCM handler',
      () async {
        final List<String> calls = <String>[];
        BackgroundMessageHandler? registeredHandler;
        Flavor? bootstrappedFlavor;

        ensureBootstrapBindingInitialized = () {
          calls.add('binding');
        };
        registerFcmBackgroundHandler = (final handler) {
          calls.add('background-handler');
          registeredHandler = handler;
        };
        bootstrapFlavorApp = (final flavor) async {
          calls.add('bootstrap');
          bootstrappedFlavor = flavor;
        };

        await runAppWithFlavor(Flavor.dev);

        expect(calls, <String>['binding', 'background-handler', 'bootstrap']);
        expect(bootstrappedFlavor, Flavor.dev);
        expect(registeredHandler, isNotNull);
      },
    );

    test('getAppVersion delegates to app version reader', () {
      readAppVersion = () => '9.9.9-test';

      expect(getAppVersion(), '9.9.9-test');
    });
  });
}
