import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:networking/networking.dart';

/// Registers timer and network status services.
///
/// `registerHttpServices` builds `Dio` with `NetworkStatusService`; chart setup
/// can eagerly resolve HTTP clients, so network status must exist first.
void registerTimerNetworkServices() {
  registerLazySingletonIfAbsent<TimerService>(DefaultTimerService.new);
  registerLazySingletonIfAbsent<NetworkStatusService>(
    () => ConnectivityNetworkStatusService(
      timerService: getIt<TimerService>(),
    ),
    dispose: (final service) => service.dispose(),
  );
}
