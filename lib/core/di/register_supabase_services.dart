import 'package:flutter_bloc_app/core/di/injector_helpers.dart';
import 'package:flutter_bloc_app/features/supabase_auth/data/supabase_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';

/// Registers Supabase-related services.
///
/// [SupabaseAuthRepository] is the abstraction used by the Supabase auth page.
void registerSupabaseServices() {
  registerLazySingletonIfAbsent<SupabaseAuthRepository>(
    SupabaseAuthRepositoryImpl.new,
  );
}
