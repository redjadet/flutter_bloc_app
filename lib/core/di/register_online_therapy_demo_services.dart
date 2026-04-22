import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/fake_repositories.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/repositories.dart';

void registerOnlineTherapyDemoServices() {
  registerLazySingletonIfAbsent<OnlineTherapyFakeApi>(OnlineTherapyFakeApi.new);

  registerLazySingletonIfAbsent<TherapyAuthRepository>(
    () => FakeTherapyAuthRepository(api: getIt<OnlineTherapyFakeApi>()),
  );
  registerLazySingletonIfAbsent<TherapistRepository>(
    () => FakeTherapistRepository(api: getIt<OnlineTherapyFakeApi>()),
  );
  registerLazySingletonIfAbsent<AppointmentRepository>(
    () => FakeAppointmentRepository(api: getIt<OnlineTherapyFakeApi>()),
  );
  registerLazySingletonIfAbsent<TherapyMessagingRepository>(
    () => FakeTherapyMessagingRepository(api: getIt<OnlineTherapyFakeApi>()),
  );
  registerLazySingletonIfAbsent<TherapyCallRepository>(
    () => FakeTherapyCallRepository(api: getIt<OnlineTherapyFakeApi>()),
  );
  registerLazySingletonIfAbsent<TherapyAdminRepository>(
    () => FakeTherapyAdminRepository(api: getIt<OnlineTherapyFakeApi>()),
  );
  registerLazySingletonIfAbsent<AuditRepository>(
    () => FakeAuditRepository(api: getIt<OnlineTherapyFakeApi>()),
  );
}
