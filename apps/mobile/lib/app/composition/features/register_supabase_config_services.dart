import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/app/bootstrap/firebase_bootstrap_service.dart';
import 'package:flutter_bloc_app/app/composition/injector.dart';
import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/config/supabase_config_coordinator.dart';
import 'package:flutter_bloc_app/app/config/supabase_config_provider.dart';
import 'package:flutter_bloc_app/features/remote_config/domain/remote_config_service.dart';

/// Registers Supabase config provider/coordinator (Firebase-gated).
void registerSupabaseConfigServices() {
  final FirebaseAuth? firebaseAuth = _registeredFirebaseAuthOrNull();

  registerLazySingletonIfAbsent<SupabaseConfigProvider>(
    () => SupabaseConfigProvider(
      auth: firebaseAuth,
      remoteConfig: getIt<RemoteConfigService>(),
    ),
  );
  if (firebaseAuth == null) {
    return;
  }

  registerLazySingletonIfAbsent<SupabaseConfigCoordinator>(
    () => SupabaseConfigCoordinator(
      auth: firebaseAuth,
      provider: getIt<SupabaseConfigProvider>(),
    ),
    dispose: (final coordinator) => coordinator.dispose(),
  );
}

FirebaseAuth? _registeredFirebaseAuthOrNull() {
  if (!FirebaseBootstrapService.isFirebaseInitialized) {
    return null;
  }

  try {
    return getIt<FirebaseAuth>();
  } on Object {
    return null;
  }
}
