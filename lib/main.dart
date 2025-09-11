import 'package:flutter_bloc_app/core/flavor.dart';
import 'package:flutter_bloc_app/main_bootstrap.dart';

/// Application entry point (generic)
/// Uses compile-time `--dart-define=FLAVOR=` if provided, otherwise defaults to `dev`.
Future<void> main() => runAppWithFlavor(FlavorManager.I.flavor);
