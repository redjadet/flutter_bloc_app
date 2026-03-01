import 'dart:async';

import 'package:flutter_bloc_app/app.dart' show MyApp;
import 'package:flutter_bloc_app/app/app_scope.dart' show AppScope;
import 'package:flutter_bloc_app/core/bootstrap/bootstrap_coordinator.dart'
    show BootstrapCoordinator;
import 'package:flutter_bloc_app/core/di/injector_registrations.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/utils/initialization_guard.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// Configures all application dependencies using GetIt dependency injection.
///
/// **Dependency Registration Strategy:**
///
/// All dependencies are registered as **lazy singletons** (using `registerLazySingleton`),
/// which means:
/// - **Single instance:** Only one instance is created and reused throughout the app lifecycle
/// - **Lazy initialization:** The instance is created only when first requested, not at registration time
/// - **Memory efficient:** Reduces memory usage by sharing instances across the app
///
/// **When to use Singletons vs Factories:**
///
/// **Singletons (current approach):**
/// - ✅ **Stateful services** that maintain internal state (e.g., `HiveService`, `WebsocketRepository`)
/// - ✅ **Expensive to create** resources (e.g., `http.Client`, database connections)
/// - ✅ **Shared resources** used across multiple features (e.g., repositories, services)
/// - ✅ **Configuration objects** that don't change (e.g., `PaymentCalculator`, `DeepLinkParser`)
///
/// **Factories (not currently used, but consider for):**
/// - ❌ **Stateless utilities** that could be created on-demand (though singletons work fine too)
/// - ❌ **Request-scoped objects** that need fresh instances per request
/// - ❌ **Objects with different configurations** per usage context
///
/// **Dispose Callbacks:**
///
/// Some dependencies require cleanup when the app shuts down or during testing.
/// These are registered with a `dispose` callback:
/// - `http.Client` - closes HTTP connections
/// - `HuggingFaceApiClient` - disposes internal resources
/// - `WebsocketRepository` - closes WebSocket connections and cancels subscriptions
/// - `RemoteConfigRepository` - cancels config update subscriptions
///
/// The dispose callbacks are automatically called when `getIt.reset()` is invoked
/// (typically during tests or app shutdown).
Future<void> configureDependencies() async {
  // Initialize Hive - handle initialization failures gracefully
  // This must be done before registering other dependencies that depend on Hive
  await InitializationGuard.executeSafely(
    () async {
      await registerAllDependencies();
      await getIt<HiveService>().initialize();
    },
    context: 'configureDependencies',
    failureMessage:
        'Failed to initialize Hive during dependency configuration. '
        'App may not function correctly without storage.',
  );
}

/// Ensures DI is configured (fire-and-forget). Use when pumping [AppScope] or
/// [MyApp] in tests without running [BootstrapCoordinator] bootstrap.
/// Note: [getIt] may be used immediately after; in production, bootstrap
/// awaits [configureDependencies] before runApp, so there is no race.
void ensureConfigured() {
  unawaited(configureDependencies());
}
