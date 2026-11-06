import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/carrier_line_demo.dart';
import 'package:storage/storage.dart';

void registerCarrierLineDemoServices() {
  registerLazySingletonIfAbsent<CarrierInboxRepository>(
    () => HiveCarrierInboxRepository(hiveService: getIt<HiveService>()),
  );
  // Realtime client is created per route visit (CarrierLineDemoRouteFactory)
  // so Cubit.close() can dispose without poisoning a singleton.
  registerLazySingletonIfAbsent<LineStatusRepository>(
    () => const StubLineStatusRepository(),
  );
  // Push: compose shared FcmMessagingService from FCM demo DI (P1 UI).
}
