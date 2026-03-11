import 'package:flutter_bloc_app/core/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/core/config/secret_config.dart';
import 'package:flutter_bloc_app/shared/platform/secure_secret_storage.dart';

Future<void> initializeSupabaseForTest() async {
  SecretConfig.resetForTest();
  SecretConfig.storage = InMemorySecretStorage();
  SecretConfig.debugEnvironment = <String, dynamic>{
    'SUPABASE_URL': 'https://example.supabase.co',
    'SUPABASE_ANON_KEY': 'anon-key',
  };
  SupabaseBootstrapService.resetForTest();
  SupabaseBootstrapService.initializeClient =
      ({required final String url, required final String anonKey}) async {};
  await SecretConfig.load(persistToSecureStorage: false);
  await SupabaseBootstrapService.initializeSupabase();
}

void resetSupabaseTestState() {
  SecretConfig.resetForTest();
  SupabaseBootstrapService.resetForTest();
}
