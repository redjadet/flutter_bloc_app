import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_realtime_subscription.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

/// Registers sync registry, pending-sync store, and background coordinator.
void registerSyncServices() {
  registerLazySingletonIfAbsent<SyncableRepositoryRegistry>(
    SyncableRepositoryRegistry.new,
  );
  registerLazySingletonIfAbsent<PendingSyncRepository>(
    () => PendingSyncRepository(hiveService: getIt<HiveService>()),
    dispose: (final repository) => repository.dispose(),
  );
  registerLazySingletonIfAbsent<BackgroundSyncCoordinator>(
    () {
      final IotDemoRealtimeSubscription realtime = getIt<IotDemoRealtimeSubscription>();
      return BackgroundSyncCoordinator(
        repository: getIt<PendingSyncRepository>(),
        networkStatusService: getIt<NetworkStatusService>(),
        timerService: getIt<TimerService>(),
        registry: getIt<SyncableRepositoryRegistry>(),
        getSyncSupabaseUserId: () => getIt<SupabaseAuthRepository>().currentUser?.id,
        startIotDemoRealtimeSubscription: (final onSyncRequested) =>
            realtime.start(onSyncRequested),
        stopIotDemoRealtimeSubscription: () => unawaited(realtime.stop()),
      );
    },
    dispose: (final coordinator) => coordinator.dispose(),
  );
}
