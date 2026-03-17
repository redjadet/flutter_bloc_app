import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/core/time/timer_service.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/iot_demo_realtime_subscription.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/offline_first_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/persistent_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/data/supabase_iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/iot_demo/domain/iot_demo_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/storage/hive_service.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/syncable_repository_registry.dart';

/// Registers IoT demo services (offline-first, per-Supabase-user local storage).
void registerIotDemoServices() {
  registerLazySingletonIfAbsent<IotDemoRealtimeSubscription>(
    IotDemoRealtimeSubscription.new,
  );
  registerLazySingletonIfAbsent<SupabaseIotDemoRepository>(
    SupabaseIotDemoRepository.new,
  );
  registerLazySingletonIfAbsent<IotDemoRepository>(
    () => OfflineFirstIotDemoRepository(
      getCurrentSupabaseUserId: () =>
          getIt<SupabaseAuthRepository>().currentUser?.id,
      getPersistentRepository: (final supabaseUserId) =>
          PersistentIotDemoRepository(
            hiveService: getIt<HiveService>(),
            supabaseUserId: supabaseUserId,
            timerService: getIt<TimerService>(),
          ),
      pendingSyncRepository: getIt<PendingSyncRepository>(),
      registry: getIt<SyncableRepositoryRegistry>(),
      timerService: getIt<TimerService>(),
      remoteRepository: SupabaseBootstrapService.isSupabaseInitialized
          ? getIt<SupabaseIotDemoRepository>()
          : null,
    ),
  );
}
