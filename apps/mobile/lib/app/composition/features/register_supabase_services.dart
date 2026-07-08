import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/http/supabase/supabase_session_manager.dart';
import 'package:flutter_bloc_app/features/supabase_auth/data/supabase_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';

/// Registers Supabase-related services.
///
/// [SupabaseAuthRepository] is the abstraction used by the Supabase auth page.
void registerSupabaseServices() {
  registerLazySingletonIfAbsent<SupabaseSessionManager>(() {
    final SupabaseSessionManager manager = SupabaseSessionManager(
      sessionCoordinator: getIt.isRegistered<SessionLifecycleCoordinator>()
          ? getIt<SessionLifecycleCoordinator>()
          : null,
      tokenRepository: getIt<TokenRepository>(),
    )..hydrateFromPersistentSession();
    return manager;
  });

  registerLazySingletonIfAbsent<SupabaseAuthRepository>(
    () => SupabaseAuthRepositoryImpl(tokenRepository: getIt<TokenRepository>()),
  );
  registerLazySingletonIfAbsent<RemoteBackendAuthPort>(
    () => getIt<SupabaseAuthRepository>(),
  );
}
