import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/bootstrap/app_version_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/bootstrap_coordinator.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/fcm_background_handler.dart';

void Function() ensureBootstrapBindingInitialized =
    WidgetsFlutterBinding.ensureInitialized;

void Function(BackgroundMessageHandler handler) registerFcmBackgroundHandler =
    FirebaseMessaging.onBackgroundMessage;

Future<void> Function(Flavor flavor) bootstrapFlavorApp =
    BootstrapCoordinator.bootstrapApp;

String Function() readAppVersion = AppVersionService.getAppVersion;

/// Bootstrap the app with the given flavor
Future<void> runAppWithFlavor(final Flavor flavor) async {
  ensureBootstrapBindingInitialized();
  registerFcmBackgroundHandler(fcmBackgroundHandler);
  await bootstrapFlavorApp(flavor);
}

/// Get the app version synchronously, with fallback to default
String getAppVersion() => readAppVersion();

@visibleForTesting
void resetMainBootstrapHooksForTest() {
  ensureBootstrapBindingInitialized = WidgetsFlutterBinding.ensureInitialized;
  registerFcmBackgroundHandler = FirebaseMessaging.onBackgroundMessage;
  bootstrapFlavorApp = BootstrapCoordinator.bootstrapApp;
  readAppVersion = AppVersionService.getAppVersion;
}
