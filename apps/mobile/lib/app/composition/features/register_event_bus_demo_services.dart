import 'package:event_bus/event_bus.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';

/// Registers the shared [EventBus] used by the Event Bus demo only.
///
/// Kept demo-scoped so the rest of the app continues to use Cubit/BLoC for
/// predictable state. Expand registration only if a production cross-cutting
/// bus is intentionally adopted.
void registerEventBusDemoServices() {
  registerLazySingletonIfAbsent<EventBus>(
    EventBus.new,
    dispose: (final bus) => bus.destroy(),
  );
}
