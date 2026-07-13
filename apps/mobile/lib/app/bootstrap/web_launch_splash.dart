import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app.dart' show MyApp;
import 'package:flutter_bloc_app/app/bootstrap/bootstrap_coordinator.dart'
    show BootstrapCoordinator;
import 'package:flutter_bloc_app/app/config/app_constants.dart';

/// Minimal first-paint UI shown on web while [BootstrapCoordinator] finishes.
///
/// Replaced by [MyApp] once DI, backends, and migration complete. Keeps the
/// canvas from staying blank after the engine starts but before `runApp(MyApp)`.
class WebLaunchSplash extends StatelessWidget {
  const WebLaunchSplash({super.key});

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: AppConstants.primarySeedColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: colors),
      home: Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Starting…',
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.72),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
