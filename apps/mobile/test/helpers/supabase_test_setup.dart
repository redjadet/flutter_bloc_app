import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/app/bootstrap/supabase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/config/secret_config.dart';

Future<void> initializeSupabaseForTest() async {
  SecretConfig.resetForTest();
  SecretConfig.storage = InMemorySecretStorage();
  SecretConfig.debugEnvironment = <String, dynamic>{
    'SUPABASE_URL': 'https://example.supabase.co',
    'SUPABASE_ANON_KEY': 'anon-key',
  };
  SupabaseBootstrapService.resetForTest();
  SupabaseBootstrapService.initializeClient = ({
    required String url,
    required String anonKey,
  }) async {};
  await SecretConfig.load(persistToSecureStorage: false);
  await SupabaseBootstrapService.initializeSupabase();
}

void resetSupabaseTestState() {
  SecretConfig.resetForTest();
  SupabaseBootstrapService.resetForTest();
}
