import 'package:flutter_bloc_app/core/bootstrap/app_version_service.dart';
import 'package:flutter_bloc_app/core/bootstrap/bootstrap_coordinator.dart';
import 'package:flutter_bloc_app/core/flavor.dart';

/// Bootstrap the app with the given flavor
Future<void> runAppWithFlavor(final Flavor flavor) async {
  await BootstrapCoordinator.bootstrapApp(flavor);
}

/// Get the app version synchronously, with fallback to default
String getAppVersion() => AppVersionService.getAppVersion();
