import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:networking/networking.dart';
import 'package:storage/storage.dart';

/// Registers sync registry, pending-sync store, and background coordinator.
///
/// Optional [RealtimeSyncTrigger] is registered by features (e.g. IoT demo)
/// before this runs; this file stays free of feature imports.
void registerSyncServices() {
  registerLazySingletonIfAbsent<SyncableRepositoryRegistry>(
    SyncableRepositoryRegistry.new,
  );
  registerLazySingletonIfAbsent<PendingSyncRepository>(
    () => PendingSyncRepository(hiveService: getIt<HiveService>()),
    dispose: (repository) => repository.dispose(),
  );
  registerLazySingletonIfAbsent<BackgroundSyncCoordinator>(() {
    final RealtimeSyncTrigger? realtimeTrigger =
        getIt.isRegistered<RealtimeSyncTrigger>()
        ? getIt<RealtimeSyncTrigger>()
        : null;
    return BackgroundSyncCoordinator(
      repository: getIt<PendingSyncRepository>(),
      networkStatusService: getIt<NetworkStatusService>(),
      timerService: getIt<TimerService>(),
      registry: getIt<SyncableRepositoryRegistry>(),
      getSyncSupabaseUserId: () =>
          getIt<SupabaseAuthRepository>().currentUser?.id,
      getSharedSyncAuthUserId: () {
        if (!getIt.isRegistered<FirebaseAuth>()) {
          return null;
        }
        return getIt<FirebaseAuth>().currentUser?.uid;
      },
      realtimeSyncTrigger: realtimeTrigger,
    );
  }, dispose: (coordinator) => coordinator.dispose());
}
