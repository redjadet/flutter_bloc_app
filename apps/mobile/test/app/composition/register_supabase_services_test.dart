import 'package:auth/auth.dart';
import 'package:flutter_bloc_app/app/composition/features/register_supabase_services.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/features/supabase_auth/data/supabase_auth_repository_impl.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockTokenRepository extends Mock implements TokenRepository {}

void main() {
  setUp(() async {
    await getIt.reset(dispose: true);
  });

  tearDown(() async {
    await getIt.reset(dispose: true);
  });

  test('registerSupabaseServices registers Supabase auth repository', () {
    getIt.registerSingleton<TokenRepository>(_MockTokenRepository());

    registerSupabaseServices();

    expect(getIt<SupabaseAuthRepository>(), isA<SupabaseAuthRepositoryImpl>());
    expect(getIt<RemoteBackendAuthPort>(), isA<SupabaseAuthRepository>());
  });
}
