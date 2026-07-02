import 'package:flutter_bloc_app/core/auth/remote_backend_auth_port.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/core/auth/token_repository.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/supabase_auth/data/supabase_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/shared/http/supabase_session_manager.dart';

/// Registers Supabase-related services.
///
/// [SupabaseAuthRepository] is the abstraction used by the Supabase auth page.
void registerSupabaseServices() {
  registerLazySingletonIfAbsent<TokenRepository>(InMemoryTokenRepository.new);
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
