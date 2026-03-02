import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/core/bootstrap/app_version_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/bootstrap_coordinator.dart';
import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/fcm_background_handler.dart';

/// Bootstrap the app with the given flavor
Future<void> runAppWithFlavor(final Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  await BootstrapCoordinator.bootstrapApp(flavor);
}

/// Get the app version synchronously, with fallback to default
String getAppVersion() => AppVersionService.getAppVersion();
