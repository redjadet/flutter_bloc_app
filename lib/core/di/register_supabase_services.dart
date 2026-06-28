import 'package:flutter_bloc_app/core/auth/remote_backend_auth_port.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/supabase_auth/data/supabase_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/http/supabase_session_manager.dart';

/// Registers Supabase-related services.
///
/// [SupabaseAuthRepository] is the abstraction used by the Supabase auth page.
void registerSupabaseServices() {
  registerLazySingletonIfAbsent<SupabaseSessionManager>(
    () => SupabaseSessionManager(
      sessionCoordinator: getIt.isRegistered<SessionLifecycleCoordinator>()
          ? getIt<SessionLifecycleCoordinator>()
          : null,
    ),
  );

  registerLazySingletonIfAbsent<SupabaseAuthRepository>(
    SupabaseAuthRepositoryImpl.new,
  );
  registerLazySingletonIfAbsent<RemoteBackendAuthPort>(
    () => getIt<SupabaseAuthRepository>(),
  );
}
